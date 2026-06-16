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
  Future<void> onFilenameChanged(String filename, {bool force = false}) async {
    if (!force && !settings.mediaSync.autoloadEnabled) return;

    // Robustly extract filename from URL or Path
    String name = filename;
    final uri = Uri.tryParse(name);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      name = uri.pathSegments.last;
    } else {
      name = name.split('/').last.split('\\').last;
    }

    // Normalize filename (remove extension if present)
    String basename = name;
    if (basename.contains('.')) {
      basename = basename.substring(0, basename.lastIndexOf('.'));
    }

    if (basename == _lastVideoBasename) return;
    _lastVideoBasename = basename;

    AppLogger.instance.i("MediaSyncOrchestrator: video changed to '$basename', searching for bundles...");

    // 1. Check local library first
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final libraryDir = "${docDir.path}/funscript_library";
      final existingBundles = await FunscriptBundleLoader.listAll(libraryDir);
      
      for (final meta in existingBundles) {
        if (meta['name'] == basename) {
          AppLogger.instance.i("MediaSyncOrchestrator: found '$basename' in local library, loading...");
          final bundle = await FunscriptBundleLoader.loadFromLibrary(meta['id'] as String, libraryDir);
          playbackController.load(bundle);
          onBundleLoaded?.call(bundle);
          return; // Success
        }
      }
    } catch (e) {
      AppLogger.instance.e("MediaSyncOrchestrator: error checking local library", error: e);
    }

    // 2. Check configured locations (Local folders and SMB)
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
