import 'package:flutter/foundation.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/focstim_api_service.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/core/command_loop.dart';
import 'package:foc_companion/core/patterns.dart';
import 'package:foc_companion/generated/protobuf/focstim_rpc.pb.dart';

class DeviceProvider with ChangeNotifier {
  final FocStimApiService api = FocStimApiService();
  SettingsProvider settings;
  CommandLoop? _threePhaseLoop;
  FourPhaseCommandLoop? _fourPhaseLoop;

  String connectionStatus = "Disconnected";
  String firmwareVersion = '';
  String temperature = "--";
  String batteryVoltage = "--";
  bool isLoopRunning = false;

  DeviceProvider(this.settings) {
    api.onNotification = _handleNotification;
    api.onDisconnect = () {
      connectionStatus = "Disconnected";
      isLoopRunning = false;
      _threePhaseLoop?.stop();
      _fourPhaseLoop?.stop();
      notifyListeners();
    };
    api.onError = (err) {
      connectionStatus = "Error: $err";
      notifyListeners();
    };

    _threePhaseLoop = CommandLoop(api, settings);
    _fourPhaseLoop = FourPhaseCommandLoop(api, settings);

    // Apply persisted cockpit settings to the loops
    _applyCockpitToLoop();
    _applyCockpit4PhaseToLoop();
  }

  void _applyCockpitToLoop() {
    final c = settings.cockpit;
    final idx = c.patternIndex.clamp(0, ThreephasePatternRegistry.all.length - 1);
    _threePhaseLoop?.pattern = ThreephasePatternRegistry.all[idx];
    _threePhaseLoop?.velocity = c.velocity;
    _threePhaseLoop?.setPulseModConfig(c.pulseFreqMod);
  }

  void _applyCockpit4PhaseToLoop() {
    final c = settings.cockpit4Phase;
    final idx = c.patternIndex.clamp(0, FourphasePatternRegistry.all.length - 1);
    _fourPhaseLoop?.pattern = FourphasePatternRegistry.all[idx];
    _fourPhaseLoop?.velocity = c.velocity;
    _fourPhaseLoop?.setPulseModConfig(c.pulseFreqMod);
  }

  void updateSettings(SettingsProvider newSettings) {
    settings = newSettings;
  }

  CockpitSettings get cockpit => settings.cockpit;
  CockpitSettings get cockpit4Phase => settings.cockpit4Phase;

  // ── 3-phase cockpit ──

  void selectPattern(int index) {
    final idx = index.clamp(0, ThreephasePatternRegistry.all.length - 1);
    settings.cockpit.patternIndex = idx;
    _threePhaseLoop?.pattern = ThreephasePatternRegistry.all[idx];
    settings.saveSettings();
    notifyListeners();
  }

  void setVelocity(double v) {
    settings.cockpit.velocity = v.clamp(0.1, 4.0);
    _threePhaseLoop?.velocity = settings.cockpit.velocity;
    settings.saveSettings();
    notifyListeners();
  }

  void updatePulseModConfig(PulseModulationConfig config) {
    settings.cockpit.pulseFreqMod = config;
    _threePhaseLoop?.setPulseModConfig(config);
    settings.saveSettings();
    notifyListeners();
  }

  // ── 4-phase cockpit ──

  void select4PhasePattern(int index) {
    final idx = index.clamp(0, FourphasePatternRegistry.all.length - 1);
    settings.cockpit4Phase.patternIndex = idx;
    _fourPhaseLoop?.pattern = FourphasePatternRegistry.all[idx];
    settings.saveSettings();
    notifyListeners();
  }

  void set4PhaseVelocity(double v) {
    settings.cockpit4Phase.velocity = v.clamp(0.1, 4.0);
    _fourPhaseLoop?.velocity = settings.cockpit4Phase.velocity;
    settings.saveSettings();
    notifyListeners();
  }

  void update4PhasePulseModConfig(PulseModulationConfig config) {
    settings.cockpit4Phase.pulseFreqMod = config;
    _fourPhaseLoop?.setPulseModConfig(config);
    settings.saveSettings();
    notifyListeners();
  }

  Future<void> connect() async {
    try {
      connectionStatus = "Connecting to ${settings.focStim.wifiIp}:${settings.focStim.wifiPort}...";
      print("Attempting connection to ${settings.focStim.wifiIp}:${settings.focStim.wifiPort}");
      notifyListeners();
      await api.connectTcp(settings.focStim.wifiIp, settings.focStim.wifiPort);

      connectionStatus = "Checking firmware...";
      notifyListeners();
      final resp = await api.requestFirmwareVersion();
      api.validateFirmwareVersion(resp); // throws on mismatch

      final v = resp.stm32FirmwareVersion2;
      firmwareVersion = 'v${v.major}.${v.minor}.${v.revision} (${v.branch})';
      connectionStatus = "Connected ($firmwareVersion)";
    } catch (e) {
      connectionStatus = "Error: $e";
      api.disconnect();
    }
    notifyListeners();
  }

  DeviceMode get deviceMode => settings.device.deviceMode;

  Future<void> disconnect() async {
    await _threePhaseLoop?.stop();
    await _fourPhaseLoop?.stop();
    api.disconnect();
  }

  Future<void> toggleLoop() async {
    if (!api.isConnected) return;

    if (isLoopRunning) {
      if (deviceMode == DeviceMode.fourPhase) {
        await _fourPhaseLoop?.stop();
      } else {
        await _threePhaseLoop?.stop();
      }
      isLoopRunning = false;
    } else {
      if (deviceMode == DeviceMode.fourPhase) {
        await _fourPhaseLoop?.start();
      } else {
        await _threePhaseLoop?.start();
      }
      isLoopRunning = true;
    }
    notifyListeners();
  }

  void _handleNotification(Notification n) {
    print("Received notification: ${n.whichNotification()}");

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
