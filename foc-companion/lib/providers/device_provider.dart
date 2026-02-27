import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/focstim_api_service.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/core/command_loop.dart';
import 'package:foc_companion/core/patterns.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:foc_companion/generated/protobuf/focstim_rpc.pb.dart';
import 'package:foc_companion/services/app_logger.dart';

final _log = AppLogger.instance;

// If no notification arrives within this window the device is considered
// unresponsive and is disconnected automatically.
const _kNotificationWatchdogTimeout = Duration(seconds: 30);

class DeviceProvider with ChangeNotifier {
  final FocStimApiService api = FocStimApiService();
  SettingsProvider settings;
  CommandLoop? _threePhaseLoop;
  FourPhaseCommandLoop? _fourPhaseLoop;

  String connectionStatus = "Disconnected";
  String firmwareVersion = '';
  String temperature = "--";
  String batteryVoltage = "--";
  double? batterySoc;
  bool isLoopRunning = false;

  /// Captured debug notifications/logs
  final List<String> capturedLogs = [];
  bool isRecordingLogs = false;
  bool isShowingErrorDialog = false;
  String? lastErrorMessage;
  static const int _kMaxLogRows = 1000;
  Timer? _logInactivityTimer;

  /// True while tick round-trips are taking longer than 16 ms (can't keep 60 Hz).
  bool isSlowConnection = false;

  /// Master volume (0–1). Not persisted — resets to 0.1 on app restart/connect.
  double volume = 0.1;

  /// Hardware potentiometer volume (0–1). Updated from device notifications.
  double boxVolume = 0.0;

  /// True if the hardware volume is locked (long-press on knob).
  bool isHardwareVolumeLocked = false;

  /// Per-channel impedance magnitude in ohms, estimated by the firmware.
  /// Null when no data has been received yet (device not playing).
  /// In 3-phase mode impedanceD is always null.
  double? impedanceA;
  double? impedanceB;
  double? impedanceC;
  double? impedanceD;

  Timer? _notificationWatchdog;
  Timer? _buttonPressTimer;
  bool _buttonLongPressDetected = false;

  DeviceProvider(this.settings) {
    api.onNotification = _handleNotification;
    api.onDisconnect = () {
      _notificationWatchdog?.cancel();
      _notificationWatchdog = null;
      connectionStatus = "Disconnected";
      isLoopRunning = false;
      isSlowConnection = false;
      impedanceA = impedanceB = impedanceC = impedanceD = null;
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

    _threePhaseLoop!.onSlowConnection = _handleSlowConnection;
    _threePhaseLoop!.onTimeout = _handleLoopTimeout;
    _fourPhaseLoop!.onSlowConnection = _handleSlowConnection;
    _fourPhaseLoop!.onTimeout = _handleLoopTimeout;

    // Apply persisted cockpit settings to the loops
    _applyCockpitToLoop();
    _applyCockpit4PhaseToLoop();
  }

  // ── Slow-connection / timeout callbacks from loops ──────────────────────

  void _handleSlowConnection(bool slow) {
    if (isSlowConnection == slow) return;
    isSlowConnection = slow;
    notifyListeners();
  }

  void _handleLoopTimeout(String error) {
    if (isRecordingLogs) {
      capturedLogs.add("${DateTime.now().toIso8601String()} [TIMEOUT_ERROR] $error");
      isRecordingLogs = false;
      _logInactivityTimer?.cancel();
    }
    isLoopRunning = false;
    isSlowConnection = false;
    connectionStatus = "Timeout: $error";
    // Best-effort stop signal — may fail if link is already broken.
    api.stopSignal().catchError((e) => _log.e("stopSignal after timeout", error: e));
    notifyListeners();
  }

  // ── Notification watchdog ────────────────────────────────────────────────

  void _resetNotificationWatchdog() {
    _notificationWatchdog?.cancel();
    if (api.isConnected) {
      _notificationWatchdog = Timer(_kNotificationWatchdogTimeout, () {
        connectionStatus = "Error: Device stopped responding";
        isLoopRunning = false;
        isSlowConnection = false;
        api.disconnect(); // triggers onDisconnect → notifyListeners
      });
    }
  }

  // ── Cockpit helpers ──────────────────────────────────────────────────────

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

  // ── 3-phase cockpit ──────────────────────────────────────────────────────

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

  // ── 4-phase cockpit ──────────────────────────────────────────────────────

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

  // ── Volume ───────────────────────────────────────────────────────────────

  void setVolume(double v) {
    volume = v.clamp(0.0, 1.0);
    _threePhaseLoop?.volume = volume;
    _fourPhaseLoop?.volume = volume;
    notifyListeners();
  }

  void clearLogs() {
    _logInactivityTimer?.cancel();
    capturedLogs.clear();
    lastErrorMessage = null;
    isRecordingLogs = false;
    isShowingErrorDialog = false;
    notifyListeners();
  }

  Future<void> shareLogs() async {
    if (capturedLogs.isEmpty) return;

    final allText = capturedLogs.join('\n');
    final topText = capturedLogs.take(2).join('\n');
    final summary = "FOC Companion Diagnostic Summary:\n$topText\n... (Full log attached)";

    try {
      final tempDir = await getTemporaryDirectory();
      final file = io.File('${tempDir.path}/diagnostic_log.txt');
      await file.writeAsString(allText);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/plain')],
        text: summary,
        subject: 'FOC Companion Diagnostic Log',
      );
    } catch (e) {
      _log.e("Error sharing logs", error: e);
      // Fallback to plain text share if file fails
      await Share.share(allText, subject: 'FOC Companion Diagnostic Log');
    }
  }

