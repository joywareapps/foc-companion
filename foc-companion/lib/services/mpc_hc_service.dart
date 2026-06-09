import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/video_player_status.dart';

final _log = AppLogger.instance;

/// HTTP JSON-RPC polling service for MPC-HC (and mpv with mpv-jsonipc).
///
/// Polls the player's web interface every 250 ms (4 Hz) and emits
/// [VideoPlayerStatus] events through [statusStream].
///
/// MPC-HC API:
///   GET  /api/?q={}                              → current status
///   POST /api/?q={"command":"playpause"}         → toggle play/pause
///   POST /api/?q={"command":"seek","param":12345} → seek to ms
class MpcHcService {
  final String ip;
  final int port;

  Timer? _pollTimer;
  final StreamController<VideoPlayerStatus> _statusController =
      StreamController<VideoPlayerStatus>.broadcast();
  Stream<VideoPlayerStatus> get statusStream => _statusController.stream;

  static const _pollIntervalMs = 250;
  static const _connectTimeout = Duration(seconds: 5);

  MpcHcService({required this.ip, required this.port});

  /// Start periodic polling. Emits a disconnected status if polling fails.
  Future<void> startPolling() async {
    stopPolling();
    _log.i('MpcHcService: starting poll to $ip:$port');

    // Verify connectivity with a first fetch before starting timer
    try {
      final status = await fetchStatus();
      _statusController.add(status);
    } catch (e) {
      _log.w('MpcHcService: initial fetch failed, starting poll anyway: $e');
      _statusController.add(const VideoPlayerStatus.disconnected());
    }

    _pollTimer = Timer.periodic(
      const Duration(milliseconds: _pollIntervalMs),
      (_) => _poll(),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Single HTTP GET to retrieve current player status.
  Future<VideoPlayerStatus> fetchStatus() async {
    final uri = Uri.http('$ip:$port', '/api/', {'q': '{}'});
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri).timeout(_connectTimeout);
      final response = await request.close().timeout(_connectTimeout);

      if (response.statusCode != 200) {
        throw HttpException(
            'HTTP ${response.statusCode}', uri: uri);
      }

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      return _parseStatus(json);
    } finally {
      client.close();
    }
  }

  /// Send play/pause toggle command via HTTP POST.
  Future<void> sendPlayPause() async {
    final uri = Uri.http('$ip:$port', '/api/', {
      'q': jsonEncode({'command': 'playpause'}),
    });
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri).timeout(_connectTimeout);
      await request.close().timeout(_connectTimeout);
    } finally {
      client.close();
    }
  }

  /// Send seek command via HTTP POST. [positionMs] is the target position in ms.
  Future<void> sendSeek(int positionMs) async {
    final uri = Uri.http('$ip:$port', '/api/', {
      'q': jsonEncode({'command': 'seek', 'param': positionMs}),
    });
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri).timeout(_connectTimeout);
      await request.close().timeout(_connectTimeout);
    } finally {
      client.close();
    }
  }

  void _poll() async {
    try {
      final status = await fetchStatus();
      _statusController.add(status);
    } catch (e) {
      _log.w('MpcHcService: poll error: $e');
      _statusController.add(const VideoPlayerStatus.disconnected());
    }
  }

  /// Parse MPC-HC / mpv JSON response into [VideoPlayerStatus].
  ///
  /// MPC-HC format: { "playing": true, "position": 12345, "duration": 600000,
  ///                  "filename": "video.mp4", "filepath": "C:\\Videos\\video.mp4" }
  /// mpv format:    { "playing": true, "position": 12345, "duration": 600000,
  ///                  "filename": "video.mp4", "path": "C:\\Videos\\video.mp4" }
  VideoPlayerStatus _parseStatus(Map<String, dynamic> json) {
    return VideoPlayerStatus(
      connected: true,
      isPlaying: json['playing'] == true,
      currentTimeMs: (json['position'] ?? 0).toDouble(),
      durationMs: (json['duration'] ?? 0).toDouble(),
      filePath: json['filepath'] ?? json['path'] ?? json['filename'] ?? '',
      playbackSpeed: (json['playback_speed'] ?? json['speed'] ?? 1.0).toDouble(),
    );
  }

  void dispose() {
    stopPolling();
    _statusController.close();
  }
}
