import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
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
  bool get isConnected =>
      _provider.connectionStatus == "Connected" ||
      _provider.connectionStatus.startsWith("Connected");
}

class BoxStatus {
  final int index;
  String connectionStatus = "Disconnected";
  String firmwareVersion = "";
  String temperature = "--";
  String batteryVoltage = "--";
  double? batterySoc;
  bool isLoopRunning = false;
  bool isSlowConnection = false;
  bool isPotLocked = false;
  double boxVolume = 0.0;

  double? impedanceA;
  double? impedanceB;
  double? impedanceC;
  double? impedanceD;

  BoxStatus(this.index);
}

class DeviceProvider with ChangeNotifier, WidgetsBindingObserver {
  late final BackgroundApiCompatibility api = BackgroundApiCompatibility(this);
  SettingsProvider settings;

  final List<BoxStatus> boxes = [BoxStatus(0), BoxStatus(1)];

  // Active Focused Box Status Getters (for backwards compatibility)
  BoxStatus get activeBoxStatus => boxes[settings.activeUiBoxIndex];

  String get connectionStatus => activeBoxStatus.connectionStatus;
  String get firmwareVersion => activeBoxStatus.firmwareVersion;
  String get temperature => activeBoxStatus.temperature;
  String get batteryVoltage => activeBoxStatus.batteryVoltage;
  double? get batterySoc => activeBoxStatus.batterySoc;
  bool get isLoopRunning => activeBoxStatus.isLoopRunning;
  bool get isSlowConnection => activeBoxStatus.isSlowConnection;
  bool get isPotLocked => activeBoxStatus.isPotLocked;
  double get boxVolume => activeBoxStatus.boxVolume;
  double? get impedanceA => activeBoxStatus.impedanceA;
  double? get impedanceB => activeBoxStatus.impedanceB;
  double? get impedanceC => activeBoxStatus.impedanceC;
  double? get impedanceD => activeBoxStatus.impedanceD;

  final List<String> capturedLogs = [];
  bool isRecordingLogs = false;
  bool isShowingErrorDialog = false;
  String? lastErrorMessage;
  static const int _kMaxLogRows = 1000;
  Timer? _logInactivityTimer;
  Timer? _periodicSyncTimer;

  // Desktop: subscription to in-process service stream.
  StreamSubscription<Map<String, dynamic>>? _desktopSub;

  /// Master volume (0–1). Not persisted — resets to 0.1 on app restart/connect.
  double volume = 0.1;

