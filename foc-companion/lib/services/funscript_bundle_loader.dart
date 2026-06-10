import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:foc_companion/models/funscript.dart';
import 'package:foc_companion/models/funscript_bundle.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/funscript_parser.dart';

/// Handles .focb zip import, library storage, and bundle CRUD.
class FunscriptBundleLoader {
  FunscriptBundleLoader._();

  static const _uuid = Uuid();

  /// Import a .focb file from a file:// or content:// URI.
  static Future<FunscriptBundle> importFromUri(
    Uri sourceUri,
    String libraryDir,
  ) async {
    AppLogger.instance.i('FunscriptBundleLoader: importing from $sourceUri');

    // Copy source to temp file
    final sourceFile = File.fromUri(sourceUri);
    if (!sourceFile.existsSync()) {
      throw FileSystemException('Source file not found', sourceUri.toString());
    }

    final tempPath = '${(await getTemporaryDirectory()).path}/import_${DateTime.now().millisecondsSinceEpoch}.focb';
    await sourceFile.copy(tempPath);

    try {
      return await importFromPath(tempPath, libraryDir);
    } finally {
      // Clean up temp file
      try {
        await File(tempPath).delete();
      } catch (_) {}
    }
  }

  /// Import a .focb file from a local file path.
  static Future<FunscriptBundle> importFromPath(
    String path,
    String libraryDir,
  ) async {
    final bytes = await File(path).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find .funscript files
    final funscriptEntries = <ArchiveFile>[];
    for (final entry in archive) {
      if (entry.isFile && entry.name.toLowerCase().endsWith('.funscript')) {
        funscriptEntries.add(entry);
      }
    }

    if (funscriptEntries.isEmpty) {
      throw const FormatException('No .funscript files found in bundle');
    }

    // Bundle name = zip filename stem
    final zipFileName = path.split('/').last;
    final name = zipFileName.replaceAll(RegExp(r'\.(focb|zip)$', caseSensitive: false), '');

    // Check if bundle with this name already exists to prevent duplicates
    String id = _uuid.v4();
    final existingBundles = await listAll(libraryDir);
    for (final b in existingBundles) {
      if (b['name'] == name) {
        id = b['id'] as String;
        AppLogger.instance.i('FunscriptBundleLoader: updating existing bundle "$name" ($id)');
        break;
      }
    }

    // Parse each funscript
    final axes = <String, Funscript>{};
    for (final entry in funscriptEntries) {
      final axisSuffix = detectAxisSuffix(entry.name) ?? 'alpha';
      final content = String.fromCharCodes(entry.content as List<int>);
      final funscript = FunscriptParser.parse(content);
      axes[axisSuffix] = funscript;
      AppLogger.instance.d('FunscriptBundleLoader: parsed axis "$axisSuffix" (${funscript.actions.length} actions)');
    }

    // Calculate max duration
    var durationMs = 0;
    for (final f in axes.values) {
      if (f.durationMs > durationMs) durationMs = f.durationMs;
    }

    // Use established ID and create/overwrite library directory
    final bundleDir = '$libraryDir/$id';
    if (await Directory(bundleDir).exists()) {
      // Clear old content to ensure a clean overwrite
      await Directory(bundleDir).delete(recursive: true);
    }
    await Directory(bundleDir).create(recursive: true);

    // Extract zip contents into bundle directory
    for (final entry in archive) {
      if (!entry.isFile) continue;
      final filePath = '$bundleDir/${entry.name}';
      final parentDir = filePath.substring(0, filePath.lastIndexOf('/'));
      if (parentDir != bundleDir) {
        await Directory(parentDir).create(recursive: true);
      }
      await File(filePath).writeAsBytes(entry.content as List<int>);
    }

    // Write meta.json
    final meta = {
      'id': id,
      'name': name,
      'importDate': DateTime.now().toUtc().toIso8601String(),
      'durationMs': durationMs,
      'sourceFile': zipFileName,
      'axes': axes.keys.toList(),
      'waveformAxis': axes.containsKey('volume') ? 'volume' : (axes.containsKey('alpha') ? 'alpha' : axes.keys.first),
    };
    await File('$bundleDir/meta.json').writeAsString(jsonEncode(meta));

    AppLogger.instance.i('FunscriptBundleLoader: ${existingBundles.any((b) => b['name'] == name) ? "Updated" : "Imported"} "$name" ($id) with ${axes.length} axes');

    return FunscriptBundle(
      id: id,
      name: name,
      importDate: DateTime.now(),
      durationMs: durationMs,
      sourceFile: zipFileName,
      axes: axes,
    );
  }

