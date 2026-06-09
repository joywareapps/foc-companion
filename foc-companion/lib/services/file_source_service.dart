import 'dart:io';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/samba_service.dart';
import 'package:foc_companion/services/app_logger.dart';

class FileSourceService {
  /// Find matching funscript bundles (.focb or .zip) for a video filename.
  Future<List<String>> findBundles(FunscriptLocation location, String videoBasename) async {
    if (location.type == 'local') {
      final dir = Directory(location.localPath);
      if (!await dir.exists()) return [];

      final files = await dir.list().toList();
      return files
          .whereType<File>()
          .where((f) {
            final name = f.path.split(Platform.pathSeparator).last.toLowerCase();
            return (name.endsWith('.focb') || name.endsWith('.zip')) && 
                   name.startsWith(videoBasename.toLowerCase());
          })
          .map((f) => f.path)
          .toList();
    } else if (location.type == 'smb') {
      // Logic for SMB listing would go here via SambaService
      final focb = await SambaService.instance.findFile(location, "$videoBasename.focb");
      if (focb != null) return [focb];
      
      final zip = await SambaService.instance.findFile(location, "$videoBasename.zip");
      if (zip != null) return [zip];
    }
    return [];
  }

  /// Original method for individual funscripts (legacy support)
  Future<List<String>> findFunscripts(FunscriptLocation location, String videoBasename) async {
    if (location.type == 'local') {
      final dir = Directory(location.localPath);
      if (!await dir.exists()) return [];

      final files = await dir.list().toList();
      return files
          .whereType<File>()
          .where((f) => f.path.endsWith('.funscript') && 
                        f.path.split(Platform.pathSeparator).last.toLowerCase().startsWith(videoBasename.toLowerCase()))
          .map((f) => f.path)
          .toList();
    }
    return [];
  }

  Future<String> readFile(FunscriptLocation location, String path) async {
    if (location.type == 'local') {
      return await File(path).readAsString();
    }
    throw Exception("Source type not supported for individual file read");
  }
}
