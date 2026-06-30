import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dart_smb2/dart_smb2.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/app_logger.dart';

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
