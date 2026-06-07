import 'package:flutter/foundation.dart';

import 'package:foc_companion/models/funscript_bundle.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/funscript_parser.dart';

/// Playback transport state.
enum PlaybackState { stopped, playing, paused }

/// Transport controller for funscript playback.
///
/// Called by the CommandLoop tick (~30Hz) to advance position
/// and compute current axis values.
class FunscriptPlaybackController extends ChangeNotifier {
  FunscriptBundle? _bundle;
  PlaybackState _state = PlaybackState.stopped;
  int _positionMs = 0;
  int _lastTickMs = 0;
  bool _loop = false;

  /// Per-axis current normalized values (0.0–1.0).
  final Map<String, double> _currentValues = {};

  PlaybackState get state => _state;
  int get positionMs => _positionMs;
  int get durationMs => _bundle?.durationMs ?? 0;
  double get progress => durationMs > 0 ? _positionMs / durationMs : 0.0;
  FunscriptBundle? get bundle => _bundle;
  bool get loop => _loop;
  Map<String, double> get currentValues => Map.unmodifiable(_currentValues);

  /// Load a bundle for playback and reset position.
  void load(FunscriptBundle bundle) {
    _bundle = bundle;
    _positionMs = 0;
    _lastTickMs = 0;
    _currentValues.clear();
    _state = PlaybackState.stopped;
    notifyListeners();
    AppLogger.instance.i('FunscriptPlaybackController: loaded "${bundle.name}" (${bundle.durationMs}ms)');
  }

  /// Start playback from current position.
  void play() {
    if (_bundle == null) return;
    _state = PlaybackState.playing;
    _lastTickMs = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
    AppLogger.instance.d('FunscriptPlaybackController: play at ${_positionMs}ms');
  }

  /// Pause playback (freeze position, keep last values).
  void pause() {
    _state = PlaybackState.paused;
    notifyListeners();
    AppLogger.instance.d('FunscriptPlaybackController: paused at ${_positionMs}ms');
  }

  /// Stop playback and reset position to 0.
  void stop() {
    _state = PlaybackState.stopped;
    _positionMs = 0;
    _lastTickMs = 0;
    _currentValues.clear();
    notifyListeners();
    AppLogger.instance.d('FunscriptPlaybackController: stopped');
  }

  /// Seek to absolute position in ms.
  void seek(int ms) {
    _positionMs = ms.clamp(0, durationMs);
    _lastTickMs = 0; // reset delta tracking
    notifyListeners();
  }

  /// Toggle loop mode.
  void setLoop(bool value) {
    _loop = value;
    notifyListeners();
  }

  /// Called by CommandLoop each tick (~30Hz).
  /// Updates internal clock, computes all axis values.
  /// Returns true if playback is active.
  bool tick() {
    if (_state != PlaybackState.playing || _bundle == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastTickMs == 0) _lastTickMs = now;
    _positionMs += (now - _lastTickMs);
    _lastTickMs = now;

    // Handle end-of-file
    if (_positionMs >= durationMs) {
      if (_loop) {
        _positionMs %= durationMs;
      } else {
        _state = PlaybackState.stopped;
        _positionMs = durationMs;
        notifyListeners();
        return false;
      }
    }

    // Update all axis values
    _currentValues.clear();
    for (final entry in _bundle!.axes.entries) {
      _currentValues[entry.key] =
          FunscriptParser.getValueAt(entry.value, _positionMs);
    }

    notifyListeners();
    return true;
  }

  /// Get current normalized value for a specific axis (0.0–1.0).
  /// Returns null if axis not available.
  double? getValue(String axisSuffix) {
    return _currentValues[axisSuffix];
  }

  /// Get device-ready value for an axis, mapped to [min]–[max] range.
  /// Returns null if axis not available.
  double? getDeviceValue(String axisSuffix,
      {double min = 0.0, double max = 1.0}) {
    final normalized = _currentValues[axisSuffix];
    if (normalized == null) return null;
    return min + normalized * (max - min);
  }
}
