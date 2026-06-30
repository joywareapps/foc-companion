import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dart_smb2/dart_smb2.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/found_bundle.dart';
import 'package:foc_companion/services/funscript_bundle_loader.dart';

class SambaService {
  SambaService._();
  static final instance = SambaService._();

  String _cleanShare(String raw) {
    final s = raw.replaceAll('\\', '/').replaceAll('//', '/');
    return s.startsWith('/') ? s.substring(1) : s;
  }

  String _cleanPath(String raw) {
    final s = raw.replaceAll('\\', '/').trim();
    // Strip leading/trailing slashes so we can safely join with '/'
    return s.replaceAll(RegExp(r'^/+|/+$'), '');
  }

  /// Resolves the directory path within the share for listing.
  String _listDir(FunscriptLocation loc) {
    return _cleanPath(loc.smbPath);
  }


  /// Test connection to an SMB location.
  /// Returns null on success, or an error message on failure.
  Future<String?> testConnection(FunscriptLocation loc) async {
    if (loc.type != 'smb') return "Invalid location type";

    try {
      final pool = await Smb2Pool.connect(
        host: loc.smbHost,
        share: _cleanShare(loc.smbShare),
        user: loc.smbUsername.isEmpty ? 'guest' : loc.smbUsername,
        password: loc.smbPassword,
        domain: loc.smbDomain,
      );

      await pool.listDirectory(_listDir(loc));
      await pool.disconnect();
      return null; // Success
    } catch (e) {
      AppLogger.instance.e("SambaService testConnection error", error: e);
      return e.toString();
    }
  }

  /// Search for a file in an SMB location.
  /// Returns the remote path (with subfolder prefix) if found, null otherwise.
  Future<String?> findFile(FunscriptLocation loc, String pattern) async {
    if (loc.type != 'smb') return null;

    try {
      final pool = await Smb2Pool.connect(
        host: loc.smbHost,
        share: _cleanShare(loc.smbShare),
        user: loc.smbUsername.isEmpty ? 'guest' : loc.smbUsername,
        password: loc.smbPassword,
        domain: loc.smbDomain,
      );

      final rootDir = _listDir(loc);
      final foundPath = loc.searchSubfolders
          ? await _findRecursive(pool, rootDir, pattern, 0)
          : await _findInDir(pool, rootDir, pattern, rootDir);

      await pool.disconnect();

      if (foundPath != null) {
        AppLogger.instance.i("SambaService: found '$pattern' at ${loc.smbHost}/${loc.smbShare}/$foundPath");
      }
      return foundPath;
    } catch (e) {
      AppLogger.instance.e("SambaService list error", error: e);
      return null;
    }
  }

  Future<String?> _findInDir(Smb2Pool pool, String dirPath, String pattern, String rootDir) async {
    final entries = await pool.listDirectory(dirPath);
    for (final entry in entries) {
      if (entry.isFile && entry.name.toLowerCase() == pattern.toLowerCase()) {
        return dirPath.isEmpty ? entry.name : '$dirPath/${entry.name}';
      }
    }
    return null;
  }

  Future<String?> _findRecursive(Smb2Pool pool, String dirPath, String pattern, int depth) async {
    if (depth > 6) return null;
    try {
      final entries = await pool.listDirectory(dirPath);
      for (final entry in entries) {
        if (entry.name == '.' || entry.name == '..') continue;
        final entryPath = dirPath.isEmpty ? entry.name : '$dirPath/${entry.name}';
        if (entry.isFile && entry.name.toLowerCase() == pattern.toLowerCase()) {
          return entryPath;
        }
        if (entry.isDirectory) {
          final found = await _findRecursive(pool, entryPath, pattern, depth + 1);
          if (found != null) return found;
        }
      }
    } catch (e) {
      AppLogger.instance.e("SambaService recursive list error at $dirPath", error: e);
    }
    return null;
  }

  /// Find the best bundle candidate in one connection, returning a [FoundBundle].
  ///
  /// Lists the configured directory once and collects:
  ///  - An archive (.focb / .zip) with its modification date.
  ///  - Loose .funscript files with their axes (from filenames) and newest date.
  ///
  /// Completeness comparison uses the date-only rule for SMB because reading
  /// archive contents requires a full download.
  Future<FoundBundle?> findBundle(FunscriptLocation loc, String videoBasename) async {
    if (loc.type != 'smb') return null;

    try {
      final pool = await Smb2Pool.connect(
        host: loc.smbHost,
        share: _cleanShare(loc.smbShare),
        user: loc.smbUsername.isEmpty ? 'guest' : loc.smbUsername,
        password: loc.smbPassword,
        domain: loc.smbDomain,
      );

      final rootDir = _listDir(loc);
      FoundBundle? archive;
      FoundBundle? loose;

      if (loc.searchSubfolders) {
        final result = await _collectBundleCandidatesRecursive(pool, rootDir, videoBasename.toLowerCase(), 0);
        archive = result.$1;
        loose = result.$2;
      } else {
        final result = await _collectBundleCandidatesInDir(pool, rootDir, videoBasename.toLowerCase());
        archive = result.$1;
        loose = result.$2;
      }

      await pool.disconnect();
      return pickBundleWinner(archive, loose);
    } catch (e) {
      AppLogger.instance.e("SambaService findBundle error", error: e);
      return null;
    }
  }

