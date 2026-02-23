import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  void configure(String ip, int port) {
    _ip = ip;
    _port = port;
  }

  Future<void> connect() async {
    if (_ip.isEmpty) throw Exception("IP not configured");

    try {
      _socket = await Socket.connect(_ip, _port, timeout: const Duration(seconds: 5));
      
      _socket!.listen(
        _onData,
        onError: (e) => disconnect(),
        onDone: () => disconnect(),
      );

      _startKeepAlive();
    } catch (e) {
      throw Exception("Failed to connect to HereSphere: $e");
    }
  }

  void disconnect() {
    _keepAliveTimer?.cancel();
    _socket?.close();
    _socket = null;
  }

  void _onData(Uint8List data) {
    // Protocol: 4-byte length header (little-endian) + JSON payload
    // Basic implementation for prototype:
    if (data.length < 4) return;

    final length = ByteData.sublistView(data, 0, 4).getUint32(0, Endian.little);
    if (length == 0) return; // Keep-alive

    if (data.length >= 4 + length) {
      final jsonBytes = data.sublist(4, 4 + length);
      final jsonStr = utf8.decode(jsonBytes);
      try {
        final status = HereSphereStatus.fromJson(jsonDecode(jsonStr));
        _statusController.add(status);
      } catch (e) {
        print("HereSphere JSON error: $e");
      }
    }
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_socket != null) {
        _socket!.add([0, 0, 0, 0]); // 4 null bytes
      }
    });
  }

  void dispose() {
    disconnect();
    _statusController.close();
  }
}
