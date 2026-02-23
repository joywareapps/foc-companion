import 'dart:async';
import 'package:foc_companion/services/focstim_api_service.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/core/patterns.dart';
import 'package:foc_companion/core/modulation.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/generated/protobuf/constants.pbenum.dart';
import 'package:foc_companion/generated/protobuf/focstim_rpc.pb.dart';
import 'package:foc_companion/generated/protobuf/messages.pb.dart';

// Tick requests use a shorter timeout than setup requests so congestion is
// detected quickly. 2 s gives a couple of WiFi retransmit attempts before
// we declare the link dead.
const _kTickTimeout = Duration(seconds: 2);
const _kTickInterval = Duration(milliseconds: 33); // 30 Hz

// How many consecutive skipped ticks (each 33 ms) before we flag the
// connection as slow. 3 ticks ≈ 100 ms behind — clearly not keeping 30 Hz.
const _kSlowThreshold = 3;

// ─────────────────────────────────────────────────────────
// 4-Phase command loop
// ─────────────────────────────────────────────────────────

class FourPhaseCommandLoop {
  final FocStimApiService _api;
  final SettingsProvider _settings;

  /// Active pattern — swappable while running.
  FourphasePattern pattern = FourphasePatternRegistry.all[0];

  /// Playback speed multiplier (applied to dt fed into the pattern).
  double velocity = 1.0;

  /// Volume (0–1). Sent to device as: volume² × maxAmp (matching desktop
  /// fourphase_algorithm: AXIS_WAVEFORM_AMPLITUDE_AMPS = volume² × maxAmp).
  double volume = 1.0;

  /// Called with `true` when ticks are being skipped (connection slow),
  /// `false` when throughput recovers.
  void Function(bool)? onSlowConnection;

  /// Called when a tick request times out. Loop is already stopped.
  void Function(String)? onTimeout;

  final Modulator _pulseFreqMod = Modulator(PulseModulationConfig());

  Timer? _timer;
  bool _isRunning = false;
  bool _tickInFlight = false; // true while awaiting current tick's responses
  int _slowCount = 0;         // consecutive skipped ticks
  double _startTime = 0;
  final Map<int, double> _lastSent = {}; // last transmitted value per axis key
  double _lastSyncWallTime = 0.0;        // wall time of last forced full sync

  FourPhaseCommandLoop(this._api, this._settings);

  void setPulseModConfig(PulseModulationConfig config) {
    _pulseFreqMod.config = config;
  }

  Future<void> start() async {
    if (_isRunning) return;
    print("FourPhaseCommandLoop: Starting...");

    // Reset stale state from any previous session.
    _tickInFlight = false;
    _slowCount = 0;
    _lastSent.clear();
    _lastSyncWallTime = 0.0; // ensures first tick sends all axes

    pattern.reset();
    _pulseFreqMod.reset();

    try {
      await _setupParams();
      print("FourPhaseCommandLoop: Params setup complete. Starting signal...");
      await _api.startSignal(mode: OutputMode.OUTPUT_FOURPHASE_INDIVIDUAL_ELECTRODES);
      print("FourPhaseCommandLoop: Signal started.");
      _isRunning = true;
      _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _timer = Timer.periodic(_kTickInterval, _tick);
    } catch (e) {
      print("FourPhaseCommandLoop: Error starting: $e");
      _isRunning = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    print("FourPhaseCommandLoop: Stopping...");
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    try {
      await _api.stopSignal();
    } catch (e) {
      print("FourPhaseCommandLoop: Error stopping signal: $e");
    }
    print("FourPhaseCommandLoop: Stopped.");
  }

  void _tick(Timer _) async {
    if (!_api.isConnected || !_isRunning) return;

    // ── Backpressure: skip if previous tick not yet acknowledged ──
    if (_tickInFlight) {
      _slowCount++;
      if (_slowCount == _kSlowThreshold) onSlowConnection?.call(true);
      return;
    }
    _tickInFlight = true;

    const double dt = 0.033;
    final double now = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // Force a full re-sync every ~1 s to recover from any dropped packets.
    final bool forceSync = (now - _lastSyncWallTime) >= 1.0;

    final pos = pattern.update(dt * velocity);

    final double elapsed = now - _startTime;
    final double ramp = (elapsed / 5.0).clamp(0.0, 1.0);
    final double currentAmp =
        volume * volume * _settings.device.waveformAmplitude * ramp;

    final freqOffset = _pulseFreqMod.update(dt, velocity);
    final modFreq =
        (_settings.pulse.pulseFrequency + freqOffset).clamp(1.0, 300.0);

    // Collect futures for changed axes only (or all axes on full sync).
    final futs = <Future<Response>>[];
    void send(AxisType axis, double value) {
      final key = axis.value;
      if (!forceSync && _lastSent[key] == value) return; // unchanged — skip
      _lastSent[key] = value;
      futs.add(_api.sendRequest(
        Request()
          ..requestAxisMoveTo = (RequestAxisMoveTo()
            ..axis = axis
            ..value = value
            ..interval = 50),
        timeout: _kTickTimeout,
      ));
    }

    // Position axes always change (continuous motion).
    send(AxisType.AXIS_ELECTRODE_1_POWER, pos.a);
    send(AxisType.AXIS_ELECTRODE_2_POWER, pos.b);
    send(AxisType.AXIS_ELECTRODE_3_POWER, pos.c);
    send(AxisType.AXIS_ELECTRODE_4_POWER, pos.d);
    // Settings — delta-sent; only transmitted when value changes or on full sync.
    send(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, currentAmp);
    send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, _settings.pulse.carrierFrequency);
    send(AxisType.AXIS_PULSE_FREQUENCY_HZ, modFreq);
    send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, _settings.pulse.pulseWidth);
    send(AxisType.AXIS_PULSE_RISE_TIME_CYCLES, _settings.pulse.pulseRiseTime);
    send(AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT,
        _settings.pulse.pulseIntervalRandom / 100.0);
    send(AxisType.AXIS_CALIBRATION_4_CENTER, _settings.device.calibration4Center);
    send(AxisType.AXIS_CALIBRATION_4_A, _settings.device.calibration4A);
    send(AxisType.AXIS_CALIBRATION_4_B, _settings.device.calibration4B);
    send(AxisType.AXIS_CALIBRATION_4_C, _settings.device.calibration4C);
    send(AxisType.AXIS_CALIBRATION_4_D, _settings.device.calibration4D);

