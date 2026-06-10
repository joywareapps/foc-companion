import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/video_player_status.dart';

final _log = AppLogger.instance;

/// HTTP polling service for MPC-HC using the variables.html endpoint.
///
/// Polls the player's web interface every 500 ms and emits
/// [VideoPlayerStatus] events through [statusStream].
class MpcHcService {
  String _ip = '';
  int _port = 13579;

  Timer? _pollTimer;
  final StreamController<VideoPlayerStatus> _statusController =
      StreamController<VideoPlayerStatus>.broadcast();
  Stream<VideoPlayerStatus> get statusStream => _statusController.stream;

  static const _pollIntervalMs = 500;
  static const _connectTimeout = Duration(seconds: 2);
  final HttpClient _client = HttpClient()..connectionTimeout = _connectTimeout;

  void configure(String ip, int port) {
    _ip = ip;
    _port = port;
  }

  /// Start periodic polling. Emits a disconnected status if polling fails.
  Future<void> startPolling() async {
    stopPolling();
    if (_ip.isEmpty) return;
    
    _log.i('MpcHcService: starting poll to $_ip:$_port');

    _pollTimer = Timer.periodic(
      const Duration(milliseconds: _pollIntervalMs),
      (_) => _poll(),
    );
    _poll(); // Immediate first poll
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Single HTTP GET to retrieve current player status from variables.html.
  Future<VideoPlayerStatus> fetchStatus() async {
    final uri = Uri.parse('http://$_ip:$_port/variables.html');
    try {
      final request = await _client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}', uri: uri);
      }

      final body = await response.transform(const Utf8Decoder()).join();
      return _parseVariablesHtml(body);
    } catch (e) {
      rethrow;
    }
  }

  /// Send play/pause toggle command.
  Future<void> sendPlayPause() async {
    final uri = Uri.parse('http://$_ip:$_port/command.html?wm_command=887'); // Toggle play/pause
    try {
      final request = await _client.getUrl(uri);
      await request.close();
    } catch (e) {
      _log.e("MpcHcService: failed to send play/pause", error: e);
    }
  }

  /// Send seek command. [positionMs] is target in ms.
  Future<void> sendSeek(int positionMs) async {
    // Note: command 102 (seek) might not work via URL easily in all versions.
    // For now we focus on status retrieval.
  }

  void _poll() async {
    try {
      final status = await fetchStatus();
      _statusController.add(status);
    } catch (e) {
      _statusController.add(const VideoPlayerStatus.disconnected());
    }
  }

  /// Extract data from variables.html using Regex.
  VideoPlayerStatus _parseVariablesHtml(String body) {
    final filePath = _extract(body, 'filepath') ?? _extract(body, 'file') ?? '';
    final state = int.tryParse(_extract(body, 'state') ?? '0') ?? 0; // 0=stopped, 1=paused, 2=playing
    final position = double.tryParse(_extract(body, 'position') ?? '0') ?? 0.0;
    final duration = double.tryParse(_extract(body, 'duration') ?? '0') ?? 0.0;
    final speed = double.tryParse(_extract(body, 'playbackrate') ?? '1.0') ?? 1.0;

    return VideoPlayerStatus(
      connected: true,
      isPlaying: state == 2,
      currentTimeMs: position,
      durationMs: duration,
      filePath: filePath,
      playbackSpeed: speed,
    );
  }

  String? _extract(String body, String id) {
    final reg = RegExp('<p id="$id">(.*?)</p>');
    final match = reg.firstMatch(body);
    return match?.group(1);
  }

  void dispose() {
    stopPolling();
    _statusController.close();
    _client.close();
  }
}
