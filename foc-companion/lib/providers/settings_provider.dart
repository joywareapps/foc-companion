import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/utils/calibration_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsProvider with ChangeNotifier {
  List<BoxProfile> boxes = [
    BoxProfile(name: "Box 1"),
    BoxProfile(name: "Box 2"),
  ];
  int activeUiBoxIndex = 0;
  bool linkDevicesEnabled = false;

  MediaSyncSettings mediaSync = MediaSyncSettings();
  bool keepScreenOn = false;
  DeviceBehaviorSettings deviceBehavior = DeviceBehaviorSettings();

  BoxProfile get activeBox => boxes[activeUiBoxIndex.clamp(0, boxes.length - 1)];

  // Compatibility getters/setters mapping to active focused box in UI
  DeviceSettings get device => activeBox.device;
  set device(DeviceSettings val) {
    activeBox.device = val;
  }

  PulseSettings get pulse => activeBox.pulse;
  set pulse(PulseSettings val) {
    activeBox.pulse = val;
  }

  FocStimSettings get focStim => activeBox.connection;
  set focStim(FocStimSettings val) {
    activeBox.connection = val;
  }

  CockpitSettings get cockpit => activeBox.cockpit;
  set cockpit(CockpitSettings val) {
    activeBox.cockpit = val;
  }

  CockpitSettings get cockpit4Phase => activeBox.cockpit4Phase;
  set cockpit4Phase(CockpitSettings val) {
    activeBox.cockpit4Phase = val;
  }

  void setActiveUiBoxIndex(int index) {
    activeUiBoxIndex = index.clamp(0, boxes.length - 1);
    saveSettings();
    notifyListeners();
  }

  void setLinkDevicesEnabled(bool enabled) {
    linkDevicesEnabled = enabled;
    saveSettings();
    notifyListeners();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final boxesJson = prefs.getString('box_profiles_v2');
    if (boxesJson != null) {
      try {
        final List decoded = jsonDecode(boxesJson);
        boxes = decoded.map((e) => BoxProfile.fromJson(Map<String, dynamic>.from(e))).toList();
        while (boxes.length < 2) {
          boxes.add(BoxProfile(name: "Box ${boxes.length + 1}"));
        }
        if (boxes.length > 2) {
          boxes = boxes.sublist(0, 2);
        }
      } catch (_) {}
    } else {
      // Migrate old single settings
      final deviceJson = prefs.getString('device_settings');
      final pulseJson = prefs.getString('pulse_settings');
      final focStimJson = prefs.getString('focstim_settings');
      final cockpitJson = prefs.getString('cockpit_settings');
      final cockpit4Json = prefs.getString('cockpit4_settings');

      if (deviceJson != null) boxes[0].device = DeviceSettings.fromJson(jsonDecode(deviceJson));
      if (pulseJson != null) boxes[0].pulse = PulseSettings.fromJson(jsonDecode(pulseJson));
      if (focStimJson != null) boxes[0].connection = FocStimSettings.fromJson(jsonDecode(focStimJson));
      if (cockpitJson != null) boxes[0].cockpit = CockpitSettings.fromJson(jsonDecode(cockpitJson));
      if (cockpit4Json != null) boxes[0].cockpit4Phase = CockpitSettings.fromJson(jsonDecode(cockpit4Json));
    }

    activeUiBoxIndex = prefs.getInt('active_ui_box_index') ?? 0;
    linkDevicesEnabled = prefs.getBool('link_devices_enabled') ?? false;

    final mediaJson = prefs.getString('media_settings');
    if (mediaJson != null) mediaSync = MediaSyncSettings.fromJson(jsonDecode(mediaJson));

    keepScreenOn = prefs.getBool('keep_screen_on') ?? false;
    if (keepScreenOn) WakelockPlus.enable(); else WakelockPlus.disable();

    final behaviorJson = prefs.getString('device_behavior_settings');
    if (behaviorJson != null) deviceBehavior = DeviceBehaviorSettings.fromJson(jsonDecode(behaviorJson));

    // Run calibration sync for both boxes
    for (var box in boxes) {
      _syncFromUdLrForBox(box.device);
    }

    notifyListeners();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('box_profiles_v2', jsonEncode(boxes.map((e) => e.toJson()).toList()));
    await prefs.setInt('active_ui_box_index', activeUiBoxIndex);
    await prefs.setBool('link_devices_enabled', linkDevicesEnabled);
    await prefs.setString('media_settings', jsonEncode(mediaSync.toJson()));
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

  void _syncFromUdLrForBox(DeviceSettings dev) {
    final abc = CalibrationUtils.udLrToIntensityRatio(dev.calibration3Up, dev.calibration3Left);
    dev.calibration3A = abc[0] > 0.0 ? (math.log(abc[0]) / math.ln10) * 10.0 : -20.0;
    dev.calibration3B = abc[1] > 0.0 ? (math.log(abc[1]) / math.ln10) * 10.0 : -20.0;
    dev.calibration3C = abc[2] > 0.0 ? (math.log(abc[2]) / math.ln10) * 10.0 : -20.0;
    dev.calibration3A = dev.calibration3A.clamp(-20.0, 0.0);
    dev.calibration3B = dev.calibration3B.clamp(-20.0, 0.0);
    dev.calibration3C = dev.calibration3C.clamp(-20.0, 0.0);
  }

  void syncFromUdLr() {
    _syncFromUdLrForBox(device);
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

  void resetCalibration() {
    final d = DeviceSettings();
    device
      ..calibration3Center = d.calibration3Center
      ..calibration3Up = d.calibration3Up
      ..calibration3Left = d.calibration3Left
      ..calibration3A = d.calibration3A
      ..calibration3B = d.calibration3B
      ..calibration3C = d.calibration3C
      ..calibration4A = d.calibration4A
      ..calibration4B = d.calibration4B
      ..calibration4C = d.calibration4C
      ..calibration4D = d.calibration4D;
    notifyListeners();
  }

  Future<bool> reloadCalibration() async {
    final prefs = await SharedPreferences.getInstance();

    DeviceSettings? saved;

    // Prefer the current multi-box storage format.
    final boxesJson = prefs.getString('box_profiles_v2');
    if (boxesJson != null) {
      try {
        final List decoded = jsonDecode(boxesJson);
        if (activeUiBoxIndex < decoded.length) {
          final boxMap = Map<String, dynamic>.from(decoded[activeUiBoxIndex] as Map);
          final deviceMap = boxMap['device'] as Map<String, dynamic>?;
          if (deviceMap != null) saved = DeviceSettings.fromJson(deviceMap);
        }
      } catch (_) {}
    }

    // Fall back to old single-box key for users who haven't migrated yet.
    if (saved == null) {
      final json = prefs.getString('device_settings');
      if (json == null) return false;
      saved = DeviceSettings.fromJson(jsonDecode(json));
    }

    device
      ..calibration3Center = saved.calibration3Center
      ..calibration3Up = saved.calibration3Up
      ..calibration3Left = saved.calibration3Left
      ..calibration3A = saved.calibration3A
      ..calibration3B = saved.calibration3B
      ..calibration3C = saved.calibration3C
      ..calibration4A = saved.calibration4A
      ..calibration4B = saved.calibration4B
      ..calibration4C = saved.calibration4C
      ..calibration4D = saved.calibration4D;

    // Sync Up/Left → A/B/C in case this save predates the A/B/C fields.
    _syncFromUdLrForBox(device);

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
