import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/utils/calibration_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsProvider with ChangeNotifier {
  DeviceSettings device = DeviceSettings();
  PulseSettings pulse = PulseSettings();
  FocStimSettings focStim = FocStimSettings();
  MediaSyncSettings mediaSync = MediaSyncSettings();
  CockpitSettings cockpit = CockpitSettings();
  CockpitSettings cockpit4Phase = CockpitSettings();
  bool keepScreenOn = false;
  DeviceBehaviorSettings deviceBehavior = DeviceBehaviorSettings();

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final deviceJson = prefs.getString('device_settings');
    if (deviceJson != null) {
      device = DeviceSettings.fromJson(jsonDecode(deviceJson));
      syncFromUdLr();
    }

    final pulseJson = prefs.getString('pulse_settings');
    if (pulseJson != null) pulse = PulseSettings.fromJson(jsonDecode(pulseJson));

    final focStimJson = prefs.getString('focstim_settings');
    if (focStimJson != null) focStim = FocStimSettings.fromJson(jsonDecode(focStimJson));

    final mediaJson = prefs.getString('media_settings');
    if (mediaJson != null) mediaSync = MediaSyncSettings.fromJson(jsonDecode(mediaJson));

    final cockpitJson = prefs.getString('cockpit_settings');
    if (cockpitJson != null) cockpit = CockpitSettings.fromJson(jsonDecode(cockpitJson));

    final cockpit4Json = prefs.getString('cockpit4_settings');
    if (cockpit4Json != null) cockpit4Phase = CockpitSettings.fromJson(jsonDecode(cockpit4Json));

    keepScreenOn = prefs.getBool('keep_screen_on') ?? false;
    if (keepScreenOn) WakelockPlus.enable(); else WakelockPlus.disable();

    final behaviorJson = prefs.getString('device_behavior_settings');
    if (behaviorJson != null) deviceBehavior = DeviceBehaviorSettings.fromJson(jsonDecode(behaviorJson));

    notifyListeners();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_settings', jsonEncode(device.toJson()));
    await prefs.setString('pulse_settings', jsonEncode(pulse.toJson()));
    await prefs.setString('focstim_settings', jsonEncode(focStim.toJson()));
    await prefs.setString('media_settings', jsonEncode(mediaSync.toJson()));
    await prefs.setString('cockpit_settings', jsonEncode(cockpit.toJson()));
    await prefs.setString('cockpit4_settings', jsonEncode(cockpit4Phase.toJson()));
    await prefs.setBool('keep_screen_on', keepScreenOn);
    await prefs.setString('device_behavior_settings', jsonEncode(deviceBehavior.toJson()));
    notifyListeners();
  }

  Future<void> setKeepScreenOn(bool value) async {
    keepScreenOn = value;
    if (value) WakelockPlus.enable(); else WakelockPlus.disable();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keep_screen_on', value);
    notifyListeners();
  }

  // ── Calibration ──

  void syncFromUdLr() {
    final abc = CalibrationUtils.udLrToIntensityRatio(device.calibration3Up, device.calibration3Left);
    device.calibration3A = abc[0] > 0.0 ? (math.log(abc[0]) / math.ln10) * 10.0 : -20.0;
    device.calibration3B = abc[1] > 0.0 ? (math.log(abc[1]) / math.ln10) * 10.0 : -20.0;
    device.calibration3C = abc[2] > 0.0 ? (math.log(abc[2]) / math.ln10) * 10.0 : -20.0;
    device.calibration3A = device.calibration3A.clamp(-20.0, 0.0);
    device.calibration3B = device.calibration3B.clamp(-20.0, 0.0);
    device.calibration3C = device.calibration3C.clamp(-20.0, 0.0);
  }

  void updateCalibration3Modern(double a, double b, double c) {
    device.calibration3A = a.clamp(-20.0, 0.0);
    device.calibration3B = b.clamp(-20.0, 0.0);
    device.calibration3C = c.clamp(-20.0, 0.0);
    
    // Convert to ratios
    final double ratioA = math.pow(10.0, device.calibration3A / 10.0).toDouble();
    final double ratioB = math.pow(10.0, device.calibration3B / 10.0).toDouble();
    final double ratioC = math.pow(10.0, device.calibration3C / 10.0).toDouble();
    
    final udlr = CalibrationUtils.intensityRatioToUdLr(ratioA, ratioB, ratioC);
    device.calibration3Up = udlr[0];
    device.calibration3Left = udlr[1];
    notifyListeners();
  }

  void updateCalibration3Classic(double up, double left) {
    device.calibration3Up = up;
    device.calibration3Left = left;
    syncFromUdLr();
    notifyListeners();
  }

  void setCalibration3Interface(String val) {
    device.calibration3Interface = val;
    notifyListeners();
  }

  void resetCalibration() {
    final d = DeviceSettings();
    device
      ..calibration3Center = d.calibration3Center
      ..calibration3Up = d.calibration3Up
      ..calibration3Left = d.calibration3Left
      ..calibration3Interface = d.calibration3Interface
      ..calibration4A = d.calibration4A
      ..calibration4B = d.calibration4B
      ..calibration4C = d.calibration4C
      ..calibration4D = d.calibration4D;
    syncFromUdLr();
    notifyListeners();
  }

  Future<bool> reloadCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('device_settings');
    if (json == null) return false;
    final saved = DeviceSettings.fromJson(jsonDecode(json));
    device
      ..calibration3Center = saved.calibration3Center
      ..calibration3Up = saved.calibration3Up
      ..calibration3Left = saved.calibration3Left
      ..calibration3Interface = saved.calibration3Interface
      ..calibration4A = saved.calibration4A
      ..calibration4B = saved.calibration4B
      ..calibration4C = saved.calibration4C
      ..calibration4D = saved.calibration4D;
    syncFromUdLr();
    notifyListeners();
    return true;
  }

  // ── Pulse ──

  void resetPulse() {
    pulse = PulseSettings();
    notifyListeners();
  }

  Future<bool> reloadPulse() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('pulse_settings');
    if (json == null) return false;
    pulse = PulseSettings.fromJson(jsonDecode(json));
    notifyListeners();
    return true;
  }

  // ── Connection & safety limits ──

  void resetConnectionAndLimits() {
    focStim = FocStimSettings();
    final d = DeviceSettings();
    device
      ..minFrequency = d.minFrequency
      ..maxFrequency = d.maxFrequency
      ..waveformAmplitude = d.waveformAmplitude;
    notifyListeners();
  }

  Future<bool> reloadConnectionAndLimits() async {
    final prefs = await SharedPreferences.getInstance();
    var found = false;
    final fsJson = prefs.getString('focstim_settings');
    if (fsJson != null) {
      focStim = FocStimSettings.fromJson(jsonDecode(fsJson));
      found = true;
    }
    final dJson = prefs.getString('device_settings');
    if (dJson != null) {
      final saved = DeviceSettings.fromJson(jsonDecode(dJson));
      device
        ..minFrequency = saved.minFrequency
        ..maxFrequency = saved.maxFrequency
        ..waveformAmplitude = saved.waveformAmplitude;
      found = true;
    }
    if (found) notifyListeners();
    return found;
  }
}
