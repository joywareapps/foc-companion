import 'dart:async';
import 'dart:math' as math;
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/focstim_api_service.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/core/patterns.dart';
import 'package:foc_companion/core/modulation.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/generated/protobuf/constants.pbenum.dart';
import 'package:foc_companion/generated/protobuf/focstim_rpc.pb.dart';
import 'package:foc_companion/generated/protobuf/messages.pb.dart';

final _log = AppLogger.instance;

// Tick requests use a shorter timeout than setup requests so congestion is
// detected quickly. 2 s gives a couple of WiFi retransmit attempts before
// we declare the link dead.
const _kTickTimeout = Duration(seconds: 2);
const _kTickInterval = Duration(milliseconds: 33); // 30 Hz

// How many consecutive skipped ticks (each 33 ms) before we flag the
// connection as slow. 3 ticks ≈ 100 ms behind — clearly not keeping 30 Hz.
const _kSlowThreshold = 3;

// ─────────────────────────────────────────────────────────
// Axis conversion: user-facing 0–1 values → firmware units
// ─────────────────────────────────────────────────────────

/// Converts the three intuitive axes (speed, pulse, texture) to the three
/// firmware parameters (pulse_frequency_hz, pulse_width_cycles,
/// pulse_rise_time_cycles).
///
/// [carrierHz]  AXIS_CARRIER_FREQUENCY_HZ (current value)
/// [speed]      0 = slow (long inter-pulse gap), 1 = fast (short gap)
/// [pulse]      0 = brief wavelet (3 cycles), 1 = sustained (20 cycles)
/// [texture]    0 = sharp onset (min rise), 1 = smooth (max rise)
({double freqHz, double widthCycles, double riseCycles}) pulseFirmwareAxes({
  required double carrierHz,
  required double speed,
  required double pulse,
  required double texture,
}) {
  // 1. Wavelet duration in cycles (3..20) and seconds
  final widthCycles = (3.0 + pulse * 17.0).clamp(3.0, 20.0);
  final waveletSeconds = widthCycles / carrierHz;

  // 2. Inter-pulse gap: 0.5 s (slow) → 0.005 s (fast), logarithmic
  //    gap = 0.5 × (0.01)^speed
  final gapSeconds = 0.5 * math.pow(0.01, speed.clamp(0.0, 1.0));
  final freqHz = (1.0 / (waveletSeconds + gapSeconds)).clamp(1.0, 300.0);

  // 3. Rise time: 2 cycles (sharp) → pulse_width/2 cycles (smooth), capped at 10
  final effectiveMaxRise = (widthCycles / 2.0).clamp(2.0, 10.0);
  final riseCycles =
      (2.0 + texture * (effectiveMaxRise - 2.0)).clamp(2.0, 10.0);

  return (freqHz: freqHz, widthCycles: widthCycles, riseCycles: riseCycles);
}

// ─────────────────────────────────────────────────────────
// 4-Phase command loop
// ─────────────────────────────────────────────────────────

class FourPhaseCommandLoop {
  final FocStimApiService _api;
  final SettingsProvider _settings;
  int boxIndex = 0;

  DeviceSettings get _device => _settings.boxes[boxIndex].device;
  PulseSettings get _pulse => _settings.boxes[boxIndex].pulse;

  /// Active pattern — swappable while running.
  FourphasePattern pattern = FourphasePatternRegistry.all[0];

  /// Playback speed multiplier (applied to dt fed into the pattern).
  double velocity = 1.0;

  /// Volume (0–1). Sent to device as: volume × maxAmp.
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
    _log.i("FourPhaseCommandLoop: Starting...");

    // Reset stale state from any previous session.
    _tickInFlight = false;
    _slowCount = 0;
    _lastSent.clear();
    _lastSyncWallTime = 0.0; // ensures first tick sends all axes

    pattern.reset();
    _pulseFreqMod.reset();

