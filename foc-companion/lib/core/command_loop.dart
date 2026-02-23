import 'dart:async';
import 'package:foc_companion/services/focstim_api_service.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/core/patterns.dart';
import 'package:foc_companion/core/modulation.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/generated/protobuf/constants.pbenum.dart';
import 'package:foc_companion/generated/protobuf/focstim_rpc.pb.dart';
import 'package:foc_companion/generated/protobuf/messages.pb.dart';

class FourPhaseCommandLoop {
  final FocStimApiService _api;
  final SettingsProvider _settings;
  final CyclePattern4Phase _pattern = CyclePattern4Phase();
  Timer? _timer;
  bool _isRunning = false;
  double _startTime = 0;

  FourPhaseCommandLoop(this._api, this._settings);

  Future<void> start() async {
    if (_isRunning) return;
    print("FourPhaseCommandLoop: Starting...");
    try {
      await _setupParams();
      print("FourPhaseCommandLoop: Params setup complete. Starting signal...");
      await _api.startSignal(mode: OutputMode.OUTPUT_FOURPHASE_INDIVIDUAL_ELECTRODES);
      print("FourPhaseCommandLoop: Signal started.");
      _isRunning = true;
      _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _timer = Timer.periodic(const Duration(milliseconds: 16), _tick);
    } catch (e) {
      print("FourPhaseCommandLoop: Error starting: $e");
      _isRunning = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    print("FourPhaseCommandLoop: Stopping...");
    _timer?.cancel();
    _isRunning = false;
    await _api.stopSignal();
    print("FourPhaseCommandLoop: Stopped.");
  }

  void _tick(Timer timer) async {
    if (!_api.isConnected) return;

    double now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    var pos = _pattern.update(0.016);

    double elapsed = now - _startTime;
    double ramp = (elapsed / 5.0).clamp(0.0, 1.0);
    // 4-phase uses squared volume for perceptual linearity
    double currentAmp = _settings.device.waveformAmplitude * ramp * ramp;

    try {
      _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_ELECTRODE_1_POWER
          ..value = pos.a
          ..interval = 50));
      _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_ELECTRODE_2_POWER
          ..value = pos.b
          ..interval = 50));
      _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_ELECTRODE_3_POWER
          ..value = pos.c
          ..interval = 50));
      _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_ELECTRODE_4_POWER
          ..value = pos.d
          ..interval = 50));
      _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS
          ..value = currentAmp
          ..interval = 50));
    } catch (e) {
      print("4-phase loop error: $e");
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

    // Initialize electrode power axes to 0
    await send(AxisType.AXIS_ELECTRODE_1_POWER, 0);
    await send(AxisType.AXIS_ELECTRODE_2_POWER, 0);
    await send(AxisType.AXIS_ELECTRODE_3_POWER, 0);
    await send(AxisType.AXIS_ELECTRODE_4_POWER, 0);

    // Reset amplitude to 0
    await send(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, 0);

    // Pulse settings
    await send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, p.carrierFrequency);
    await send(AxisType.AXIS_PULSE_FREQUENCY_HZ, p.pulseFrequency);
    await send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, p.pulseWidth);
    await send(AxisType.AXIS_PULSE_RISE_TIME_CYCLES, p.pulseRiseTime);
    await send(AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT, p.pulseIntervalRandom / 100.0);

    // 4-phase calibration
    await send(AxisType.AXIS_CALIBRATION_4_CENTER, d.calibration4Center);
    await send(AxisType.AXIS_CALIBRATION_4_A, d.calibration4A);
    await send(AxisType.AXIS_CALIBRATION_4_B, d.calibration4B);
    await send(AxisType.AXIS_CALIBRATION_4_C, d.calibration4C);
    await send(AxisType.AXIS_CALIBRATION_4_D, d.calibration4D);
  }
}

class CommandLoop {
  final FocStimApiService _api;
  final SettingsProvider _settings;

  /// Active pattern — can be swapped while running.
  ThreephasePattern pattern = CirclePattern();

  /// Playback speed multiplier (applied to dt fed into the pattern).
  double velocity = 1.0;

  final Modulator _pulseFreqMod = Modulator(PulseModulationConfig());

  Timer? _timer;
  bool _isRunning = false;
  double _startTime = 0;

  CommandLoop(this._api, this._settings);

  void setPulseModConfig(PulseModulationConfig config) {
    _pulseFreqMod.config = config;
  }

  Future<void> start() async {
    if (_isRunning) return;
    print("CommandLoop: Starting...");

    pattern.reset();
    _pulseFreqMod.reset();

    try {
      await _setupParams();
      print("CommandLoop: Params setup complete. Starting signal...");
      await _api.startSignal();
      print("CommandLoop: Signal started.");

      _isRunning = true;
      _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

      // 60 Hz loop
      _timer = Timer.periodic(const Duration(milliseconds: 16), _tick);
    } catch (e) {
      print("CommandLoop: Error starting: $e");
      _isRunning = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    print("CommandLoop: Stopping...");
    _timer?.cancel();
    _isRunning = false;
    await _api.stopSignal();
    print("CommandLoop: Stopped.");
  }

  void _tick(Timer timer) async {
    if (!_api.isConnected) return;

    const double dt = 0.016;
    double now = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // Velocity scales the dt fed into the pattern
    var pos = pattern.update(dt * velocity);

    // Ramp
    double elapsed = now - _startTime;
    double targetAmp = _settings.device.waveformAmplitude;
    double currentAmp = targetAmp * (elapsed / 5.0).clamp(0.0, 1.0);

    // Pulse-frequency modulation
    final freqOffset = _pulseFreqMod.update(dt, velocity);
    final modFreq = (_settings.pulse.pulseFrequency + freqOffset).clamp(1.0, 300.0);

    try {
      _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_POSITION_ALPHA
          ..value = pos.x
          ..interval = 50));

      _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_POSITION_BETA
          ..value = pos.y
          ..interval = 50));

      _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS
          ..value = currentAmp
          ..interval = 50));

      if (_pulseFreqMod.config.enabled) {
        _api.sendRequest(Request()
          ..requestAxisMoveTo = (RequestAxisMoveTo()
            ..axis = AxisType.AXIS_PULSE_FREQUENCY_HZ
            ..value = modFreq
            ..interval = 50));
      }
    } catch (e) {
      print("Loop error: $e");
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

    // Initialize position axes to 0
    await send(AxisType.AXIS_POSITION_ALPHA, 0);
    await send(AxisType.AXIS_POSITION_BETA, 0);

    // Reset amplitude to 0
    await send(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, 0);

    // Pulse settings
    await send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, p.carrierFrequency);
    await send(AxisType.AXIS_PULSE_FREQUENCY_HZ, p.pulseFrequency);
    await send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, p.pulseWidth);
    await send(AxisType.AXIS_PULSE_RISE_TIME_CYCLES, p.pulseRiseTime);
    await send(AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT, p.pulseIntervalRandom / 100.0);

    // Calibration settings
    await send(AxisType.AXIS_CALIBRATION_3_CENTER, d.calibration3Center);
    await send(AxisType.AXIS_CALIBRATION_3_UP, d.calibration3Up);
    await send(AxisType.AXIS_CALIBRATION_3_LEFT, d.calibration3Left);
  }
}
