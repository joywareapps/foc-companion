import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/models/funscript_bundle.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/file_source_service.dart';
import 'package:foc_companion/services/funscript_bundle_loader.dart';
import 'package:foc_companion/services/funscript_playback_controller.dart';
import 'package:foc_companion/services/samba_service.dart';

class MediaSyncOrchestrator {
  final SettingsProvider settings;
  final FunscriptPlaybackController playbackController;
  final Function(FunscriptBundle)? onBundleLoaded;
  final FileSourceService _fileSourceService = FileSourceService();

  String? _lastVideoBasename;

  MediaSyncOrchestrator({
    required this.settings,
    required this.playbackController,
    this.onBundleLoaded,
  });

  /// Call this when the player reports a new filename.
  Future<void> onFilenameChanged(String filename) async {
    if (!settings.mediaSync.autoloadEnabled) return;

    // Normalize filename (remove extension if present)
    String basename = filename;
    if (basename.contains('.')) {
      basename = basename.substring(0, basename.lastIndexOf('.'));
    }

    if (basename == _lastVideoBasename) return;
    _lastVideoBasename = basename;

    AppLogger.instance.i("MediaSyncOrchestrator: video changed to '$basename', searching for bundles...");

    for (final loc in settings.mediaSync.funscriptLocations) {
      try {
        final bundles = await _fileSourceService.findBundles(loc, basename);
        if (bundles.isNotEmpty) {
          final bundlePath = bundles.first;
          AppLogger.instance.i("MediaSyncOrchestrator: found bundle at $bundlePath");

          File? localFile;
          if (loc.type == 'local') {
            localFile = File(bundlePath);
          } else if (loc.type == 'smb') {
            AppLogger.instance.i("MediaSyncOrchestrator: downloading from SMB...");
            localFile = await SambaService.instance.downloadFile(loc, bundlePath);
          }

          if (localFile != null && await localFile.exists()) {
            await _importAndLoad(localFile);
            return; // Stop after first match
          }
        }
      } catch (e) {
        AppLogger.instance.e("MediaSyncOrchestrator: error searching location ${loc.name}", error: e);
      }
    }

    AppLogger.instance.w("MediaSyncOrchestrator: no matching bundle found for '$basename'");
  }

  Future<void> _importAndLoad(File file) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final libraryDir = "${docDir.path}/funscript_library";
      
      final bundle = await FunscriptBundleLoader.importFromPath(file.path, libraryDir);
      playbackController.load(bundle);
      onBundleLoaded?.call(bundle);
      
      AppLogger.instance.i("MediaSyncOrchestrator: successfully autoloaded '${bundle.name}'");
    } catch (e) {
      AppLogger.instance.e("MediaSyncOrchestrator: failed to import/load bundle", error: e);
    }
  }
}
