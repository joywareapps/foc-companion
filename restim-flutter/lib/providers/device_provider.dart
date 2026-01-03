import 'package:flutter/foundation.dart';
import 'package:restim_flutter/services/focstim_api_service.dart';
import 'package:restim_flutter/providers/settings_provider.dart';
import 'package:restim_flutter/core/command_loop.dart';
import 'package:restim_flutter/generated/protobuf/focstim_rpc.pb.dart';

class DeviceProvider with ChangeNotifier {
  final FocStimApiService api = FocStimApiService();
  SettingsProvider settings;
  CommandLoop? _loop;

  String connectionStatus = "Disconnected";
  String temperature = "--";
  String batteryVoltage = "--";
  bool isLoopRunning = false;

  DeviceProvider(this.settings) {
    api.onNotification = _handleNotification;
    api.onDisconnect = () {
      connectionStatus = "Disconnected";
      isLoopRunning = false;
      _loop?.stop();
      notifyListeners();
    };
    api.onError = (err) {
      connectionStatus = "Error: $err";
      notifyListeners();
    };
    
    _loop = CommandLoop(api, settings);
  }

  void updateSettings(SettingsProvider newSettings) {
    settings = newSettings;
    // Update loop settings if running
  }

  Future<void> connect() async {
    try {
      connectionStatus = "Connecting to ${settings.focStim.wifiIp}:${settings.focStim.wifiPort}...";
      print("Attempting connection to ${settings.focStim.wifiIp}:${settings.focStim.wifiPort}");
      notifyListeners();
      await api.connectTcp(settings.focStim.wifiIp, settings.focStim.wifiPort);
      connectionStatus = "Connected";
    } catch (e) {
      connectionStatus = "Error: $e";
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _loop?.stop();
    api.disconnect();
  }

  Future<void> toggleLoop() async {
    if (!api.isConnected) return;

    if (isLoopRunning) {
      await _loop?.stop();
      isLoopRunning = false;
    } else {
      await _loop?.start();
      isLoopRunning = true;
    }
    notifyListeners();
  }

  void _handleNotification(Notification n) {
    print("Received notification: ${n.whichNotification()}");
    
    // Parse notifications to update state (temp, battery, etc)
    if (n.hasNotificationSystemStats()) {
       final stats = n.notificationSystemStats;
       if (stats.hasFocstimv3()) {
         temperature = "${stats.focstimv3.tempStm32.toStringAsFixed(1)}°C";
       } else if (stats.hasEsc1()) {
         temperature = "${stats.esc1.tempStm32.toStringAsFixed(1)}°C";
       }
    }
    if (n.hasNotificationBattery()) {
      batteryVoltage = "${n.notificationBattery.batteryVoltage.toStringAsFixed(2)}V";
    }
    notifyListeners();
  }
}