    try {
      // eagerError: false — wait for all futures so their exceptions are
      // consumed rather than becoming unhandled async errors.
      await Future.wait(futs, eagerError: false);
      if (forceSync) _lastSyncWallTime = now;
      if (_slowCount >= _kSlowThreshold) onSlowConnection?.call(false);
      _slowCount = 0;
    } on TimeoutException {
      _timer?.cancel();
      _timer = null;
      _isRunning = false;
      onTimeout?.call("Request timed out — connection lost");
    } catch (e) {
      print("4-phase loop error: $e");
    } finally {
      _tickInFlight = false;
    }
  }

  Future<void> _setupParams() async {
    print("FourPhaseCommandLoop: Setting up params...");
    Future<void> send(AxisType axis, double val) async {
      await _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = axis
          ..value = val
          ..interval = 0));
    }

    var p = _settings.pulse;
    var d = _settings.device;

    await send(AxisType.AXIS_ELECTRODE_1_POWER, 0);
    await send(AxisType.AXIS_ELECTRODE_2_POWER, 0);
    await send(AxisType.AXIS_ELECTRODE_3_POWER, 0);
    await send(AxisType.AXIS_ELECTRODE_4_POWER, 0);
    await send(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, 0);
    await send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, p.carrierFrequency);
    await send(AxisType.AXIS_PULSE_FREQUENCY_HZ, p.pulseFrequency);
    await send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, p.pulseWidth);
    await send(AxisType.AXIS_PULSE_RISE_TIME_CYCLES, p.pulseRiseTime);
    await send(AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT,
        p.pulseIntervalRandom / 100.0);
    await send(AxisType.AXIS_CALIBRATION_4_CENTER, d.calibration4Center);
    await send(AxisType.AXIS_CALIBRATION_4_A, d.calibration4A);
    await send(AxisType.AXIS_CALIBRATION_4_B, d.calibration4B);
    await send(AxisType.AXIS_CALIBRATION_4_C, d.calibration4C);
    await send(AxisType.AXIS_CALIBRATION_4_D, d.calibration4D);
  }
}

// ─────────────────────────────────────────────────────────
// 3-Phase command loop
// ─────────────────────────────────────────────────────────

class CommandLoop {
  final FocStimApiService _api;
  final SettingsProvider _settings;

  /// Active pattern — can be swapped while running.
  ThreephasePattern pattern = CirclePattern();

  /// Playback speed multiplier (applied to dt fed into the pattern).
  double velocity = 1.0;

  /// Volume (0–1). Sent to device as: volume × maxAmp (matching desktop
  /// threephase_algorithm: AXIS_WAVEFORM_AMPLITUDE_AMPS = volume × maxAmp).
  double volume = 1.0;

  /// Called with `true` when ticks are being skipped (connection slow),
  /// `false` when throughput recovers.
  void Function(bool)? onSlowConnection;

  /// Called when a tick request times out. Loop is already stopped.
  void Function(String)? onTimeout;

  final Modulator _pulseFreqMod = Modulator(PulseModulationConfig());

  Timer? _timer;
  bool _isRunning = false;
  bool _tickInFlight = false; // true while awaiting current tick's responses
  int _slowCount = 0;         // consecutive skipped ticks
  double _startTime = 0;
  final Map<int, double> _lastSent = {}; // last transmitted value per axis key
  double _lastSyncWallTime = 0.0;        // wall time of last forced full sync

  CommandLoop(this._api, this._settings);

  void setPulseModConfig(PulseModulationConfig config) {
    _pulseFreqMod.config = config;
  }

