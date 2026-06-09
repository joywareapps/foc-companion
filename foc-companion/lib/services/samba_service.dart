import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dart_smb2/dart_smb2.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/app_logger.dart';

class SambaService {
  SambaService._();
  static final instance = SambaService._();

  /// Test connection to an SMB location.
  /// Returns null on success, or an error message on failure.
  Future<String?> testConnection(FunscriptLocation loc) async {
    if (loc.type != 'smb') return "Invalid location type";

    try {
      final share = loc.smbShare.replaceAll('\\', '/').replaceAll('//', '/');
      final cleanShare = share.startsWith('/') ? share.substring(1) : share;

      final pool = await Smb2Pool.connect(
        host: loc.smbHost,
        share: cleanShare,
        user: loc.smbUsername.isEmpty ? 'guest' : loc.smbUsername,
        password: loc.smbPassword,
        domain: loc.smbDomain,
      );
      
      // Try to list the root of the share to verify access
      // Using empty string as some servers reject '.'
      await pool.listDirectory('');
      await pool.disconnect();
      return null; // Success
    } catch (e) {
      AppLogger.instance.e("SambaService testConnection error", error: e);
      return e.toString();
    }
  }

  /// Search for a file in an SMB location.
  /// Returns the remote path if found, null otherwise.
  Future<String?> findFile(FunscriptLocation loc, String pattern) async {
    if (loc.type != 'smb') return null;

    try {
      final share = loc.smbShare.replaceAll('\\', '/').replaceAll('//', '/');
      final cleanShare = share.startsWith('/') ? share.substring(1) : share;

      final pool = await Smb2Pool.connect(
        host: loc.smbHost,
        share: cleanShare,
        user: loc.smbUsername.isEmpty ? 'guest' : loc.smbUsername,
        password: loc.smbPassword,
        domain: loc.smbDomain,
      );

      // Pattern is usually "Filename.focb" or "Filename.zip"
      final entries = await pool.listDirectory('');
      
      String? foundPath;
      for (final entry in entries) {
        if (entry.name.toLowerCase() == pattern.toLowerCase()) {
          AppLogger.instance.i("SambaService: found match '$pattern' at ${loc.smbHost}/$cleanShare");
          foundPath = entry.name;
          break;
        }
      }
      
      await pool.disconnect();
      return foundPath;
    } catch (e) {
      AppLogger.instance.e("SambaService list error", error: e);
      return null;
    }
  }

  /// Download a file from SMB to a temporary local file.
  Future<File?> downloadFile(FunscriptLocation loc, String remotePath) async {
    try {
      final share = loc.smbShare.replaceAll('\\', '/').replaceAll('//', '/');
      final cleanShare = share.startsWith('/') ? share.substring(1) : share;

      final pool = await Smb2Pool.connect(
        host: loc.smbHost,
        share: cleanShare,
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