  // ── Connection ───────────────────────────────────────────────────────────

  Future<void> connect() async {
    volume = 0.1;
    _threePhaseLoop?.volume = volume;
    _fourPhaseLoop?.volume = volume;
    try {
      connectionStatus = "Connecting to ${settings.focStim.wifiIp}:${settings.focStim.wifiPort}...";
      _log.i("Attempting connection to ${settings.focStim.wifiIp}:${settings.focStim.wifiPort}");
      notifyListeners();
      await api.connectTcp(settings.focStim.wifiIp, settings.focStim.wifiPort);

      connectionStatus = "Checking firmware...";
      notifyListeners();
      final resp = await api.requestFirmwareVersion();
      api.validateFirmwareVersion(resp); // throws on mismatch

      final v = resp.stm32FirmwareVersion2;
      firmwareVersion = 'v${v.major}.${v.minor}.${v.revision} (${v.branch})';
      connectionStatus = "Connected ($firmwareVersion)";
      _resetNotificationWatchdog();
    } catch (e) {
      connectionStatus = "Error: $e";
      api.disconnect();
    }
    notifyListeners();
  }

  DeviceMode get deviceMode => settings.device.deviceMode;

  void setDeviceMode(DeviceMode mode) {
    settings.device.deviceMode = mode;
    settings.saveSettings();
    notifyListeners();
  }

  Future<void> disconnect() async {
    _notificationWatchdog?.cancel();
    _notificationWatchdog = null;
    _logInactivityTimer?.cancel();
    isRecordingLogs = false;
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
      isSlowConnection = false;
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

  static double _calcImpedance(double r, double x) =>
      math.sqrt(r * r + x * x);

  void _handleNotification(Notification n) {
    _log.d("Notification: ${n.whichNotification()}");
    _resetNotificationWatchdog();

    // ── Log Recording Logic ────────────────────────────────────────────────
    if (isRecordingLogs) {
      // Reset inactivity timer
      _logInactivityTimer?.cancel();
      _logInactivityTimer = Timer(const Duration(seconds: 5), () {
        if (isRecordingLogs) {
          isRecordingLogs = false;
          capturedLogs.add("${DateTime.now().toIso8601String()} [INFO] Recording stopped due to inactivity.");
          notifyListeners();
        }
      });

      if (capturedLogs.length < _kMaxLogRows) {
        capturedLogs.add("${DateTime.now().toIso8601String()} [${n.whichNotification()}] $n");
      } else {
        isRecordingLogs = false; // reached limit
      }
    }

    if (n.hasNotificationModelEstimation()) {
      final e = n.notificationModelEstimation;
      impedanceA = _calcImpedance(e.resistanceA, e.reluctanceA);
      impedanceB = _calcImpedance(e.resistanceB, e.reluctanceB);
      impedanceC = _calcImpedance(e.resistanceC, e.reluctanceC);
      // D is zero in 3-phase mode; treat as unavailable.
      impedanceD = (e.resistanceD == 0.0 && e.reluctanceD == 0.0)
          ? null
          : _calcImpedance(e.resistanceD, e.reluctanceD);
    }
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
      batterySoc = n.notificationBattery.batterySoc;
    }
    if (n.hasNotificationPotentiometer()) {
      boxVolume = n.notificationPotentiometer.value;
    }
    if (n.hasNotificationButtonPress()) {
      final pressed = n.notificationButtonPress.pressed;
      if (pressed) {
        _buttonLongPressDetected = false;
        _buttonPressTimer?.cancel();
        _buttonPressTimer = Timer(const Duration(milliseconds: 1800), () {
          _buttonLongPressDetected = true;
        });
      } else {
        _buttonPressTimer?.cancel();
        _buttonPressTimer = null;
        if (!_buttonLongPressDetected) {
          toggleLoop();
        }
        _buttonLongPressDetected = false;
      }
    }
    if (n.hasNotificationDeviceState()) {
      isHardwareVolumeLocked = n.notificationDeviceState.volumeLocked;
    }
    if (n.hasNotificationDebugString()) {
      final msg = n.notificationDebugString.message;
      _log.d("Device: $msg");

      // Detect critical error to start recording/show dialog
      if (msg.contains("Current limit exceeded") || msg.contains("Producer too slow")) {
        if (!isRecordingLogs) {
          lastErrorMessage = msg;
          isRecordingLogs = true;
          capturedLogs.clear();
          capturedLogs.add("${DateTime.now().toIso8601String()} [INITIAL_ERROR] $msg");
        }
      }
    }
    notifyListeners();
  }
}