  DeviceProvider(this.settings) {
    WidgetsBinding.instance.addObserver(this);

    if (Platform.isAndroid) {
      FlutterForegroundTask.addTaskDataCallback(_handleBackgroundMessage);
    } else {
      _desktopSub = DesktopServiceManager.messageStream
          .listen(_handleBackgroundMessage);
    }

    checkExistingConnection();
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (await ServiceManager.isRunning) {
        ServiceManager.sendCommand('requestState');
      }
    });
  }

  @override
  void dispose() {
    _periodicSyncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    if (Platform.isAndroid) {
      FlutterForegroundTask.removeTaskDataCallback(_handleBackgroundMessage);
    } else {
      _desktopSub?.cancel();
    }

    _logInactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkExistingConnection();
    }
  }

  Future<void> checkExistingConnection() async {
    if (await ServiceManager.isRunning) {
      ServiceManager.sendCommand('requestState');
      _syncSettingsToBackground();
    }
  }

  void _syncSettingsToBackground() {
    for (int i = 0; i < 2; i++) {
      ServiceManager.sendCommand('updateSettings', {
        'boxIndex': i,
        'device': settings.boxes[i].device.toJson(),
        'pulse': settings.boxes[i].pulse.toJson(),
        'cockpit': settings.boxes[i].cockpit.toJson(),
        'cockpit4Phase': settings.boxes[i].cockpit4Phase.toJson(),
        'deviceBehavior': settings.deviceBehavior.toJson(),
      });
    }
  }

  void _handleBackgroundMessage(dynamic msg) {
    if (msg is! Map) return;

    final type = msg['type'];
    final int boxIndex = msg['boxIndex'] as int? ?? 0;
    final box = boxes[boxIndex];

    switch (type) {
      case 'stateUpdate':
        box.connectionStatus =
            msg['connectionStatus'] as String? ?? box.connectionStatus;
        box.firmwareVersion =
            msg['firmwareVersion'] as String? ?? box.firmwareVersion;
        box.isLoopRunning =
            msg['isLoopRunning'] as bool? ?? box.isLoopRunning;
        box.isSlowConnection =
            msg['isSlowConnection'] as bool? ?? box.isSlowConnection;
        box.isPotLocked = msg['isPotLocked'] as bool? ?? box.isPotLocked;
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
        if (isRecordingLogs) {
          _logInactivityTimer?.cancel();
          _logInactivityTimer = Timer(const Duration(seconds: 5), () {
            if (isRecordingLogs) {
              isRecordingLogs = false;
              capturedLogs.add(
                  "${DateTime.now().toIso8601String()} [INFO] Recording stopped due to inactivity.");
              notifyListeners();
            }
          });
        }

        if (msg.containsKey('impedanceA')) {
          box.impedanceA = (msg['impedanceA'] as num?)?.toDouble();
        }
        if (msg.containsKey('impedanceB')) {
          box.impedanceB = (msg['impedanceB'] as num?)?.toDouble();
        }
        if (msg.containsKey('impedanceC')) {
          box.impedanceC = (msg['impedanceC'] as num?)?.toDouble();
        }
        if (msg.containsKey('impedanceD')) {
          box.impedanceD = (msg['impedanceD'] as num?)?.toDouble();
        }
        if (msg.containsKey('temperature')) {
          box.temperature = msg['temperature'] as String;
        }
        if (msg.containsKey('batteryVoltage')) {
          box.batteryVoltage = msg['batteryVoltage'] as String;
        }
        if (msg.containsKey('batterySoc')) {
          box.batterySoc = (msg['batterySoc'] as num?)?.toDouble();
        }
        if (msg.containsKey('boxVolume')) {
          box.boxVolume = (msg['boxVolume'] as num).toDouble();
        }
        if (msg.containsKey('isPotLocked')) {
          box.isPotLocked = msg['isPotLocked'] as bool;
        }
        if (msg.containsKey('debugMessage')) {
          final dbgMsg = msg['debugMessage'] as String;
          _log.d("Device $boxIndex: $dbgMsg");

          if (isRecordingLogs && capturedLogs.length < _kMaxLogRows) {
            capturedLogs.add(
                "${DateTime.now().toIso8601String()} [Device $boxIndex Debug] $dbgMsg");
          }

          if (dbgMsg.contains("Current limit exceeded") ||
              dbgMsg.contains("Producer too slow")) {
            if (!isRecordingLogs) {
              lastErrorMessage = "[Box ${boxIndex + 1}] $dbgMsg";
              isRecordingLogs = true;
              capturedLogs.clear();
              capturedLogs.add(
                  "${DateTime.now().toIso8601String()} [INITIAL_ERROR] [Box ${boxIndex + 1}] $dbgMsg");
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
    final targets =
        settings.linkDevicesEnabled ? [0, 1] : [settings.activeUiBoxIndex];
    for (var i in targets) {
      settings.boxes[i].cockpit.patternIndex = idx;
      ServiceManager.sendCommand(
          'selectPattern', {'boxIndex': i, 'index': idx});
    }
    settings.saveSettings();
    notifyListeners();
  }

  void setVelocity(double v) {
    final speed = v.clamp(0.1, 4.0);
    final targets =
        settings.linkDevicesEnabled ? [0, 1] : [settings.activeUiBoxIndex];
    for (var i in targets) {
      settings.boxes[i].cockpit.velocity = speed;
      ServiceManager.sendCommand(
          'setVelocity', {'boxIndex': i, 'velocity': speed});
    }
    settings.saveSettings();
    notifyListeners();
  }

  void updatePulseModConfig(PulseModulationConfig config) {
    final targets =
        settings.linkDevicesEnabled ? [0, 1] : [settings.activeUiBoxIndex];
    for (var i in targets) {
      settings.boxes[i].cockpit.pulseFreqMod = config;
      ServiceManager.sendCommand('updatePulseModConfig',
          {'boxIndex': i, 'config': config.toJson()});
    }
    settings.saveSettings();
    notifyListeners();
  }

  // ── 4-phase cockpit ──────────────────────────────────────────────────────

  void select4PhasePattern(int index) {
    final idx = index.clamp(0, FourphasePatternRegistry.all.length - 1);
    final targets =
        settings.linkDevicesEnabled ? [0, 1] : [settings.activeUiBoxIndex];
    for (var i in targets) {
      settings.boxes[i].cockpit4Phase.patternIndex = idx;
      ServiceManager.sendCommand(
          'select4PhasePattern', {'boxIndex': i, 'index': idx});
    }
    settings.saveSettings();
    notifyListeners();
  }

  void set4PhaseVelocity(double v) {
    final speed = v.clamp(0.1, 4.0);
    final targets =
        settings.linkDevicesEnabled ? [0, 1] : [settings.activeUiBoxIndex];
    for (var i in targets) {
      settings.boxes[i].cockpit4Phase.velocity = speed;
      ServiceManager.sendCommand(
          'set4PhaseVelocity', {'boxIndex': i, 'velocity': speed});
    }
    settings.saveSettings();
    notifyListeners();
  }

  void update4PhasePulseModConfig(PulseModulationConfig config) {
    final targets =
        settings.linkDevicesEnabled ? [0, 1] : [settings.activeUiBoxIndex];
    for (var i in targets) {
      settings.boxes[i].cockpit4Phase.pulseFreqMod = config;
      ServiceManager.sendCommand('update4PhasePulseModConfig',
          {'boxIndex': i, 'config': config.toJson()});
    }
    settings.saveSettings();
    notifyListeners();
  }

  // ── Volume ───────────────────────────────────────────────────────────────

  void setVolume(double v) {
    volume = v.clamp(0.0, 1.0);
    final targets =
        settings.linkDevicesEnabled ? [0, 1] : [settings.activeUiBoxIndex];
    for (var i in targets) {
      ServiceManager.sendCommand('setVolume', {'boxIndex': i, 'volume': volume});
    }
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
    final summary =
        "FOC Companion Diagnostic Summary:\n$topText\n... (Full log attached)";

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

  Future<void> connect({int? boxIndex}) async {
    final targetIndex = boxIndex ?? settings.activeUiBoxIndex;
    final boxProfile = settings.boxes[targetIndex];

    boxes[targetIndex].connectionStatus = "Starting service...";
    notifyListeners();

    try {
      final success = await ServiceManager.start();
      if (!success) {
        boxes[targetIndex].connectionStatus = "Error: Permission Denied";
        notifyListeners();
        return;
      }

      _syncSettingsToBackground();

      ServiceManager.sendCommand('setDeviceMode', {
        'boxIndex': targetIndex,
        'mode': boxProfile.device.deviceMode.name,
      });
      ServiceManager.sendCommand(
          'setVolume', {'boxIndex': targetIndex, 'volume': volume});
      ServiceManager.sendCommand('selectPattern',
          {'boxIndex': targetIndex, 'index': boxProfile.cockpit.patternIndex});
      ServiceManager.sendCommand('select4PhasePattern', {
        'boxIndex': targetIndex,
        'index': boxProfile.cockpit4Phase.patternIndex,
      });
      ServiceManager.sendCommand('setVelocity',
          {'boxIndex': targetIndex, 'velocity': boxProfile.cockpit.velocity});
      ServiceManager.sendCommand('set4PhaseVelocity', {
        'boxIndex': targetIndex,
        'velocity': boxProfile.cockpit4Phase.velocity,
      });
      ServiceManager.sendCommand('updatePulseModConfig', {
        'boxIndex': targetIndex,
        'config': boxProfile.cockpit.pulseFreqMod.toJson(),
      });
      ServiceManager.sendCommand('update4PhasePulseModConfig', {
        'boxIndex': targetIndex,
        'config': boxProfile.cockpit4Phase.pulseFreqMod.toJson(),
      });

      boxes[targetIndex].connectionStatus = "Connecting...";
      notifyListeners();

      if (boxProfile.connection.useSerial) {
        ServiceManager.sendCommand('connectSerial', {
          'boxIndex': targetIndex,
          'portName': boxProfile.connection.serialPort,
        });
      } else {
        ServiceManager.sendCommand('connect', {
          'boxIndex': targetIndex,
          'ip': boxProfile.connection.wifiIp,
          'port': boxProfile.connection.wifiPort,
        });
      }
    } catch (e) {
      boxes[targetIndex].connectionStatus = "Error: $e";
      notifyListeners();
    }
  }

  void setActiveUiBoxIndex(int index) {
    settings.setActiveUiBoxIndex(index);
    notifyListeners();
  }

  DeviceMode get deviceMode => settings.device.deviceMode;

  void setDeviceMode(DeviceMode mode) {
    final targets =
        settings.linkDevicesEnabled ? [0, 1] : [settings.activeUiBoxIndex];
    for (var i in targets) {
      settings.boxes[i].device.deviceMode = mode;
      ServiceManager.sendCommand(
          'setDeviceMode', {'boxIndex': i, 'mode': mode.name});
    }
    settings.saveSettings();
    notifyListeners();
  }

  Future<void> disconnect({int? boxIndex}) async {
    final targetIndex = boxIndex ?? settings.activeUiBoxIndex;

    ServiceManager.sendCommand('disconnect', {'boxIndex': targetIndex});

    boxes[targetIndex].connectionStatus = "Disconnected";
    boxes[targetIndex].isLoopRunning = false;
    boxes[targetIndex].isSlowConnection = false;
    boxes[targetIndex].impedanceA =
        boxes[targetIndex].impedanceB =
            boxes[targetIndex].impedanceC =
                boxes[targetIndex].impedanceD = null;
    notifyListeners();

    final anyConnected =
        boxes.any((b) => b.connectionStatus != "Disconnected");
    if (!anyConnected) {
      _logInactivityTimer?.cancel();
      isRecordingLogs = false;
      await ServiceManager.stop();
    }
  }

  Future<void> toggleLoop() async {
    final targets =
        settings.linkDevicesEnabled ? [0, 1] : [settings.activeUiBoxIndex];
    for (var i in targets) {
      ServiceManager.sendCommand('toggleLoop', {'boxIndex': i});
    }
  }

  Future<void> togglePotLock() async {
    final targets =
        settings.linkDevicesEnabled ? [0, 1] : [settings.activeUiBoxIndex];
    for (var i in targets) {
      ServiceManager.sendCommand('togglePotLock', {'boxIndex': i});
    }
  }
}
