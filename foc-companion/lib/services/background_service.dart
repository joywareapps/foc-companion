import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:foc_companion/services/focstim_api_service.dart';
import 'package:foc_companion/core/command_loop.dart';
import 'package:foc_companion/core/patterns.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/generated/protobuf/focstim_rpc.pb.dart';
import 'package:foc_companion/generated/protobuf/constants.pbenum.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(FocStimTaskHandler());
}

class BackgroundServiceManager {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foc_stim_service',
        channelName: 'FOC Stim Service',
        channelDescription: 'FOC Companion active background service',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        playSound: false,
        enableVibration: false,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
    _initialized = true;
  }

  static Future<bool> start() async {
    await init();
    
    // Request notification permission if needed
    final notificationPermission = await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      final requested = await FlutterForegroundTask.requestNotificationPermission();
      if (requested != NotificationPermission.granted) {
        return false;
      }
    }

    if (await FlutterForegroundTask.isRunningService) {
      return true;
    }

    final startResult = await FlutterForegroundTask.startService(
      notificationTitle: 'FOC Companion',
      notificationText: 'Service starting...',
      notificationButtons: [
        const NotificationButton(id: 'disconnect', text: 'Disconnect'),
      ],
      callback: startCallback,
    );

    return startResult is ServiceRequestSuccess;
  }

  static Future<void> stop() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  static void sendCommand(String type, [Map<String, dynamic>? data]) {
    final msg = <String, dynamic>{'type': type};
    if (data != null) {
      msg.addAll(data);
    }
    FlutterForegroundTask.sendDataToTask(msg);
  }
}

class ActiveBoxState {
  final int index;
  final FocStimApiService api = FocStimApiService();
  late final CommandLoop threePhaseLoop;
  late final FourPhaseCommandLoop fourPhaseLoop;

  String connectionStatus = "Disconnected";
  String firmwareVersion = "";
  bool isLoopRunning = false;
  bool isSlowConnection = false;
  bool isPotLocked = false;
  DeviceMode deviceMode = DeviceMode.threePhase;

  /// Funscript playback state (updated from foreground via commands).
  bool funscriptActive = false;
  Map<String, double> funscriptValues = {};  // axis suffix → normalized 0.0-1.0

  int? buttonEventTimestampMs;
  DateTime? buttonEventDateTime;
  Timer? notificationWatchdog;
  final Map<String, dynamic> lastTelemetry = {};

  DateTime lastNotificationUpdateTime = DateTime.fromMillisecondsSinceEpoch(0);
  bool? lastIsLoopRunningState;

  ActiveBoxState(this.index, SettingsProvider settings) {
    threePhaseLoop = CommandLoop(api, settings)..boxIndex = index;
    threePhaseLoop.isFunscriptActive = () => funscriptActive;
    threePhaseLoop.getFunscriptValues = () => funscriptValues;
    fourPhaseLoop = FourPhaseCommandLoop(api, settings)..boxIndex = index;
  }
}

class FocStimTaskHandler extends TaskHandler {
  final Map<int, ActiveBoxState> _boxes = {};
  SettingsProvider? _settings;
  DateTime _lastGlobalNotificationUpdateTime = DateTime.fromMillisecondsSinceEpoch(0);

  // Cache settings behavior to handle buttons in background
  DeviceBehaviorSettings _deviceBehavior = DeviceBehaviorSettings();

  static double _calcImpedance(double r, double x) =>
      math.sqrt(r * r + x * x);

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _settings = SettingsProvider(); // Safe stub provider

