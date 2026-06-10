import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/video_player_status.dart';

final _log = AppLogger.instance;

class HereSphereStatus {
  final String identifier;
  final String path;
  final double currentTime;
  final double playbackSpeed;
  final int playerState; // 0 = playing

  HereSphereStatus({
    required this.identifier,
    required this.path,
    required this.currentTime,
    required this.playbackSpeed,
    required this.playerState,
  });

  factory HereSphereStatus.fromJson(Map<String, dynamic> json) {
    return HereSphereStatus(
      identifier: json['identifier'] ?? '',
      path: json['path'] ?? '',
      currentTime: (json['currentTime'] ?? 0.0).toDouble(),
      playbackSpeed: (json['playbackSpeed'] ?? 1.0).toDouble(),
      playerState: json['playerState'] ?? 1,
    );
  }
}

class HereSphereService {
  Socket? _socket;
  Timer? _keepAliveTimer;
  String _ip = '';
  int _port = 23554;

  final StreamController<HereSphereStatus> _statusController =
      StreamController<HereSphereStatus>.broadcast();
  Stream<HereSphereStatus> get statusStream => _statusController.stream;

  /// Internal buffer for TCP stream processing
  final List<int> _receiveBuffer = [];

  /// Convenience stream that maps HereSphereStatus → VideoPlayerStatus.
  Stream<VideoPlayerStatus> get videoPlayerStatusStream =>
      statusStream.map((s) => VideoPlayerStatus(
            connected: true,
            isPlaying: s.playerState == 0,
            currentTimeMs: s.currentTime * 1000,
            durationMs: 0, 
            filePath: s.path,
            playbackSpeed: s.playbackSpeed,
          ));

  void configure(String ip, int port) {
    _ip = ip;
    _port = port;
  }

  Future<void> connect() async {
    if (_ip.isEmpty) throw Exception("IP not configured");

    try {
      _socket = await Socket.connect(_ip, _port, timeout: const Duration(seconds: 5));
      _receiveBuffer.clear();
      
      _socket!.listen(
        _onData,
        onError: (e) {
          _log.e("HereSphere socket error", error: e);
          disconnect();
        },
        onDone: () => disconnect(),
      );

      _startKeepAlive();
      _log.i("Connected to HereSphere at $_ip:$_port");
    } catch (e) {
      throw Exception("Failed to connect to HereSphere: $e");
    }
  }

  void disconnect() {
    _keepAliveTimer?.cancel();
    _socket?.destroy();
    _socket = null;
    _receiveBuffer.clear();
  }

  void _onData(Uint8List data) {
    _receiveBuffer.addAll(data);

    while (_receiveBuffer.length >= 4) {
      // 1. Read header (4 bytes, little-endian length)
      final length = ByteData.sublistView(Uint8List.fromList(_receiveBuffer.sublist(0, 4)))
          .getUint32(0, Endian.little);

      if (length == 0) {
        // Keep-alive/Heartbeat
        _receiveBuffer.removeRange(0, 4);
        continue;
      }

      // 2. Check if entire message has arrived
      if (_receiveBuffer.length < 4 + length) {
        break; // Wait for more data
      }

      // 3. Extract and parse JSON
      final jsonBytes = _receiveBuffer.sublist(4, 4 + length);
      _receiveBuffer.removeRange(0, 4 + length);

      try {
        final jsonStr = utf8.decode(jsonBytes);
        final status = HereSphereStatus.fromJson(jsonDecode(jsonStr));
        _statusController.add(status);
      } catch (e) {
        _log.e("HereSphere parse error", error: e);
      }
    }
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_socket != null) {
        _socket!.add([0, 0, 0, 0]); // 4 null bytes heartbeat
      }
    });
  }

  void dispose() {
    disconnect();
    _statusController.close();
  }
}
