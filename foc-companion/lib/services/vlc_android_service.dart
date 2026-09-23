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
      // Accept VLC-Android's self-signed certificate
      final ioClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => host == _ip;
      _httpClient = IOClient(ioClient);
    } else {
      _httpClient = http.Client();
    }
    return _httpClient!;
  }

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

  Future<void> startSync() async {
    if (!isPaired) {
      throw StateError('VlcAndroidService: not paired yet, call requestPairingCode/submitOtp first');
    }
    _stopped = false;
    await _connect();
  }

  Future<void> _connect() async {
    if (_stopped) return;
    try {
      final ticket = await _fetchTicket();
      final uri = Uri.parse('$_wsScheme://$_ip:$_port/echo');

      _channel = IOWebSocketChannel.connect(
        uri,
        protocols: ['player'],
        headers: {'Cookie': sessionCookie!},
        pingInterval: const Duration(seconds: 10),
      );

      _wsSubscription = _channel!.stream.listen(
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
      _statusController.add(const VideoPlayerStatus(connected: true));
    } catch (e) {
      _log.w('VlcAndroidService: failed to connect: $e');
      _statusController.add(const VideoPlayerStatus.disconnected());
      _scheduleReconnect();
    }
  }

  Future<String> _fetchTicket() async {
    final response = await _client().get(
      _uri('/wsticket'),
      headers: {'Cookie': sessionCookie!},
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 401) {
      throw StateError('Session expired or revoked - re-pair with the device');
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

      _statusController.add(VideoPlayerStatus(
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
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _channel?.sink.close();
    _channel = null;
    _statusController.add(const VideoPlayerStatus.disconnected());
  }

  void dispose() {
    stopSync();
    _httpClient?.close();
    _statusController.close();
  }
}
