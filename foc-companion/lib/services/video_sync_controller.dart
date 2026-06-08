import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/funscript_playback_controller.dart';
import 'package:foc_companion/services/heresphere_service.dart';
import 'package:foc_companion/services/mpc_hc_service.dart';
import 'package:foc_companion/services/video_player_status.dart';

final _log = AppLogger.instance;

/// Sync state for the video ↔ funscript link.
enum SyncState { idle, syncing, exceeded, error }

/// Orchestrates the link between a video player backend and the funscript
/// playback controller.
///
/// The video player is always the **time master**: on every status update the
/// funscript controller seeks to the video's current timestamp. When the video
/// pauses, the funscript pauses. When the video exceeds the funscript duration,
/// the funscript holds its last value instead of stopping.
class VideoSyncController extends ChangeNotifier {
  final FunscriptPlaybackController _funscriptController;

  HereSphereService? _heresphereService;
  MpcHcService? _mpcHcService;
  StreamSubscription<VideoPlayerStatus>? _statusSubscription;

  SyncState _syncState = SyncState.idle;
  VideoPlayerStatus _playerStatus = const VideoPlayerStatus.disconnected();
  bool _isLinked = false;
  VideoPlayerType _linkedPlayer = VideoPlayerType.none;

  // ── Public getters ────────────────────────────────────────

  SyncState get syncState => _syncState;
  VideoPlayerStatus get playerStatus => _playerStatus;
  bool get isLinked => _isLinked;
  VideoPlayerType get linkedPlayer => _linkedPlayer;

  /// True when the video is playing beyond the funscript's total duration.
  bool get isVideoBeyondScript =>
      _playerStatus.connected &&
      _playerStatus.currentTimeMs > _funscriptController.durationMs;

  VideoSyncController({required FunscriptPlaybackController funscriptController})
      : _funscriptController = funscriptController;

  /// Connect to [player] and start receiving timestamps.
  ///
  /// Call [unlink] to disconnect.
  Future<void> link(VideoPlayerType player, {
    required String heresphereIp,
    required int herespherePort,
    required String mpcHcIp,
    required int mpcHcPort,
  }) async {
    if (_isLinked) {
      _log.w('VideoSyncController: already linked to $_linkedPlayer, unlinking first');
      unlink();
    }

    _log.i('VideoSyncController: linking to $player');
    _linkedPlayer = player;

    try {
      switch (player) {
        case VideoPlayerType.heresphere:
          _heresphereService = HereSphereService();
          _heresphereService!.configure(heresphereIp, herespherePort);
          await _heresphereService!.connect();
          _statusSubscription = _heresphereService!.statusStream
              .map((s) => VideoPlayerStatus(
                    connected: true,
                    isPlaying: s.playerState == 0,
                    currentTimeMs: s.currentTime,
                    durationMs: 0, // HereSphere doesn't report video duration
                    filePath: s.path,
                    playbackSpeed: s.playbackSpeed,
                  ))
              .listen(_onPlayerStatus);
          break;

        case VideoPlayerType.mpcHc:
          _mpcHcService = MpcHcService(ip: mpcHcIp, port: mpcHcPort);
          _statusSubscription =
              _mpcHcService!.statusStream.listen(_onPlayerStatus);
          await _mpcHcService!.startPolling();
          break;

        case VideoPlayerType.none:
          _log.w('VideoSyncController: cannot link to VideoPlayerType.none');
          return;
      }

      _isLinked = true;
      _syncState = SyncState.idle;
      notifyListeners();
      _log.i('VideoSyncController: linked to $player');
    } catch (e) {
      _log.e('VideoSyncController: failed to link to $player', error: e);
      _syncState = SyncState.error;
      _isLinked = false;
      _cleanupServices();
      notifyListeners();
    }
  }

  /// Disconnect from the video player. The funscript controller resumes its
  /// own internal clock.
  void unlink() {
    if (!_isLinked) return;
    _log.i('VideoSyncController: unlinking from $_linkedPlayer');

    _statusSubscription?.cancel();
    _statusSubscription = null;
    _cleanupServices();

    _isLinked = false;
    _linkedPlayer = VideoPlayerType.none;
    _syncState = SyncState.idle;
    _playerStatus = const VideoPlayerStatus.disconnected();
    notifyListeners();
  }

  // ── Internal ───────────────────────────────────────────────

  void _cleanupServices() {
    _heresphereService?.dispose();
    _heresphereService = null;
    _mpcHcService?.dispose();
    _mpcHcService = null;
  }

  void _onPlayerStatus(VideoPlayerStatus status) {
    _playerStatus = status;

    final scriptDurationMs = _funscriptController.durationMs.toDouble();

    // 1. Disconnected
    if (!status.connected) {
      _syncState = SyncState.error;
      notifyListeners();
      return;
    }

    // 2. Video paused → pause funscript
    if (!status.isPlaying) {
      if (_funscriptController.state == PlaybackState.playing) {
        _funscriptController.pause();
      }
      _syncState = scriptDurationMs > 0 &&
              status.currentTimeMs >= scriptDurationMs
          ? SyncState.exceeded
          : SyncState.idle;
      notifyListeners();
      return;
    }

    // 3. Video beyond funscript duration
    if (scriptDurationMs > 0 && status.currentTimeMs > scriptDurationMs) {
      _syncState = SyncState.exceeded;
      // Hold last position — seek to end but don't stop
      if (_funscriptController.positionMs != scriptDurationMs.toInt()) {
        _funscriptController.seek(scriptDurationMs.toInt());
      }
      // Pause so output stays at last value
      if (_funscriptController.state == PlaybackState.playing) {
        _funscriptController.pause();
      }
      notifyListeners();
      return;
    }

    // 4. Within range — sync
    _syncState = SyncState.syncing;
    _funscriptController.seek(status.currentTimeMs.toInt());
    if (_funscriptController.state != PlaybackState.playing) {
      _funscriptController.play();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unlink();
    super.dispose();
  }
}