  /// Quickly check if a zip file contains any .funscript files.
  static Future<bool> isValidBundle(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final entry in archive) {
        if (entry.isFile && entry.name.toLowerCase().endsWith('.funscript')) {
          return true;
        }
      }
    } catch (e) {
      AppLogger.instance.e('FunscriptBundleLoader: validation failed for $path', error: e);
    }
    return false;
  }

  /// Load a previously imported bundle from the library (re-parses funscripts).
  static Future<FunscriptBundle> loadFromLibrary(
    String bundleId,
    String libraryDir,
  ) async {
    final bundleDir = '$libraryDir/$bundleId';
    final metaFile = File('$bundleDir/meta.json');
    if (!metaFile.existsSync()) {
      throw FileSystemException('Bundle meta.json not found', bundleDir);
    }

    final metaJson = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
    final axisNames = (metaJson['axes'] as List<dynamic>).cast<String>();

    // Map filename stem (axis) to content
    final axisFiles = <String, String>{};
    final dir = Directory(bundleDir);
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.funscript')) {
        final detected = detectAxisSuffix(entity.path.split('/').last);
        if (detected != null) {
          axisFiles[detected] = await entity.readAsString();
        }
      }
    }

    // Re-parse all funscripts from extracted files
    final axes = <String, Funscript>{};
    for (final axisName in axisNames) {
      final content = axisFiles[axisName];
      if (content != null) {
        axes[axisName] = FunscriptParser.parse(content);
      }
    }

    return FunscriptBundle(
      id: bundleId,
      name: metaJson['name'] as String? ?? 'Unknown',
      importDate: DateTime.parse(metaJson['importDate'] as String),
      durationMs: metaJson['durationMs'] as int? ?? 0,
      sourceFile: metaJson['sourceFile'] as String? ?? '',
      axes: axes,
    );
  }

  /// List all bundles (meta.json only, no funscript parsing).
  static Future<List<Map<String, dynamic>>> listAll(String libraryDir) async {
    final libDir = Directory(libraryDir);
    if (!libDir.existsSync()) {
      await libDir.create(recursive: true);
      return [];
    }

    final results = <Map<String, dynamic>>[];
    await for (final entity in libDir.list()) {
      if (entity is Directory) {
        final metaFile = File('${entity.path}/meta.json');
        if (metaFile.existsSync()) {
          try {
            final meta = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
            results.add(meta);
          } catch (e) {
            AppLogger.instance.w('FunscriptBundleLoader: failed to read meta for ${entity.path}: $e');
          }
        }
      }
    }
    return results;
  }

  /// Rename a bundle (updates meta.json only).
  static Future<void> rename(String bundleId, String newName, String libraryDir) async {
    final bundleDir = '$libraryDir/$bundleId';
    final metaFile = File('$bundleDir/meta.json');
    if (!metaFile.existsSync()) {
      throw FileSystemException('Bundle meta.json not found', bundleDir);
    }

    final meta = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
    meta['name'] = newName;
    await metaFile.writeAsString(jsonEncode(meta));
    AppLogger.instance.i('FunscriptBundleLoader: renamed bundle $bundleId to "$newName"');
  }

  /// Update the preferred waveform axis for a bundle (updates meta.json only).
  static Future<void> updateWaveformAxis(String bundleId, String axis, String libraryDir) async {
    final bundleDir = '$libraryDir/$bundleId';
    final metaFile = File('$bundleDir/meta.json');
    if (!metaFile.existsSync()) {
      throw FileSystemException('Bundle meta.json not found', bundleDir);
    }

    final meta = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
    meta['waveformAxis'] = axis;
    await metaFile.writeAsString(jsonEncode(meta));
    AppLogger.instance.i('FunscriptBundleLoader: updated waveform axis for $bundleId to "$axis"');
  }

  /// Delete a bundle from the library.
  static Future<void> delete(String bundleId, String libraryDir) async {
    final bundleDir = '$libraryDir/$bundleId';
    final dir = Directory(bundleDir);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
      AppLogger.instance.i('FunscriptBundleLoader: deleted bundle $bundleId');
    }
  }

  /// Extract axis suffix from a funscript filename.
  ///
  /// "video.alpha.funscript" → "alpha"
  /// "scene.volume.funscript" → "volume"
  /// "something.funscript" → null
  /// "video.pulse_frequency.funscript" → "pulse_frequency"
  ///
  /// Logic: strip `.funscript`, then strip last dot-component = suffix.
  /// If nothing remains after stripping suffix, return null.
  static String? detectAxisSuffix(String filename) {
    final lower = filename.toLowerCase();
    if (!lower.endsWith('.funscript')) return null;

    // Strip .funscript
    final withoutExt = filename.substring(0, filename.length - '.funscript'.length);

    // Strip last dot-component
    final lastDot = withoutExt.lastIndexOf('.');
    if (lastDot == -1) return null; // no suffix (just "something")

    return withoutExt.substring(lastDot + 1);
  }
}
