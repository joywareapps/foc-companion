import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/core/patterns.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:foc_companion/services/app_logger.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:foc_companion/services/background_service.dart';

final _log = AppLogger.instance;

class BackgroundApiCompatibility {
  final DeviceProvider _provider;
  BackgroundApiCompatibility(this._provider);
  bool get isConnected => _provider.connectionStatus == "Connected" || _provider.connectionStatus.startsWith("Connected");
}

class DeviceProvider with ChangeNotifier {
  late final BackgroundApiCompatibility api = BackgroundApiCompatibility(this);
  SettingsProvider settings;

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

  /// True if the hardware potentiometer is locked.
  bool isPotLocked = false;

  /// Per-channel impedance magnitude in ohms, estimated by the firmware.
  /// Null when no data has been received yet (device not playing).
  /// In 3-phase mode impedanceD is always null.
  double? impedanceA;
  double? impedanceB;
  double? impedanceC;
  double? impedanceD;

  DeviceProvider(this.settings) {
    FlutterForegroundTask.addTaskDataCallback(_handleBackgroundMessage);
    checkExistingConnection();
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_handleBackgroundMessage);
    _logInactivityTimer?.cancel();
    super.dispose();
  }

  Future<void> checkExistingConnection() async {
    if (await FlutterForegroundTask.isRunningService) {
      BackgroundServiceManager.sendCommand('requestState');
      _syncSettingsToBackground();
    }
  }

  void _syncSettingsToBackground() {
    BackgroundServiceManager.sendCommand('updateSettings', {
      'device': settings.device.toJson(),
      'pulse': settings.pulse.toJson(),
      'deviceBehavior': settings.deviceBehavior.toJson(),
    });
  }

  void _handleBackgroundMessage(dynamic msg) {
    if (msg is! Map) return;

    final type = msg['type'];
    switch (type) {
      case 'stateUpdate':
        connectionStatus = msg['connectionStatus'] as String? ?? connectionStatus;
        firmwareVersion = msg['firmwareVersion'] as String? ?? firmwareVersion;
        isLoopRunning = msg['isLoopRunning'] as bool? ?? isLoopRunning;
        isSlowConnection = msg['isSlowConnection'] as bool? ?? isSlowConnection;
        isPotLocked = msg['isPotLocked'] as bool? ?? isPotLocked;
        notifyListeners();
        break;

      case 'log':
        final logMsg = msg['message'] as String;
        _log.i("[Background] $logMsg");
        
        if (isRecordingLogs && capturedLogs.length < _kMaxLogRows) {
          capturedLogs.add(logMsg);
        }
        notifyListeners();
        break;

      case 'notification':
        // Reset inactivity timer
        if (isRecordingLogs) {
          _logInactivityTimer?.cancel();
          _logInactivityTimer = Timer(const Duration(seconds: 5), () {
            if (isRecordingLogs) {
              isRecordingLogs = false;
              capturedLogs.add("${DateTime.now().toIso8601String()} [INFO] Recording stopped due to inactivity.");
              notifyListeners();
            }
          });
        }

        if (msg.containsKey('impedanceA')) {
          impedanceA = (msg['impedanceA'] as num?)?.toDouble();
        }
        if (msg.containsKey('impedanceB')) {
          impedanceB = (msg['impedanceB'] as num?)?.toDouble();
        }
        if (msg.containsKey('impedanceC')) {
          impedanceC = (msg['impedanceC'] as num?)?.toDouble();
        }
        if (msg.containsKey('impedanceD')) {
          impedanceD = (msg['impedanceD'] as num?)?.toDouble();
        }
        if (msg.containsKey('temperature')) {
          temperature = msg['temperature'] as String;
        }
        if (msg.containsKey('batteryVoltage')) {
          batteryVoltage = msg['batteryVoltage'] as String;
        }
        if (msg.containsKey('batterySoc')) {
          batterySoc = (msg['batterySoc'] as num?)?.toDouble();
        }
        if (msg.containsKey('boxVolume')) {
          boxVolume = (msg['boxVolume'] as num).toDouble();
        }
        if (msg.containsKey('isPotLocked')) {
          isPotLocked = msg['isPotLocked'] as bool;
        }
        if (msg.containsKey('debugMessage')) {
          final dbgMsg = msg['debugMessage'] as String;
          _log.d("Device: $dbgMsg");

          if (isRecordingLogs && capturedLogs.length < _kMaxLogRows) {
            capturedLogs.add("${DateTime.now().toIso8601String()} [Device Debug] $dbgMsg");
          }

          if (dbgMsg.contains("Current limit exceeded") || dbgMsg.contains("Producer too slow")) {
            if (!isRecordingLogs) {
              lastErrorMessage = dbgMsg;
              isRecordingLogs = true;
              capturedLogs.clear();
              capturedLogs.add("${DateTime.now().toIso8601String()} [INITIAL_ERROR] $dbgMsg");
            }
          }
        }
        notifyListeners();
        break;
    }
  }

  void updateSettings(SettingsProvider newSettings) {
    settings = newSettings;
    _syncSettingsToBackground();
  }

  CockpitSettings get cockpit => settings.cockpit;
  CockpitSettings get cockpit4Phase => settings.cockpit4Phase;

  // ── 3-phase cockpit ──────────────────────────────────────────────────────

  void selectPattern(int index) {
    final idx = index.clamp(0, ThreephasePatternRegistry.all.length - 1);
    settings.cockpit.patternIndex = idx;
    BackgroundServiceManager.sendCommand('selectPattern', {'index': idx});
    settings.saveSettings();
    notifyListeners();
  }

  void setVelocity(double v) {
    settings.cockpit.velocity = v.clamp(0.1, 4.0);
    BackgroundServiceManager.sendCommand('setVelocity', {'velocity': settings.cockpit.velocity});
    settings.saveSettings();
    notifyListeners();
  }

  void updatePulseModConfig(PulseModulationConfig config) {
    settings.cockpit.pulseFreqMod = config;
    BackgroundServiceManager.sendCommand('updatePulseModConfig', {'config': config.toJson()});
    settings.saveSettings();
    notifyListeners();
  }

  // ── 4-phase cockpit ──────────────────────────────────────────────────────

  void select4PhasePattern(int index) {
    final idx = index.clamp(0, FourphasePatternRegistry.all.length - 1);
    settings.cockpit4Phase.patternIndex = idx;
    BackgroundServiceManager.sendCommand('select4PhasePattern', {'index': idx});
    settings.saveSettings();
    notifyListeners();
  }

  void set4PhaseVelocity(double v) {
    settings.cockpit4Phase.velocity = v.clamp(0.1, 4.0);
    BackgroundServiceManager.sendCommand('set4PhaseVelocity', {'velocity': settings.cockpit4Phase.velocity});
    settings.saveSettings();
    notifyListeners();
  }

  void update4PhasePulseModConfig(PulseModulationConfig config) {
    settings.cockpit4Phase.pulseFreqMod = config;
    BackgroundServiceManager.sendCommand('update4PhasePulseModConfig', {'config': config.toJson()});
    settings.saveSettings();
    notifyListeners();
  }

  // ── Volume ───────────────────────────────────────────────────────────────

  void setVolume(double v) {
    volume = v.clamp(0.0, 1.0);
    BackgroundServiceManager.sendCommand('setVolume', {'volume': volume});
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
      await Share.share(allText, subject: 'FOC Companion Diagnostic Log');
    }
  }

  // ── Connection ───────────────────────────────────────────────────────────

  Future<void> connect() async {
    volume = 0.1;
    connectionStatus = "Starting service...";
    notifyListeners();

    try {
      final success = await BackgroundServiceManager.start();
      if (!success) {
        connectionStatus = "Error: Permission Denied";
        notifyListeners();
        return;
      }

      // Sync active state
      _syncSettingsToBackground();
      BackgroundServiceManager.sendCommand('setDeviceMode', {'mode': settings.device.deviceMode.name});
      BackgroundServiceManager.sendCommand('setVolume', {'volume': volume});
      BackgroundServiceManager.sendCommand('selectPattern', {'index': settings.cockpit.patternIndex});
      BackgroundServiceManager.sendCommand('select4PhasePattern', {'index': settings.cockpit4Phase.patternIndex});
      BackgroundServiceManager.sendCommand('setVelocity', {'velocity': settings.cockpit.velocity});
      BackgroundServiceManager.sendCommand('set4PhaseVelocity', {'velocity': settings.cockpit4Phase.velocity});
      BackgroundServiceManager.sendCommand('updatePulseModConfig', {'config': settings.cockpit.pulseFreqMod.toJson()});
      BackgroundServiceManager.sendCommand('update4PhasePulseModConfig', {'config': settings.cockpit4Phase.pulseFreqMod.toJson()});

      connectionStatus = "Connecting...";
      notifyListeners();
      
      BackgroundServiceManager.sendCommand('connect', {
        'ip': settings.focStim.wifiIp,
        'port': settings.focStim.wifiPort,
      });
    } catch (e) {
      connectionStatus = "Error: $e";
      notifyListeners();
    }
  }

  DeviceMode get deviceMode => settings.device.deviceMode;

  void setDeviceMode(DeviceMode mode) {
    settings.device.deviceMode = mode;
    BackgroundServiceManager.sendCommand('setDeviceMode', {'mode': mode.name});
    settings.saveSettings();
    notifyListeners();
  }

  Future<void> disconnect() async {
    _logInactivityTimer?.cancel();
    isRecordingLogs = false;
    
    BackgroundServiceManager.sendCommand('disconnect');
    await BackgroundServiceManager.stop();

    connectionStatus = "Disconnected";
    isLoopRunning = false;
    isSlowConnection = false;
    impedanceA = impedanceB = impedanceC = impedanceD = null;
    notifyListeners();
  }

  Future<void> toggleLoop() async {
    BackgroundServiceManager.sendCommand('toggleLoop');
  }

  Future<void> togglePotLock() async {
    BackgroundServiceManager.sendCommand('togglePotLock');
  }
}
