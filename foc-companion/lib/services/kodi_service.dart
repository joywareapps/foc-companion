import 'dart:async';
import 'dart:convert';

import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/video_player_status.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final _log = AppLogger.instance;

const _GET_PLAYERS = 'get_players';
const _GET_FILE = 'get_file';
const _GET_TIME = 'get_time';

class KodiService {
  String _ip = '';
  int _port = 9090;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _pollTimer;
  Timer? _reconnectTimer;

  int? _playerId;
  String? _currentFile;
  bool _disposed = false;

  final StreamController<VideoPlayerStatus> _statusController =
      StreamController<VideoPlayerStatus>.broadcast();
  Stream<VideoPlayerStatus> get statusStream => _statusController.stream;

  void configure(String ip, int port) {
    _ip = ip;
    _port = port;
  }

  Future<void> startPolling() async {
    _disposed = false;
    _connect();

    _reconnectTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_disposed && _channel == null) {
        _connect();
      }
    });
  }

  void _connect() {
    if (_ip.isEmpty) return;
    try {
      final uri = Uri.parse('ws://$_ip:$_port/jsonrpc');
      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          _log.e('KodiService: WebSocket error', error: e);
          _onDisconnected();
        },
        onDone: () {
          _log.w('KodiService: WebSocket closed');
          _onDisconnected();
        },
      );

      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());

      // Immediate first poll
      _poll();
      _log.i('KodiService: connected to $_ip:$_port');
    } catch (e) {
      _log.e('KodiService: connect failed', error: e);
      _channel = null;
    }
  }

  void _onDisconnected() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _sub?.cancel();
    _sub = null;
    _channel = null;
    _playerId = null;
    _currentFile = null;
    if (!_disposed) {
      _statusController.add(const VideoPlayerStatus.disconnected());
    }
  }

  void _poll() {
    if (_channel == null) return;
    if (_playerId == null) {
      _send({'jsonrpc': '2.0', 'method': 'Player.GetActivePlayers', 'id': _GET_PLAYERS});
    } else {
      _send({
        'jsonrpc': '2.0',
        'method': 'Player.GetItem',
        'params': {'properties': ['file', 'title'], 'playerid': _playerId},
        'id': _GET_FILE,
      });
      _send({
        'jsonrpc': '2.0',
        'method': 'Player.GetProperties',
        'params': {'properties': ['time', 'totaltime', 'speed'], 'playerid': _playerId},
        'id': _GET_TIME,
      });
    }
  }

  void _send(Map<String, dynamic> cmd) {
    try {
      _channel?.sink.add(jsonEncode(cmd));
    } catch (e) {
      _log.e('KodiService: send failed', error: e);
    }
  }

  void _onMessage(dynamic raw) {
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (e) {
      return;
    }

    if (msg.containsKey('id')) {
      final id = msg['id'];
      final result = msg['result'];
      if (result == null) return;

      if (id == _GET_PLAYERS) {
        final players = result as List;
        if (players.isNotEmpty) {
          _playerId = players[0]['playerid'] as int;
        } else {
          _playerId = null;
          _currentFile = null;
          _statusController.add(const VideoPlayerStatus(connected: true));
        }
        _poll();
      } else if (id == _GET_FILE) {
        _currentFile = (result['item']?['file'] as String?) ?? '';
        if (_currentFile!.isEmpty) {
          _statusController.add(const VideoPlayerStatus(connected: true));
        }
      } else if (id == _GET_TIME) {
        final speed = (result['speed'] as num?)?.toInt() ?? 0;
        final t = result['time'] as Map<String, dynamic>?;
        final tot = result['totaltime'] as Map<String, dynamic>?;
        if (t == null) return;

        final timeMs = (_hoursMinSecMs(t)) * 1000.0;
        final durationMs = tot != null ? _hoursMinSecMs(tot) * 1000.0 : 0.0;

        if (_currentFile != null && _currentFile!.isNotEmpty) {
          _statusController.add(VideoPlayerStatus(
            connected: true,
            isPlaying: speed != 0,
            currentTimeMs: timeMs,
            durationMs: durationMs,
            filePath: _currentFile,
            playbackSpeed: speed.abs().toDouble().clamp(0.25, 4.0),
          ));
        }
      }
    } else if (msg.containsKey('method')) {
      final method = msg['method'] as String;
      switch (method) {
        case 'Player.OnPlay':
        case 'Player.OnResume':
        case 'Player.OnPause':
        case 'Player.OnSeek':
          // Fast response: re-poll immediately
          _playerId ??= _extractPlayerId(msg);
          _poll();
          break;
        case 'Player.OnStop':
          _playerId = null;
          _currentFile = null;
          _statusController.add(const VideoPlayerStatus(connected: true));
          break;
      }
    }
  }

  double _hoursMinSecMs(Map<String, dynamic> t) {
    return (t['hours'] as num).toDouble() * 3600 +
        (t['minutes'] as num).toDouble() * 60 +
        (t['seconds'] as num).toDouble() +
        (t['milliseconds'] as num).toDouble() / 1000.0;
  }

  int? _extractPlayerId(Map<String, dynamic> msg) {
    try {
      return msg['params']?['data']?['player']?['playerid'] as int?;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
    _statusController.close();
  }
}
