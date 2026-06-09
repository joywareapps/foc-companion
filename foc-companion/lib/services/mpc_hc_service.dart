import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/video_player_status.dart';

final _log = AppLogger.instance;

/// HTTP polling service for MPC-HC (and MPC-BE / mpv with web interface).
///
/// Polls the player's web interface every 250 ms (4 Hz) and emits
/// [VideoPlayerStatus] events through [statusStream].
///
/// Supports two API modes:
///   1. JSON API: GET /api/?q={} → JSON status (mpc-hc_ctrl project)
///   2. HTML interface: GET /variables.html → parse JS variables (standard MPC-HC)
///
/// Commands:
///   POST /api/?q={"command":"playpause"}         → toggle play/pause (JSON API)
///   GET  /command.html?wm_command=889             → toggle play/pause (web UI)
///   POST /api/?q={"command":"seek","param":12345} → seek to ms (JSON API)
///   GET  /command.html?wm_command=-1&position=123 → seek (web UI)
class MpcHcService {
  final String ip;
  final int port;

  Timer? _pollTimer;
  final StreamController<VideoPlayerStatus> _statusController =
      StreamController<VideoPlayerStatus>.broadcast();
  Stream<VideoPlayerStatus> get statusStream => _statusController.stream;

  /// Whether the player supports the JSON /api/ endpoint.
  bool _useJsonApi = true;

  static const _pollIntervalMs = 250;
  static const _connectTimeout = Duration(seconds: 5);

  MpcHcService({required this.ip, required this.port});

  /// Start periodic polling. Emits a disconnected status if polling fails.
  Future<void> startPolling() async {
    stopPolling();
    _log.i('MpcHcService: starting poll to $ip:$port');

    // Probe which API to use
    _useJsonApi = await _probeJsonApi();
    _log.i('MpcHcService: using ${_useJsonApi ? "JSON API" : "HTML interface"}');

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

  /// Probe whether the JSON /api/ endpoint is available.
  Future<bool> _probeJsonApi() async {
    try {
      final uri = Uri.http('$ip:$port', '/api/', {'q': '{}'});
      final client = HttpClient();
      try {
        final request = await client.getUrl(uri).timeout(_connectTimeout);
        final response = await request.close().timeout(_connectTimeout);
        if (response.statusCode == 200) {
          final body = await response.transform(utf8.decoder).join();
          // If it's valid JSON, the JSON API is available
          jsonDecode(body);
          return true;
        }
      } finally {
        client.close();
      }
    } catch (_) {
      // Not JSON — fall back to HTML interface
    }
    return false;
  }

  /// Single HTTP fetch to retrieve current player status.
  Future<VideoPlayerStatus> fetchStatus() async {
    if (_useJsonApi) {
      return _fetchStatusJson();
    } else {
      return _fetchStatusHtml();
    }
  }

  /// Fetch status using the JSON API.
  Future<VideoPlayerStatus> _fetchStatusJson() async {
    final uri = Uri.http('$ip:$port', '/api/', {'q': '{}'});
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri).timeout(_connectTimeout);
      final response = await request.close().timeout(_connectTimeout);

      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}', uri: uri);
      }

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      return _parseJsonStatus(json);
    } finally {
      client.close();
    }
  }

  /// Fetch status by parsing the HTML variables page.
  Future<VideoPlayerStatus> _fetchStatusHtml() async {
    final uri = Uri.http('$ip:$port', '/variables.html');
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri).timeout(_connectTimeout);
      final response = await request.close().timeout(_connectTimeout);

      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}', uri: uri);
      }

      final body = await response.transform(utf8.decoder).join();
      return _parseHtmlStatus(body);
    } finally {
      client.close();
    }
  }

  /// Send play/pause toggle command.
  Future<void> sendPlayPause() async {
    if (_useJsonApi) {
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
    } else {
      // MPC-HC web UI command 889 = play/pause
      final uri = Uri.http('$ip:$port', '/command.html', {
        'wm_command': '889',
      });
      final client = HttpClient();
      try {
        final request = await client.getUrl(uri).timeout(_connectTimeout);
        await request.close().timeout(_connectTimeout);
      } finally {
        client.close();
      }
    }
  }

  /// Send seek command. [positionMs] is the target position in ms.
  Future<void> sendSeek(int positionMs) async {
    if (_useJsonApi) {
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
    } else {
      // MPC-HC web UI: wm_command=-1 with position parameter seeks to seconds
      final uri = Uri.http('$ip:$port', '/command.html', {
        'wm_command': '-1',
        'position': '${positionMs ~/ 1000}',
      });
      final client = HttpClient();
      try {
        final request = await client.getUrl(uri).timeout(_connectTimeout);
        await request.close().timeout(_connectTimeout);
      } finally {
        client.close();
      }
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

  /// Parse JSON API response.
  VideoPlayerStatus _parseJsonStatus(Map<String, dynamic> json) {
    bool isPlaying = false;
    if (json.containsKey('playing')) {
      isPlaying = json['playing'] == true;
    } else if (json.containsKey('state')) {
      isPlaying = json['state'] == 2;
    }

    return VideoPlayerStatus(
      connected: true,
      isPlaying: isPlaying,
      currentTimeMs: (json['position'] ?? 0).toDouble(),
      durationMs: (json['duration'] ?? 0).toDouble(),
      filePath: json['filepath'] ?? json['path'] ?? json['filename'] ?? '',
      playbackSpeed: (json['playback_speed'] ?? json['speed'] ?? 1.0).toDouble(),
    );
  }

  /// Parse HTML variables page.
  ///
  /// Standard MPC-HC /variables.html format:
  ///   var MediaPlayer = new Object();
  ///   MediaPlayer.status = "Playing";
  ///   MediaPlayer.position = 12345;
  ///   MediaPlayer.duration = 600000;
  ///   MediaPlayer.filepath = "C:\\Videos\\video.mp4";
  ///   MediaPlayer.filename = "video.mp4";
  VideoPlayerStatus _parseHtmlStatus(String html) {
    final vars = <String, String>{};

    // Extract variables from MPC-HC standard <p id="key">value</p> format
    final pRegex = RegExp(r'<p id="([^"]+)">([^<]*)</p>', multiLine: true);
    for (final match in pRegex.allMatches(html)) {
      final key = match.group(1);
      var value = match.group(2)?.trim() ?? '';
      if (key != null) {
        vars[key] = value;
      }
    }

    // Also support MediaPlayer.xxx = yyy; in case some other player uses it
    final varRegex = RegExp(r'MediaPlayer\.(\w+)\s*=\s*(.+?)(?:;|$)', multiLine: true);
    for (final match in varRegex.allMatches(html)) {
      final key = match.group(1);
      var value = match.group(2)?.trim() ?? '';
      // Remove surrounding quotes
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }
      if (key != null) {
        vars[key] = value;
      }
    }

    final stateCode = vars['state'];
    final stateString = vars['statestring']?.toLowerCase() ?? vars['status']?.toLowerCase() ?? '';
    final isPlaying = stateCode == '2' || stateString == 'playing';

    final position = double.tryParse(vars['position'] ?? '0') ?? 0.0;
    final duration = double.tryParse(vars['duration'] ?? '0') ?? 0.0;
    final filepath = vars['filepath'] ?? '';
    final filename = vars['filename'] ?? '';

    return VideoPlayerStatus(
      connected: true,
      isPlaying: isPlaying,
      currentTimeMs: position,
      durationMs: duration,
      filePath: filepath.isNotEmpty ? filepath : filename,
      playbackSpeed: 1.0,
    );
  }

  void dispose() {
    stopPolling();
    _statusController.close();
  }
}