    try {
      await _setupParams();
      _log.i("FourPhaseCommandLoop: Params setup complete. Starting signal...");
      await _api.startSignal(mode: OutputMode.OUTPUT_FOURPHASE_INDIVIDUAL_ELECTRODES);
      _log.i("FourPhaseCommandLoop: Signal started.");
      _isRunning = true;
      _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _timer = Timer.periodic(_kTickInterval, _tick);
    } catch (e) {
      _log.e("FourPhaseCommandLoop: Error starting", error: e);
      _isRunning = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    _log.i("FourPhaseCommandLoop: Stopping...");
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    if (_api.isConnected) {
      try {
        await _api.stopSignal();
      } catch (e) {
        _log.e("FourPhaseCommandLoop: Error stopping signal", error: e);
      }
    }
    _log.i("FourPhaseCommandLoop: Stopped.");
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
    final double ramp = (elapsed / 3.0).clamp(0.0, 1.0);
    final double currentAmp =
        volume * _device.waveformAmplitude * ramp;

    final norm = _pulseFreqMod.update(dt, velocity); // [-1,1] when active, 0 when off
    final modCfg = _pulseFreqMod.config;
    final freqModActive = modCfg.mode == 'freq' || modCfg.mode == 'both';
    final widthModActive = modCfg.mode == 'width' || modCfg.mode == 'both';

    // Convert intuitive axes to firmware units.
    final axes = pulseFirmwareAxes(
      carrierHz: _pulse.carrierFrequency,
      speed: _pulse.speed,
      pulse: _pulse.pulse,
      texture: _pulse.texture,
    );

    // Pulse-modulation oscillator overrides freq and/or width when active.
    final modFreq = freqModActive
        ? (modCfg.minHz + (modCfg.maxHz - modCfg.minHz) * (norm + 1) / 2)
            .clamp(1.0, 300.0)
        : axes.freqHz;
    final modWidth = widthModActive
        ? (modCfg.minWidth +
                (modCfg.maxWidth - modCfg.minWidth) *
                    (_pulseFreqMod.valueAtPhaseDeg(
                              modCfg.phaseShiftDeg.toDouble()) +
                          1) /
                    2)
            .clamp(3.0, 15.0)
        : axes.widthCycles;

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
    send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, _pulse.carrierFrequency);
    send(AxisType.AXIS_PULSE_FREQUENCY_HZ, modFreq);
    send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, modWidth);
    send(AxisType.AXIS_PULSE_RISE_TIME_CYCLES, axes.riseCycles);
    send(AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT,
        _pulse.pulseIntervalRandom / 100.0);
    send(AxisType.AXIS_CALIBRATION_4_A, _device.calibration4A);
    send(AxisType.AXIS_CALIBRATION_4_B, _device.calibration4B);
    send(AxisType.AXIS_CALIBRATION_4_C, _device.calibration4C);
    send(AxisType.AXIS_CALIBRATION_4_D, _device.calibration4D);

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
      _log.e("4-phase loop error", error: e);
    } finally {
      _tickInFlight = false;
    }
  }

  Future<void> _setupParams() async {
    _log.d("FourPhaseCommandLoop: Setting up params...");
    Future<void> send(AxisType axis, double val) async {
      await _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = axis
          ..value = val
          ..interval = 0));
    }

    final p = _pulse;
    final d = _device;
    final axes = pulseFirmwareAxes(
      carrierHz: p.carrierFrequency,
      speed: p.speed,
      pulse: p.pulse,
      texture: p.texture,
    );

    await send(AxisType.AXIS_ELECTRODE_1_POWER, 0);
    await send(AxisType.AXIS_ELECTRODE_2_POWER, 0);
    await send(AxisType.AXIS_ELECTRODE_3_POWER, 0);
    await send(AxisType.AXIS_ELECTRODE_4_POWER, 0);
    await send(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, 0);
    await send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, p.carrierFrequency);
    await send(AxisType.AXIS_PULSE_FREQUENCY_HZ, axes.freqHz);
    await send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, axes.widthCycles);
    await send(AxisType.AXIS_PULSE_RISE_TIME_CYCLES, axes.riseCycles);
    await send(AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT,
        p.pulseIntervalRandom / 100.0);
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
  int boxIndex = 0;

  DeviceSettings get _device => _settings.boxes[boxIndex].device;
  PulseSettings get _pulse => _settings.boxes[boxIndex].pulse;

  /// Active pattern — can be swapped while running.
  ThreephasePattern pattern = CirclePattern();

  /// Playback speed multiplier (applied to dt fed into the pattern).
  double velocity = 1.0;

  /// Volume (0–1). Sent to device as: volume × maxAmp (matching desktop
  /// threephase_algorithm: AXIS_WAVEFORM_AMPLITUDE_AMPS = volume × maxAmp).
  double volume = 1.0;

  /// Funscript data source. When not null and active, overrides pattern values.
  /// The CommandLoop reads [funscriptActive] and [funscriptValues] each tick.
  /// Set by the background service when funscript playback is active.
  bool? Function()? isFunscriptActive;
  Map<String, double> Function()? getFunscriptValues;

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
    _log.i("CommandLoop: Starting...");

    // Reset stale state from any previous session.
    _tickInFlight = false;
    _slowCount = 0;
    _lastSent.clear();
    _lastSyncWallTime = 0.0; // ensures first tick sends all axes

    pattern.reset();
    _pulseFreqMod.reset();

    try {
      await _setupParams();
      _log.i("CommandLoop: Params setup complete. Starting signal...");
      await _api.startSignal();
      _log.i("CommandLoop: Signal started.");

      _isRunning = true;
      _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _timer = Timer.periodic(_kTickInterval, _tick);
    } catch (e) {
      _log.e("CommandLoop: Error starting", error: e);
      _isRunning = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    _log.i("CommandLoop: Stopping...");
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    if (_api.isConnected) {
      try {
        await _api.stopSignal();
      } catch (e) {
        _log.e("CommandLoop: Error stopping signal", error: e);
      }
    }
    _log.i("CommandLoop: Stopped.");
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

    // ── Funscript data source (values updated from foreground) ──
    final bool useFunscript = isFunscriptActive?.call() ?? false;
    final Map<String, double> fsValues = useFunscript
        ? (getFunscriptValues?.call() ?? <String, double>{})
        : <String, double>{};

    /// Get normalized funscript value for axis, or null if not available.
    double? fsVal(String axis) => fsValues[axis];

    /// Get device-mapped funscript value, or null.
    double? fsDevice(String axis, {double min = 0.0, double max = 1.0}) {
      final v = fsVal(axis);
      if (v == null) return null;
      return min + v * (max - min);
    }

    final bool hasPosition = fsVal('alpha') != null || fsVal('beta') != null;

    final pos = useFunscript && hasPosition
        ? PatternPosition(
            fsDevice('alpha', min: -1.0, max: 1.0) ?? pattern.update(dt * velocity).x,
            fsDevice('beta', min: -1.0, max: 1.0) ?? pattern.update(dt * velocity).y,
          )
        : pattern.update(dt * velocity);

    final double elapsed = now - _startTime;
    final double ramp = (elapsed / 3.0).clamp(0.0, 1.0);
    final double currentAmp = useFunscript
        ? (fsDevice('volume', min: 0.0, max: 1.0) ?? volume) *
            _device.waveformAmplitude *
            ramp
        : volume * _device.waveformAmplitude * ramp;

    // Convert intuitive axes to firmware units.
    final axes = pulseFirmwareAxes(
      carrierHz: _pulse.carrierFrequency,
      speed: _pulse.speed,
      pulse: _pulse.pulse,
      texture: _pulse.texture,
    );

    // Pulse modulation still applies unless funscript overrides the axis.
    final norm = _pulseFreqMod.update(dt, velocity);
    final modCfg = _pulseFreqMod.config;
    final freqModActive = modCfg.mode == 'freq' || modCfg.mode == 'both';
    final widthModActive = modCfg.mode == 'width' || modCfg.mode == 'both';

    final double freq = useFunscript
        ? (fsDevice('frequency',
                min: _device.minFrequency.toDouble(),
                max: _device.maxFrequency.toDouble()) ??
            _pulse.carrierFrequency)
        : _pulse.carrierFrequency;

    final double modFreq = useFunscript
        ? freq
        : (freqModActive
            ? (modCfg.minHz + (modCfg.maxHz - modCfg.minHz) * (norm + 1) / 2)
                .clamp(1.0, 300.0)
            : axes.freqHz);

    final double modWidth = useFunscript
        ? (fsDevice('pulse_width', min: 3.0, max: 15.0) ?? axes.widthCycles)
        : (widthModActive
            ? (modCfg.minWidth +
                    (modCfg.maxWidth - modCfg.minWidth) *
                        (_pulseFreqMod.valueAtPhaseDeg(
                                  modCfg.phaseShiftDeg.toDouble()) +
                              1) /
                            2)
                .clamp(3.0, 15.0)
            : axes.widthCycles);

    final double pulseRiseTime = useFunscript
        ? (fsDevice('pulse_rise_time', min: 2.0, max: 20.0) ?? axes.riseCycles)
        : axes.riseCycles;

    final double pulseIntervalRandom = useFunscript
        ? (fsDevice('pulse_interval_random', min: 0.0, max: 1.0) ??
            _pulse.pulseIntervalRandom / 100.0)
        : _pulse.pulseIntervalRandom / 100.0;

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
    send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, freq);
    send(AxisType.AXIS_PULSE_FREQUENCY_HZ, modFreq);
    send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, modWidth);
    send(AxisType.AXIS_PULSE_RISE_TIME_CYCLES, pulseRiseTime);
    send(AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT, pulseIntervalRandom);
    send(AxisType.AXIS_CALIBRATION_3_CENTER, _device.calibration3Center);
    send(AxisType.AXIS_CALIBRATION_3_UP, _device.calibration3Up);
    send(AxisType.AXIS_CALIBRATION_3_LEFT, _device.calibration3Left);

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
      _log.e("Loop error", error: e);
    } finally {
      _tickInFlight = false;
    }
  }

  Future<void> _setupParams() async {
    _log.d("CommandLoop: Setting up params...");
    Future<void> send(AxisType axis, double val) async {
      _log.d("CommandLoop: Sending $axis = $val");
      await _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = axis
          ..value = val
          ..interval = 0));
    }

    final p = _pulse;
    final d = _device;
    final axes = pulseFirmwareAxes(
      carrierHz: p.carrierFrequency,
      speed: p.speed,
      pulse: p.pulse,
      texture: p.texture,
    );

    await send(AxisType.AXIS_POSITION_ALPHA, 0);
    await send(AxisType.AXIS_POSITION_BETA, 0);
    await send(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, 0);
    await send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, p.carrierFrequency);
    await send(AxisType.AXIS_PULSE_FREQUENCY_HZ, axes.freqHz);
    await send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, axes.widthCycles);
    await send(AxisType.AXIS_PULSE_RISE_TIME_CYCLES, axes.riseCycles);
    await send(AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT,
        p.pulseIntervalRandom / 100.0);
    await send(AxisType.AXIS_CALIBRATION_3_CENTER, d.calibration3Center);
    await send(AxisType.AXIS_CALIBRATION_3_UP, d.calibration3Up);
    await send(AxisType.AXIS_CALIBRATION_3_LEFT, d.calibration3Left);
  }
}