    for (int i = 0; i < 2; i++) {
      final box = ActiveBoxState(i, _settings!);
      _boxes[i] = box;

      box.threePhaseLoop.onSlowConnection = (slow) => _handleSlowConnection(i, slow);
      box.threePhaseLoop.onTimeout = (err) => _handleLoopTimeout(i, err);
      box.fourPhaseLoop.onSlowConnection = (slow) => _handleSlowConnection(i, slow);
      box.fourPhaseLoop.onTimeout = (err) => _handleLoopTimeout(i, err);

      box.api.onNotification = (n) => _handleNotification(i, n);
      box.api.onDisconnect = () => _handleDisconnect(i);
      box.api.onError = (err) => _handleError(i, err);
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // We do not rely on periodic repeat ticks of foreground task
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    for (int i = 0; i < 2; i++) {
      _boxes[i]?.notificationWatchdog?.cancel();
      await _stopStimulation(i);
      _disconnect(i);
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'disconnect') {
      _logToMain(0, "Disconnect requested via notification.");
      _disconnect(0);
      _disconnect(1);
      FlutterForegroundTask.stopService();
    } else if (id == 'stop_stimulation') {
      _logToMain(0, "Stop stimulation requested via notification.");
      _stopStimulation(0);
      _stopStimulation(1);
      _sendStateUpdate(0);
      _sendStateUpdate(1);
      _updateNotificationDetails();
    }
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map) {
      final type = data['type'];
      switch (type) {
        case 'requestState':
          for (int i = 0; i < 2; i++) {
            _sendStateUpdate(i);
            final box = _boxes[i]!;
            if (box.lastTelemetry.isNotEmpty) {
              FlutterForegroundTask.sendDataToMain({
                ...box.lastTelemetry,
                'type': 'notification',
                'boxIndex': i,
              });
            }
          }
          break;
        case 'connect':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final ip = data['ip'] as String;
          final port = data['port'] as int;
          _connect(boxIndex, ip, port);
          break;
        case 'disconnect':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          _disconnect(boxIndex);
          break;
        case 'toggleLoop':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          _toggleLoop(boxIndex);
          break;
        case 'setVolume':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final vol = (data['volume'] as num).toDouble();
          final box = _boxes[boxIndex]!;
          box.threePhaseLoop.volume = vol;
          box.fourPhaseLoop.volume = vol;
          break;
        case 'setVelocity':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final vel = (data['velocity'] as num).toDouble();
          final box = _boxes[boxIndex]!;
          box.threePhaseLoop.velocity = vel;
          break;
        case 'set4PhaseVelocity':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final vel = (data['velocity'] as num).toDouble();
          final box = _boxes[boxIndex]!;
          box.fourPhaseLoop.velocity = vel;
          break;
        case 'selectPattern':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final index = data['index'] as int;
          final idx = index.clamp(0, ThreephasePatternRegistry.all.length - 1);
          final box = _boxes[boxIndex]!;
          box.threePhaseLoop.pattern = ThreephasePatternRegistry.all[idx];
          break;
        case 'select4PhasePattern':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final index = data['index'] as int;
          final idx = index.clamp(0, FourphasePatternRegistry.all.length - 1);
          final box = _boxes[boxIndex]!;
          box.fourPhaseLoop.pattern = FourphasePatternRegistry.all[idx];
          break;
        case 'updatePulseModConfig':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final configMap = Map<String, dynamic>.from(data['config']);
          final box = _boxes[boxIndex]!;
          box.threePhaseLoop.setPulseModConfig(PulseModulationConfig.fromJson(configMap));
          break;
        case 'update4PhasePulseModConfig':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final configMap = Map<String, dynamic>.from(data['config']);
          final box = _boxes[boxIndex]!;
          box.fourPhaseLoop.setPulseModConfig(PulseModulationConfig.fromJson(configMap));
          break;
        case 'togglePotLock':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          _togglePotLock(boxIndex);
          break;
        case 'setDeviceMode':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final modeStr = data['mode'] as String;
          final box = _boxes[boxIndex]!;
          box.deviceMode = DeviceMode.values.firstWhere(
            (e) => e.name == modeStr,
            orElse: () => DeviceMode.threePhase,
          );
          _sendStateUpdate(boxIndex);
          break;
        case 'updateSettings':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final box = _settings?.boxes[boxIndex];
          if (box != null) {
            if (data.containsKey('device')) {
              box.device = DeviceSettings.fromJson(Map<String, dynamic>.from(data['device']));
            }
            if (data.containsKey('pulse')) {
              box.pulse = PulseSettings.fromJson(Map<String, dynamic>.from(data['pulse']));
            }
            if (data.containsKey('cockpit')) {
              box.cockpit = CockpitSettings.fromJson(Map<String, dynamic>.from(data['cockpit']));
            }
            if (data.containsKey('cockpit4Phase')) {
              box.cockpit4Phase = CockpitSettings.fromJson(Map<String, dynamic>.from(data['cockpit4Phase']));
            }
          }
          if (data.containsKey('deviceBehavior')) {
            _deviceBehavior = DeviceBehaviorSettings.fromJson(Map<String, dynamic>.from(data['deviceBehavior']));
          }
          break;
        case 'startFunscriptPlayback':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          _startFunscriptPlayback(boxIndex);
          break;
        case 'stopFunscriptPlayback':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          _stopFunscriptPlayback(boxIndex);
          break;
        case 'pauseFunscriptPlayback':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          _pauseFunscriptPlayback(boxIndex);
          break;
        case 'setFunscriptMode':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final box = _boxes[boxIndex];
          if (box != null) {
            box.funscriptActive = data['active'] as bool? ?? false;
            if (!box.funscriptActive) box.funscriptValues.clear();
          }
          break;
        case 'updateFunscriptValues':
          final int boxIndex = data['boxIndex'] as int? ?? 0;
          final box = _boxes[boxIndex];
          if (box != null && box.funscriptActive) {
            final values = data['values'] as Map?;
            if (values != null) {
              box.funscriptValues = Map<String, double>.from(
                values.map((k, v) => MapEntry(k as String, (v as num).toDouble())),
              );
            }
          }
          break;
      }
    }
  }

  Future<void> _connect(int boxIndex, String ip, int port) async {
    final box = _boxes[boxIndex]!;
    box.connectionStatus = "Connecting...";
    _sendStateUpdate(boxIndex);
    _logToMain(boxIndex, "Connecting to $ip:$port");
    try {
      await box.api.connectTcp(ip, port);
      box.connectionStatus = "Checking firmware...";
      _sendStateUpdate(boxIndex);

      final resp = await box.api.requestFirmwareVersion();
      box.api.validateFirmwareVersion(resp);

      final v = resp.stm32FirmwareVersion2;
      box.firmwareVersion = 'v${v.major}.${v.minor}.${v.revision} (${v.branch})';
      box.connectionStatus = "Connected";
      _logToMain(boxIndex, "Connected: ${box.firmwareVersion}");

      _resetNotificationWatchdog(boxIndex);
      _sendStateUpdate(boxIndex);
      _updateNotificationDetails();
    } catch (e) {
      box.connectionStatus = "Error: $e";
      _logToMain(boxIndex, "Connection failed: $e");
      _disconnect(boxIndex);
    }
  }

  void _disconnect(int boxIndex) {
    final box = _boxes[boxIndex]!;
    box.notificationWatchdog?.cancel();
    box.notificationWatchdog = null;
    box.isLoopRunning = false;
    box.isSlowConnection = false;
    box.connectionStatus = "Disconnected";
    box.threePhaseLoop.stop().catchError((e) => null);
    box.fourPhaseLoop.stop().catchError((e) => null);
    box.api.disconnect();
    _sendStateUpdate(boxIndex);
    _updateNotificationDetails();
  }

  Future<void> _toggleLoop(int boxIndex) async {
    final box = _boxes[boxIndex]!;
    if (!box.api.isConnected) return;

    if (box.isLoopRunning) {
      await _stopStimulation(boxIndex);
    } else {
      await _startStimulation(boxIndex);
    }
    _sendStateUpdate(boxIndex);
    _updateNotificationDetails();
  }

  Future<void> _startStimulation(int boxIndex) async {
    final box = _boxes[boxIndex]!;
    try {
      if (box.deviceMode == DeviceMode.fourPhase) {
        await box.fourPhaseLoop.start();
      } else {
        await box.threePhaseLoop.start();
      }
      box.isLoopRunning = true;
      _logToMain(boxIndex, "Stimulation started.");
    } catch (e) {
      _logToMain(boxIndex, "Failed to start stimulation: $e");
      box.isLoopRunning = false;
    }
  }

  Future<void> _stopStimulation(int boxIndex) async {
    final box = _boxes[boxIndex]!;
    try {
      if (box.deviceMode == DeviceMode.fourPhase) {
        await box.fourPhaseLoop.stop();
      } else {
        await box.threePhaseLoop.stop();
      }
      box.isLoopRunning = false;
      box.isSlowConnection = false;
      _logToMain(boxIndex, "Stimulation stopped.");
    } catch (e) {
      _logToMain(boxIndex, "Failed to stop stimulation: $e");
    }
  }

  void _resetNotificationWatchdog(int boxIndex) {
    final box = _boxes[boxIndex]!;
    box.notificationWatchdog?.cancel();
    if (box.api.isConnected) {
      box.notificationWatchdog = Timer(const Duration(seconds: 30), () {
        _logToMain(boxIndex, "Watchdog: Device stopped responding.");
        _disconnect(boxIndex);
      });
    }
  }

  void _handleNotification(int boxIndex, Notification n) {
    final box = _boxes[boxIndex]!;
    _resetNotificationWatchdog(boxIndex);

    final data = <String, dynamic>{
      'type': 'notification',
      'boxIndex': boxIndex,
    };

    if (n.hasNotificationSkinResistance()) {
      final e = n.notificationSkinResistance;
      data['impedanceA'] = _calcImpedance(e.resistanceA, e.reluctanceA);
      data['impedanceB'] = _calcImpedance(e.resistanceB, e.reluctanceB);
      data['impedanceC'] = _calcImpedance(e.resistanceC, e.reluctanceC);
      data['impedanceD'] = (e.resistanceD == 0.0 && e.reluctanceD == 0.0)
          ? null
          : _calcImpedance(e.resistanceD, e.reluctanceD);
    }

    if (n.hasNotificationSystemStats()) {
      final stats = n.notificationSystemStats;
      double? temp;
      if (stats.hasFocstimv3()) {
        temp = stats.focstimv3.tempStm32;
      } else if (stats.hasEsc1()) {
        temp = stats.esc1.tempStm32;
      }
      if (temp != null) {
        data['temperature'] = "${temp.toStringAsFixed(1)}°C";
      }
    }

    if (n.hasNotificationBattery()) {
      data['batteryVoltage'] = "${n.notificationBattery.batteryVoltage.toStringAsFixed(2)}V";
      data['batterySoc'] = n.notificationBattery.batterySoc;
    }

    if (n.hasNotificationDeviceVolume()) {
      data['boxVolume'] = n.notificationDeviceVolume.volume;
      box.isPotLocked = n.notificationDeviceVolume.locked;
      data['isPotLocked'] = box.isPotLocked;
    }

    if (n.hasNotificationButtonPress()) {
      final bp = n.notificationButtonPress;
      final firmwareTs = bp.timestampMs != 0 ? bp.timestampMs : null;
      if (bp.state == ButtonState.BUTTON_DOWN) {
        box.buttonEventTimestampMs = firmwareTs;
        box.buttonEventDateTime = firmwareTs == null ? DateTime.now() : null;
      } else if (bp.state == ButtonState.BUTTON_UP) {
        final downFirmwareTs = box.buttonEventTimestampMs;
        final downDateTime = box.buttonEventDateTime;
        box.buttonEventTimestampMs = firmwareTs;
        box.buttonEventDateTime = firmwareTs == null ? DateTime.now() : null;

        int? ms;
        if (firmwareTs != null && downFirmwareTs != null) {
          ms = (firmwareTs - downFirmwareTs) & 0xFFFFFFFF;
        } else if (downDateTime != null) {
          ms = DateTime.now().difference(downDateTime).inMilliseconds;
        }

        if (ms != null) {
          final action = ms >= _deviceBehavior.longPressMillis
              ? _deviceBehavior.longPressAction
              : _deviceBehavior.shortPressAction;
          _executeButtonAction(boxIndex, action);
        }
      }
    }

    if (n.hasNotificationDebugString()) {
      final msg = n.notificationDebugString.message;
      data['debugMessage'] = msg;
    }

    // Cache telemetry (excluding 'type' and 'boxIndex')
    final cacheData = Map<String, dynamic>.from(data)..remove('type')..remove('boxIndex');
    box.lastTelemetry.addAll(cacheData);

    // ── Throttling: IPC telemetry to Main (10Hz) ──
    final now = DateTime.now();
    if (now.difference(box.lastNotificationUpdateTime).inMilliseconds >= 100) {
      box.lastNotificationUpdateTime = now;
      FlutterForegroundTask.sendDataToMain(data);
    }

    // ── Throttling: Foreground Notification (1Hz) ──
    if (now.difference(_lastGlobalNotificationUpdateTime).inMilliseconds >= 1000) {
      _lastGlobalNotificationUpdateTime = now;
      _updateNotificationDetails();
    }
  }

  void _updateNotificationDetails() {
    List<String> statuses = [];
    bool isAnyRunning = false;
    for (int i = 0; i < 2; i++) {
      final box = _boxes[i]!;
      String status = "Box ${i + 1}: ${box.connectionStatus}";
      if (box.connectionStatus == "Connected") {
        if (box.isLoopRunning) {
          status += " (Playing)";
          isAnyRunning = true;
        } else {
          status += " (Idle)";
        }
        if (box.lastTelemetry.containsKey('batterySoc')) {
          final soc = (box.lastTelemetry['batterySoc'] * 100).toInt();
          status += " $soc%";
        }
      }
      statuses.add(status);
    }

    String overallText = statuses.join(" | ");

    FlutterForegroundTask.updateService(
      notificationTitle: isAnyRunning ? "FOC Companion - Playing" : "FOC Companion",
      notificationText: overallText,
      notificationButtons: isAnyRunning
          ? [
              const NotificationButton(id: 'stop_stimulation', text: 'Stop All'),
            ]
          : [
              const NotificationButton(id: 'disconnect', text: 'Disconnect'),
            ],
    );
  }

  void _executeButtonAction(int boxIndex, ButtonAction action) {
    _logToMain(boxIndex, "Button action: $action");
    switch (action) {
      case ButtonAction.nothing:
        break;
      case ButtonAction.togglePlayPause:
        _toggleLoop(boxIndex);
        break;
      case ButtonAction.toggleVolumeLock:
        _togglePotLock(boxIndex);
        break;
    }
  }

  Future<void> _togglePotLock(int boxIndex) async {
    final box = _boxes[boxIndex]!;
    if (!box.api.isConnected) return;
    try {
      await box.api.lockDeviceVolume(!box.isPotLocked);
    } catch (e) {
      _logToMain(boxIndex, "Failed to toggle pot lock: $e");
    }
  }

  // ── Funscript playback ──────────────────────────────────────────────

  /// Start funscript playback: enable funscript mode and start the command loop.
  void _startFunscriptPlayback(int boxIndex) async {
    final box = _boxes[boxIndex];
    if (box == null || !box.api.isConnected) return;

    // Stop any running pattern first
    if (box.isLoopRunning) {
      await _stopStimulation(boxIndex);
    }

    // Enable funscript mode
    box.funscriptActive = true;
    box.funscriptValues.clear();

    // Start the command loop — it will read funscript values each tick
    await _startStimulation(boxIndex);
    _sendStateUpdate(boxIndex);
    _updateNotificationDetails();
    _logToMain(boxIndex, "Funscript playback started.");
  }

  /// Stop funscript playback: disable funscript mode and stop the command loop.
  void _stopFunscriptPlayback(int boxIndex) async {
    final box = _boxes[boxIndex];
    if (box == null) return;

    box.funscriptActive = false;
    box.funscriptValues.clear();

    await _stopStimulation(boxIndex);
    _sendStateUpdate(boxIndex);
    _updateNotificationDetails();
    _logToMain(boxIndex, "Funscript playback stopped.");
  }

  /// Pause funscript playback: stop the command loop.
  void _pauseFunscriptPlayback(int boxIndex) async {
    final box = _boxes[boxIndex];
    if (box == null) return;

    box.funscriptActive = false;
    box.funscriptValues.clear();

    await _stopStimulation(boxIndex);
    _sendStateUpdate(boxIndex);
    _updateNotificationDetails();
    _logToMain(boxIndex, "Funscript playback paused.");
  }

  void _sendStateUpdate(int boxIndex) {
    final box = _boxes[boxIndex]!;
    FlutterForegroundTask.sendDataToMain({
      'type': 'stateUpdate',
      'boxIndex': boxIndex,
      'connectionStatus': box.connectionStatus,
      'firmwareVersion': box.firmwareVersion,
      'isLoopRunning': box.isLoopRunning,
      'isSlowConnection': box.isSlowConnection,
      'isPotLocked': box.isPotLocked,
    });
  }

  void _logToMain(int boxIndex, String message) {
    FlutterForegroundTask.sendDataToMain({
      'type': 'log',
      'boxIndex': boxIndex,
      'message': message,
    });
  }

  void _handleSlowConnection(int boxIndex, bool slow) {
    final box = _boxes[boxIndex]!;
    if (box.isSlowConnection == slow) return;
    box.isSlowConnection = slow;
    _sendStateUpdate(boxIndex);
  }

  void _handleLoopTimeout(int boxIndex, String error) {
    final box = _boxes[boxIndex]!;
    _logToMain(boxIndex, "[TIMEOUT_ERROR] $error");
    box.isLoopRunning = false;
    box.isSlowConnection = false;
    box.connectionStatus = "Timeout: $error";
    box.api.stopSignal().catchError((e) => null);
    _sendStateUpdate(boxIndex);
    _updateNotificationDetails();
  }

  void _handleDisconnect(int boxIndex) {
    _disconnect(boxIndex);
  }

  void _handleError(int boxIndex, String err) {
    final box = _boxes[boxIndex]!;
    box.connectionStatus = "Error: $err";
    _logToMain(boxIndex, "Socket error: $err");
    _disconnect(boxIndex);
  }
}
