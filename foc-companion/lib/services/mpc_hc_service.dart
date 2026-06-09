import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:foc_companion/services/app_logger.dart';

class MpcHcStatus {
  final String filename;
  final int positionMs;
  final int durationMs;
  final int state; // 0=stopped, 1=paused, 2=playing

  MpcHcStatus({
    required this.filename,
    required this.positionMs,
    required this.durationMs,
    required this.state,
  });
}

class MpcHcService {
  Timer? _pollTimer;
  String _ip = '';
  int _port = 13579;
  final HttpClient _client = HttpClient()..connectionTimeout = const Duration(seconds: 2);

  final StreamController<MpcHcStatus> _statusController =
      StreamController<MpcHcStatus>.broadcast();
  Stream<MpcHcStatus> get statusStream => _statusController.stream;

  void configure(String ip, int port) {
    _ip = ip;
    _port = port;
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) => _poll());
    _poll(); // Immediate first poll
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll() async {
    if (_ip.isEmpty) return;
    try {
      final uri = Uri.parse('http://$_ip:$_port/variables.html');
      final request = await _client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(const Utf8Decoder()).join();
        
        final fullPath = _extract(body, 'filepath') ?? '';
        String filename = fullPath.split('/').last.split('\\').last;
        if (filename.contains('.')) {
          filename = filename.substring(0, filename.lastIndexOf('.'));
        }
        final position = int.tryParse(_extract(body, 'position') ?? '0') ?? 0;
        final duration = int.tryParse(_extract(body, 'duration') ?? '0') ?? 0;
        final state = int.tryParse(_extract(body, 'state') ?? '0') ?? 0;

        _statusController.add(MpcHcStatus(
          filename: filename ?? '',
          positionMs: position,
          durationMs: duration,
          state: state,
        ));
      }
    } catch (e) {
      // Quietly ignore polling errors to avoid log spam
    }
  }

  String? _extract(String body, String id) {
    // Simple regex for <p id="id">value</p>
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