  Future<(FoundBundle?, FoundBundle?)> _collectBundleCandidatesInDir(
    Smb2Pool pool, String dirPath, String lowerBasename) async {
    final entries = await pool.listDirectory(dirPath);

    String? archivePath;
    DateTime? archiveDate;
    final loosePaths = <String>[];
    final looseAxes = <String>{};
    DateTime looseNewest = DateTime.fromMillisecondsSinceEpoch(0);

    for (final entry in entries) {
      if (!entry.isFile) continue;
      final name = entry.name.toLowerCase();
      final path = dirPath.isEmpty ? entry.name : '$dirPath/${entry.name}';

      if (archivePath == null) {
        if (name == '$lowerBasename.focb' || name == '$lowerBasename.zip') {
          archivePath = path;
          archiveDate = entry.stat.modified;
          continue;
        }
      }

      if (name.startsWith('$lowerBasename.') && name.endsWith('.funscript')) {
        final axis = FunscriptBundleLoader.detectAxisSuffix(entry.name);
        if (axis != null) {
          loosePaths.add(path);
          looseAxes.add(axis);
          if (entry.stat.modified.isAfter(looseNewest)) looseNewest = entry.stat.modified;
        }
      }
    }

    final archiveBundle = archivePath != null
        ? FoundBundle.archive(archivePath, axes: const {}, date: archiveDate!)
        : null;
    final looseBundle = loosePaths.isNotEmpty
        ? FoundBundle.loose(loosePaths, axes: looseAxes, date: looseNewest)
        : null;
    return (archiveBundle, looseBundle);
  }

  Future<(FoundBundle?, FoundBundle?)> _collectBundleCandidatesRecursive(
    Smb2Pool pool, String dirPath, String lowerBasename, int depth) async {
    if (depth > 6) return (null, null);
    try {
      var (archive, loose) = await _collectBundleCandidatesInDir(pool, dirPath, lowerBasename);
      if (archive != null && loose != null) return (archive, loose);

      final entries = await pool.listDirectory(dirPath);
      for (final entry in entries) {
        if (!entry.isDirectory || entry.name == '.' || entry.name == '..') continue;
        final subPath = dirPath.isEmpty ? entry.name : '$dirPath/${entry.name}';
        final (subArchive, subLoose) = await _collectBundleCandidatesRecursive(
            pool, subPath, lowerBasename, depth + 1);
        archive ??= subArchive;
        loose ??= subLoose;
        if (archive != null && loose != null) break;
      }
      return (archive, loose);
    } catch (e) {
      AppLogger.instance.e("SambaService recursive findBundle error at $dirPath", error: e);
      return (null, null);
    }
  }

  /// Download multiple SMB files to temp in a single connection.
  Future<List<File>> downloadFiles(FunscriptLocation loc, List<String> remotePaths) async {
    final results = <File>[];
    try {
      final pool = await Smb2Pool.connect(
        host: loc.smbHost,
        share: _cleanShare(loc.smbShare),
        user: loc.smbUsername.isEmpty ? 'guest' : loc.smbUsername,
        password: loc.smbPassword,
        domain: loc.smbDomain,
      );
      final tempDir = await getTemporaryDirectory();
      for (final remotePath in remotePaths) {
        try {
          final bytes = await pool.readFile(remotePath);
          final localFile = File('${tempDir.path}/${remotePath.split('/').last}');
          await localFile.writeAsBytes(bytes);
          results.add(localFile);
          AppLogger.instance.i("SambaService: downloaded $remotePath");
        } catch (e) {
          AppLogger.instance.e("SambaService: failed to download $remotePath", error: e);
        }
      }
      await pool.disconnect();
    } catch (e) {
      AppLogger.instance.e("SambaService downloadFiles error", error: e);
    }
    return results;
  }

  /// Download a file from SMB to a temporary local file.
  /// [remotePath] should already include any subfolder prefix (as returned by findFile).
  Future<File?> downloadFile(FunscriptLocation loc, String remotePath) async {
    try {
      final pool = await Smb2Pool.connect(
        host: loc.smbHost,
        share: _cleanShare(loc.smbShare),
        user: loc.smbUsername.isEmpty ? 'guest' : loc.smbUsername,
        password: loc.smbPassword,
        domain: loc.smbDomain,
      );
      
      final tempDir = await getTemporaryDirectory();
      final localFile = File('${tempDir.path}/${remotePath.split('/').last}');
      
      final bytes = await pool.readFile(remotePath);
      await localFile.writeAsBytes(bytes);
      
      AppLogger.instance.i("SambaService: downloaded $remotePath to ${localFile.path}");
      await pool.disconnect();
      return localFile;
    } catch (e) {
      AppLogger.instance.e("SambaService download error", error: e);
      return null;
    }
  }
}
