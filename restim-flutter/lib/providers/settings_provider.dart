import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restim_flutter/models/settings_models.dart';

class SettingsProvider with ChangeNotifier {
  DeviceSettings device = DeviceSettings();
  PulseSettings pulse = PulseSettings();
  FocStimSettings focStim = FocStimSettings();
  MediaSyncSettings mediaSync = MediaSyncSettings();

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final deviceJson = prefs.getString('device_settings');
    if (deviceJson != null) device = DeviceSettings.fromJson(jsonDecode(deviceJson));

    final pulseJson = prefs.getString('pulse_settings');
    if (pulseJson != null) pulse = PulseSettings.fromJson(jsonDecode(pulseJson));

    final focStimJson = prefs.getString('focstim_settings');
    if (focStimJson != null) focStim = FocStimSettings.fromJson(jsonDecode(focStimJson));

    final mediaJson = prefs.getString('media_settings');
    if (mediaJson != null) mediaSync = MediaSyncSettings.fromJson(jsonDecode(mediaJson));
    
    notifyListeners();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_settings', jsonEncode(device.toJson()));
    await prefs.setString('pulse_settings', jsonEncode(pulse.toJson()));
    await prefs.setString('focstim_settings', jsonEncode(focStim.toJson()));
    await prefs.setString('media_settings', jsonEncode(mediaSync.toJson()));
    notifyListeners();
  }
}
