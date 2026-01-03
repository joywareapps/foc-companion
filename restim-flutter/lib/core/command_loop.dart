import 'dart:async';
import 'package:restim_flutter/services/focstim_api_service.dart';
import 'package:restim_flutter/providers/settings_provider.dart';
import 'package:restim_flutter/core/patterns.dart';
import 'package:restim_flutter/generated/protobuf/constants.pbenum.dart';
import 'package:restim_flutter/generated/protobuf/focstim_rpc.pb.dart';
import 'package:restim_flutter/generated/protobuf/messages.pb.dart';

class CommandLoop {
  final FocStimApiService _api;
  final SettingsProvider _settings;
  final CirclePattern _pattern = CirclePattern();
  Timer? _timer;
  bool _isRunning = false;
  double _startTime = 0;

  CommandLoop(this._api, this._settings);

  Future<void> start() async {
    if (_isRunning) return;
    
    // Setup params
    await _setupParams();
    await _api.startSignal();

    _isRunning = true;
    _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    // 60Hz loop
    _timer = Timer.periodic(const Duration(milliseconds: 16), _tick);
  }

  Future<void> stop() async {
    _timer?.cancel();
    _isRunning = false;
    await _api.stopSignal();
  }

  void _tick(Timer timer) async {
    if (!_api.isConnected) return;

    double now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    // Update pattern
    // Fixed dt for simplicity or calc delta
    var pos = _pattern.update(0.016); 

    // Ramp
    double elapsed = now - _startTime;
    double targetAmp = _settings.device.waveformAmplitude;
    double currentAmp = targetAmp * (elapsed / 5.0).clamp(0.0, 1.0);

    try {
      // Send updates
      await _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_POSITION_ALPHA
          ..value = pos.x
          ..interval = 50));
          
      await _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_POSITION_BETA
          ..value = pos.y
          ..interval = 50));

      await _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS
          ..value = currentAmp
          ..interval = 50));
    } catch (e) {
      print("Loop error: $e");
    }
  }

  Future<void> _setupParams() async {
    Future<void> send(AxisType axis, double val) async {
      await _api.sendRequest(Request()
        ..requestAxisMoveTo = (RequestAxisMoveTo()
          ..axis = axis
          ..value = val
          ..interval = 0));
    }

    var p = _settings.pulse;
    var d = _settings.device;

    await send(AxisType.AXIS_CARRIER_FREQUENCY_HZ, p.carrierFrequency);
    await send(AxisType.AXIS_PULSE_FREQUENCY_HZ, p.pulseFrequency);
    await send(AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, p.pulseWidth);
    
    await send(AxisType.AXIS_CALIBRATION_3_CENTER, d.calibration3Center);
    // ... others
  }
}
