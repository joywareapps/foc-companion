import 'dart:io';
import 'package:restim_flutter/models/settings_models.dart';

class FileSourceService {
  Future<List<String>> findFunscripts(FunscriptLocation location, String videoBasename) async {
    if (location.type == 'local') {
      final dir = Directory(location.localPath);
      if (!await dir.exists()) return [];

      final files = await dir.list().toList();
      return files
          .whereType<File>()
          .where((f) => f.path.endsWith('.funscript') && 
                        f.path.split(Platform.pathSeparator).last.startsWith(videoBasename))
          .map((f) => f.path)
          .toList();
    }
    // WebDAV/SMB would go here
    return [];
  }

  Future<String> readFile(FunscriptLocation location, String path) async {
    if (location.type == 'local') {
      return await File(path).readAsString();
    }
    throw Exception("Source type not supported");
  }
}