  Future<void> start() async {
    if (_isRunning) return;
    print("CommandLoop: Starting...");

    // Reset stale state from any previous session.
    _tickInFlight = false;
    _slowCount = 0;
    _lastSent.clear();
    _lastSyncWallTime = 0.0; // ensures first tick sends all axes

    pattern.reset();
    _pulseFreqMod.reset();

    try {
      await _setupParams();
      print("CommandLoop: Params setup complete. Starting signal...");
      await _api.startSignal();
      print("CommandLoop: Signal started.");

      _isRunning = true;
      _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _timer = Timer.periodic(_kTickInterval, _tick);
    } catch (e) {
      print("CommandLoop: Error starting: $e");
      _isRunning = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    print("CommandLoop: Stopping...");
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    try {
      await _api.stopSignal();
    } catch (e) {
      print("CommandLoop: Error stopping signal: $e");
    }
    print("CommandLoop: Stopped.");
  }

  void _tick(Timer _) async {
    if (!_api.isConnected || !_isRunning) return;

    // ── Backpressure: skip if previous tick not yet acknowledged ──
    if (_tickInFlight) {
      _slowCount++;
      if (_slowCount == _kSlowThreshold) onSlowConnection?.call(true);
      return;
    }
    _tickInFlight = true;

    const double dt = 0.033;
    final double now = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // Force a full re-sync every ~1 s to recover from any dropped packets.
    final bool forceSync = (now - _lastSyncWallTime) >= 1.0;

    final pos = pattern.update(dt * velocity);

    final double elapsed = now - _startTime;
    final double ramp = (elapsed / 5.0).clamp(0.0, 1.0);
    final double currentAmp =
        volume * _settings.device.waveformAmplitude * ramp;

    final freqOffset = _pulseFreqMod.update(dt, velocity);
    final modFreq =
        (_settings.pulse.pulseFrequency + freqOffset).clamp(1.0, 300.0);

    // Collect futures for changed axes only (or all axes on full sync).
    final futs = <Future<Response>>[];
    void send(AxisType axis, double value) {
      final key = axis.value;
      if (!forceSync && _lastSent[key] == value) return; // unchanged — skip
      _lastSent[key] = value;
      futs.add(_api.sendRequest(
        Request()
          ..requestAxisMoveTo = (RequestAxisMoveTo()
            ..axis = axis
            ..value = value
            ..interval = 50),
        timeout: _kTickTimeout,
      ));
    }

    // Position axes always change (continuous motion).
    send(AxisType.AXIS_POSITION_ALPHA, pos.x);
    send(AxisType.AXIS_POSITION_BETA, pos.y);
    // Settings — delta-sent; only transmitted when value changes or on full sync.
    send(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, currentAmp);
    send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, _settings.pulse.carrierFrequency);
    send(AxisType.AXIS_PULSE_FREQUENCY_HZ, modFreq);
    send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, _settings.pulse.pulseWidth);
    send(AxisType.AXIS_PULSE_RISE_TIME_CYCLES, _settings.pulse.pulseRiseTime);
    send(AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT,
        _settings.pulse.pulseIntervalRandom / 100.0);
    send(AxisType.AXIS_CALIBRATION_3_CENTER, _settings.device.calibration3Center);
    send(AxisType.AXIS_CALIBRATION_3_UP, _settings.device.calibration3Up);
    send(AxisType.AXIS_CALIBRATION_3_LEFT, _settings.device.calibration3Left);

    try {
      await Future.wait(futs, eagerError: false);
      if (forceSync) _lastSyncWallTime = now;
      if (_slowCount >= _kSlowThreshold) onSlowConnection?.call(false);
      _slowCount = 0;
    } on TimeoutException {
      _timer?.cancel();
      _timer = null;
      _isRunning = false;
      onTimeout?.call("Request timed out — connection lost");
    } catch (e) {
      print("Loop error: $e");
    } finally {
      _tickInFlight = false;
    }
  }

  Future<void> _setupParams() async {
    print("CommandLoop: Setting up params...");
    Future<void> send(AxisType axis, double val) async {
      print("CommandLoop: Sending $axis = $val");
      await _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = axis
          ..value = val
          ..interval = 0));
    }

    var p = _settings.pulse;
    var d = _settings.device;

    await send(AxisType.AXIS_POSITION_ALPHA, 0);
    await send(AxisType.AXIS_POSITION_BETA, 0);
    await send(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, 0);
    await send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, p.carrierFrequency);
    await send(AxisType.AXIS_PULSE_FREQUENCY_HZ, p.pulseFrequency);
    await send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, p.pulseWidth);
    await send(AxisType.AXIS_PULSE_RISE_TIME_CYCLES, p.pulseRiseTime);
    await send(AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT,
        p.pulseIntervalRandom / 100.0);
    await send(AxisType.AXIS_CALIBRATION_3_CENTER, d.calibration3Center);
    await send(AxisType.AXIS_CALIBRATION_3_UP, d.calibration3Up);
    await send(AxisType.AXIS_CALIBRATION_3_LEFT, d.calibration3Left);
  }
}
