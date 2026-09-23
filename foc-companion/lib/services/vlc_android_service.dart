import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/video_player_status.dart';

final _log = AppLogger.instance;

/// Thrown when VLC rejects the stored session cookie; the user must re-pair.
class VlcAndroidSessionExpired implements Exception {
  @override
  String toString() => 'Session expired or revoked - re-pair with the device';
}

class VlcAndroidPairingChallenge {
  final String challenge;
  VlcAndroidPairingChallenge(this.challenge);
}

class VlcAndroidService {
  String _ip = '127.0.0.1';
  int _port = 8080;
  bool _useHttps = false;

  // `user_session` cookie obtained after a successful pairing. Null/empty means "not paired yet".
  String? sessionCookie;

  http.Client? _httpClient;
  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;
  Timer? _reconnectTimer;
  bool _stopped = true;

  final _statusController = StreamController<VideoPlayerStatus>.broadcast();
  Stream<VideoPlayerStatus> get statusStream => _statusController.stream;

  bool get isPaired => sessionCookie != null && sessionCookie!.isNotEmpty;

  void configure(String ip, int port, {bool useHttps = false, String? sessionCookie}) {
    _ip = ip;
    _port = port;
    _useHttps = useHttps;
    this.sessionCookie = sessionCookie;
  }

  String get _httpScheme => _useHttps ? 'https' : 'http';
  String get _wsScheme => _useHttps ? 'wss' : 'ws';
  Uri _uri(String path) => Uri.parse('$_httpScheme://$_ip:$_port$path');

  http.Client _client() {
    if (_httpClient != null) return _httpClient!;
    if (_useHttps) {
      _httpClient = IOClient(_insecureHttpClient());
    } else {
      _httpClient = http.Client();
    }
    return _httpClient!;
  }

  // Accept VLC-Android's self-signed certificate, but only from the configured host
  HttpClient _insecureHttpClient() => HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => host == _ip;

  Future<VlcAndroidPairingChallenge> requestPairingCode({String? previousChallenge}) async {
    final response = await _client().post(
      _uri('/code'),
      body: previousChallenge != null ? {'challenge': previousChallenge} : null,
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Failed to request pairing code (HTTP ${response.statusCode})');
    }
    return VlcAndroidPairingChallenge(response.body.trim());
  }

  Future<bool> submitOtp(String challenge, String otpCode) async {
    final salted = sha256.convert(utf8.encode('$otpCode$challenge')).toString();

    final response = await _client().post(
      _uri('/verify-code'),
      body: {'code': salted},
    ).timeout(const Duration(seconds: 5));

    final setCookie = response.headers['set-cookie'];
    if ((response.statusCode == 302 || response.statusCode == 200) && setCookie != null) {
      final match = RegExp(r'user_session=[^;]+').firstMatch(setCookie);
      if (match != null) {
        sessionCookie = match.group(0);
        _log.i('VlcAndroidService: paired successfully');
        return true;
      }
    }
    if (response.statusCode == 429) {
      throw Exception('Too many attempts, wait a bit before retrying');
    }
    _log.w('VlcAndroidService: OTP verification failed');
    return false;
  }

  void unpair() {
    sessionCookie = null;
  }

  /// Connects to VLC. Throws [VlcAndroidSessionExpired] if the stored pairing
  /// is rejected, so the caller can surface a "re-pair needed" error.
  Future<void> startSync() async {
    if (!isPaired) {
      throw StateError('VlcAndroidService: not paired yet, call requestPairingCode/submitOtp first');
    }
    _stopped = false;
    await _connect(rethrowSessionExpired: true);
  }

  Future<void> _connect({bool rethrowSessionExpired = false}) async {
    if (_stopped) return;
    _closeChannel();
    try {
      final ticket = await _fetchTicket();
      if (_stopped) return;
      final uri = Uri.parse('$_wsScheme://$_ip:$_port/echo');

      final channel = IOWebSocketChannel.connect(
        uri,
        protocols: ['player'],
        headers: {'Cookie': sessionCookie!},
        pingInterval: const Duration(seconds: 10),
        customClient: _useHttps ? _insecureHttpClient() : null,
      );
      await channel.ready.timeout(const Duration(seconds: 5));
      if (_stopped) {
        channel.sink.close();
        return;
      }
      _channel = channel;

      _wsSubscription = channel.stream.listen(
        _onFrame,
        onError: (e) {
          _log.w('VlcAndroidService: websocket error: $e');
          _scheduleReconnect();
        },
        onDone: () {
          _log.i('VlcAndroidService: websocket closed');
          _scheduleReconnect();
        },
        cancelOnError: true,
      );

      _send({'message': 'hello', 'authTicket': ticket});
      _emit(const VideoPlayerStatus(connected: true));
    } on VlcAndroidSessionExpired {
      // Retrying can't succeed until the user re-pairs, so stop here.
      _log.e('VlcAndroidService: session rejected by VLC, re-pairing required');
      _stopped = true;
      _emit(const VideoPlayerStatus.disconnected());
      if (rethrowSessionExpired) rethrow;
    } catch (e) {
      _log.w('VlcAndroidService: failed to connect: $e');
      _emit(const VideoPlayerStatus.disconnected());
      _scheduleReconnect();
    }
  }

  void _emit(VideoPlayerStatus status) {
    if (!_statusController.isClosed) _statusController.add(status);
  }

  void _closeChannel() {
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  Future<String> _fetchTicket() async {
    final response = await _client().get(
      _uri('/wsticket'),
      headers: {'Cookie': sessionCookie!},
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 401) {
      throw VlcAndroidSessionExpired();
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch websocket ticket (HTTP ${response.statusCode})');
    }
    return response.body.trim();
  }

  void _onFrame(dynamic raw) {
    try {
      final Map<String, dynamic> json = jsonDecode(raw as String) as Map<String, dynamic>;
      if (json['type'] != 'now-playing') return;

      _emit(VideoPlayerStatus(
        connected: true,
        isPlaying: json['playing'] == true,
        currentTimeMs: (json['progress'] as num?)?.toDouble() ?? 0,
        durationMs: (json['duration'] as num?)?.toDouble() ?? 0,
        filePath: json['title'] as String?,
        playbackSpeed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      ));
    } catch (e) {
      _log.w('VlcAndroidService: could not parse frame: $e');
    }
  }

  void _send(Map<String, dynamic> message) {
    try {
      _channel?.sink.add(jsonEncode(message));
    } catch (e) {
      _log.w('VlcAndroidService: send failed: $e');
    }
  }

  Future<void> _sendControl(String message, {int? id, double? floatValue, int? longValue, String? stringValue}) async {
    if (!isPaired) return;
    try {
      final ticket = await _fetchTicket();
      _send({
        'message': message,
        if (id != null) 'id': id,
        if (floatValue != null) 'floatValue': floatValue,
        if (longValue != null) 'longValue': longValue,
        if (stringValue != null) 'stringValue': stringValue,
        'authTicket': ticket,
      });
    } catch (e) {
      _log.w('VlcAndroidService: control command "$message" failed: $e');
    }
  }

  Future<void> play() => _sendControl('play');
  Future<void> pause() => _sendControl('pause');
  Future<void> seekTo(int timeMs) => _sendControl('set-progress', id: timeMs);
  Future<void> setSpeed(double speed) => _sendControl('speed', floatValue: speed);

  void _scheduleReconnect() {
    if (_stopped) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), _connect);
  }

  void stopSync() {
    _stopped = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _closeChannel();
    _emit(const VideoPlayerStatus.disconnected());
  }

  void dispose() {
    stopSync();
    _httpClient?.close();
    _statusController.close();
  }
}
