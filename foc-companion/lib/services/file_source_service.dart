import 'dart:io';

import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/found_bundle.dart';
import 'package:foc_companion/services/funscript_bundle_loader.dart';
import 'package:foc_companion/services/samba_service.dart';

class FileSourceService {
  /// Find the best matching funscript bundle for [videoBasename] in [location].
  ///
  /// Returns a [FoundBundle] describing either an archive (.focb/.zip) or a
  /// set of loose .funscript files, chosen by the completeness+date rule.
  /// Returns null when nothing matching is found.
  Future<FoundBundle?> findBundle(FunscriptLocation location, String videoBasename) async {
    if (location.type == 'local') {
      return _findLocal(location, videoBasename);
    } else if (location.type == 'smb') {
      return SambaService.instance.findBundle(location, videoBasename);
    }
    return null;
  }

  Future<FoundBundle?> _findLocal(FunscriptLocation loc, String videoBasename) async {
    final dir = Directory(loc.localPath);
    if (!await dir.exists()) return null;

    final all = await dir.list(recursive: loc.searchSubfolders).toList();
    final lower = videoBasename.toLowerCase();
    final sep = Platform.pathSeparator;

    // ── Archive candidate (.focb preferred over .zip) ──────────────────────
    FoundBundle? archiveCandidate;
    for (final ext in ['.focb', '.zip']) {
      final match = all.whereType<File>().where((f) {
        final name = f.path.split(sep).last.toLowerCase();
        return name == '$lower$ext';
      }).firstOrNull;

      if (match != null) {
        final bytes = await match.readAsBytes();
        final axes = FunscriptBundleLoader.axesFromArchiveBytes(bytes);
        final date = await match.lastModified();
        archiveCandidate = FoundBundle.archive(match.path, axes: axes, date: date);
        break;
      }
    }

    // ── Loose funscript candidate ──────────────────────────────────────────
    final looseFiles = all.whereType<File>().where((f) {
      final name = f.path.split(sep).last.toLowerCase();
      return name.startsWith('$lower.') && name.endsWith('.funscript');
    }).toList();

    FoundBundle? looseCandidate;
    if (looseFiles.isNotEmpty) {
      final axes = looseFiles
          .map((f) => FunscriptBundleLoader.detectAxisSuffix(f.path.split(sep).last))
          .nonNulls
          .toSet();
      DateTime newest = DateTime.fromMillisecondsSinceEpoch(0);
      for (final f in looseFiles) {
        final d = await f.lastModified();
        if (d.isAfter(newest)) newest = d;
      }
      looseCandidate = FoundBundle.loose(
        looseFiles.map((f) => f.path).toList(),
        axes: axes,
        date: newest,
      );
    }

    return pickBundleWinner(archiveCandidate, looseCandidate);
  }
}
