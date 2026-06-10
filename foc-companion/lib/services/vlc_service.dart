import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/video_player_status.dart';

final _log = AppLogger.instance;

class VlcService {
  String _ip = "127.0.0.1";
  int _port = 8080;
  String _password = "";
  
  Timer? _pollingTimer;
  final _statusController = StreamController<VideoPlayerStatus>.broadcast();

  Stream<VideoPlayerStatus> get statusStream => _statusController.stream;

  void configure(String ip, int port, String password) {
    _ip = ip;
    _port = port;
    _password = password;
  }

  Future<void> startPolling() async {
    stopPolling();
    _log.i("VlcService: Starting polling $_ip:$_port");
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      _pollStatus();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _statusController.add(const VideoPlayerStatus.disconnected());
  }

  void dispose() {
    stopPolling();
    _statusController.close();
  }

  Future<void> _pollStatus() async {
    try {
      final uri = Uri.parse('http://$_ip:$_port/requests/status.xml');
      final basicAuth = 'Basic ${base64Encode(utf8.encode(':$_password'))}';

      final response = await http.get(uri, headers: {
        'Authorization': basicAuth,
      }).timeout(const Duration(milliseconds: 1000));

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final root = document.findElements('root').firstOrNull;
        
        if (root == null) throw Exception("Invalid VLC status.xml");

        final stateStr = root.findElements('state').firstOrNull?.innerText;
        final timeStr = root.findElements('time').firstOrNull?.innerText;
        
        // Find filename from information category -> meta -> filename
        String? filename;
        final information = root.findElements('information').firstOrNull;
        if (information != null) {
          final categories = information.findElements('category');
          for (final cat in categories) {
            if (cat.getAttribute('name') == 'meta') {
              final infos = cat.findElements('info');
              for (final info in infos) {
                if (info.getAttribute('name') == 'filename') {
                  filename = info.innerText;
                  break;
                }
              }
            }
          }
        }

        final isPlaying = stateStr == "playing";
        final currentTimeMs = (double.tryParse(timeStr ?? '0') ?? 0.0) * 1000.0;

        _statusController.add(VideoPlayerStatus(
          connected: true,
          isPlaying: isPlaying,
          currentTimeMs: currentTimeMs,
          filePath: filename,
        ));
      } else {
        _log.w("VlcService: HTTP ${response.statusCode}");
        _statusController.add(const VideoPlayerStatus.disconnected());
      }
    } catch (e) {
      _statusController.add(const VideoPlayerStatus.disconnected());
    }
  }
}
