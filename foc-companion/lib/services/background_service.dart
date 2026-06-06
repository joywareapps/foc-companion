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

class FocStimTaskHandler extends TaskHandler {
  FocStimApiService? _api;
  SettingsProvider? _settings;
  CommandLoop? _threePhaseLoop;
  FourPhaseCommandLoop? _fourPhaseLoop;

  // Active state
  String _connectionStatus = "Disconnected";
  String _firmwareVersion = "";
  bool _isLoopRunning = false;
  bool _isSlowConnection = false;
  bool _isPotLocked = false;
  DeviceMode _deviceMode = DeviceMode.threePhase;

  // Cache settings behavior to handle buttons in background
  DeviceBehaviorSettings _deviceBehavior = DeviceBehaviorSettings();

  // Button tracking
  int? _buttonEventTimestampMs;
  DateTime? _buttonEventDateTime;

  Timer? _notificationWatchdog;

  // Cache telemetry data to resend on requestState
  final Map<String, dynamic> _lastTelemetry = {};

  static double _calcImpedance(double r, double x) =>
      math.sqrt(r * r + x * x);

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _api = FocStimApiService();
    _settings = SettingsProvider(); // Safe stub provider

    _threePhaseLoop = CommandLoop(_api!, _settings!);
    _fourPhaseLoop = FourPhaseCommandLoop(_api!, _settings!);

    // Wire up loops
    _threePhaseLoop!.onSlowConnection = _handleSlowConnection;
    _threePhaseLoop!.onTimeout = _handleLoopTimeout;
    _fourPhaseLoop!.onSlowConnection = _handleSlowConnection;
    _fourPhaseLoop!.onTimeout = _handleLoopTimeout;

    _api!.onNotification = _handleNotification;
    _api!.onDisconnect = _handleDisconnect;
    _api!.onError = _handleError;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // We do not rely on periodic repeat ticks of foreground task
    // because our CommandLoop runs its own high-frequency 30 Hz timers.
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _notificationWatchdog?.cancel();
    await _stopStimulation();
    _disconnect();
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'disconnect') {
      _logToMain("Disconnect requested via notification.");
      _disconnect();
      FlutterForegroundTask.stopService();
    } else if (id == 'stop_stimulation') {
      _logToMain("Stop stimulation requested via notification.");
      _stopStimulation();
      _sendStateUpdate();
      _updateNotificationDetails(null);
    }
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map) {
      final type = data['type'];
      switch (type) {
        case 'requestState':
          _sendStateUpdate();
          if (_lastTelemetry.isNotEmpty) {
            FlutterForegroundTask.sendDataToMain({
              ..._lastTelemetry,
              'type': 'notification',
            });
          }
          break;
        case 'connect':
          final ip = data['ip'] as String;
          final port = data['port'] as int;
          _connect(ip, port);
          break;
        case 'disconnect':
          _disconnect();
          break;
        case 'toggleLoop':
          _toggleLoop();
          break;
        case 'setVolume':
          final vol = (data['volume'] as num).toDouble();
          _threePhaseLoop?.volume = vol;
          _fourPhaseLoop?.volume = vol;
          break;
        case 'setVelocity':
          final vel = (data['velocity'] as num).toDouble();
          _threePhaseLoop?.velocity = vel;
          break;
        case 'set4PhaseVelocity':
          final vel = (data['velocity'] as num).toDouble();
          _fourPhaseLoop?.velocity = vel;
          break;
        case 'selectPattern':
          final index = data['index'] as int;
          final idx = index.clamp(0, ThreephasePatternRegistry.all.length - 1);
          _threePhaseLoop?.pattern = ThreephasePatternRegistry.all[idx];
          break;
        case 'select4PhasePattern':
          final index = data['index'] as int;
          final idx = index.clamp(0, FourphasePatternRegistry.all.length - 1);
          _fourPhaseLoop?.pattern = FourphasePatternRegistry.all[idx];
          break;
        case 'updatePulseModConfig':
          final configMap = Map<String, dynamic>.from(data['config']);
          _threePhaseLoop?.setPulseModConfig(PulseModulationConfig.fromJson(configMap));
          break;
        case 'update4PhasePulseModConfig':
          final configMap = Map<String, dynamic>.from(data['config']);
          _fourPhaseLoop?.setPulseModConfig(PulseModulationConfig.fromJson(configMap));
          break;
        case 'togglePotLock':
          _togglePotLock();
          break;
        case 'setDeviceMode':
          final modeStr = data['mode'] as String;
          _deviceMode = DeviceMode.values.firstWhere(
            (e) => e.name == modeStr,
            orElse: () => DeviceMode.threePhase,
          );
          _sendStateUpdate();
          break;
        case 'updateSettings':
          if (data.containsKey('device')) {
            _settings?.device = DeviceSettings.fromJson(Map<String, dynamic>.from(data['device']));
          }
          if (data.containsKey('pulse')) {
            _settings?.pulse = PulseSettings.fromJson(Map<String, dynamic>.from(data['pulse']));
          }
          if (data.containsKey('deviceBehavior')) {
            _deviceBehavior = DeviceBehaviorSettings.fromJson(Map<String, dynamic>.from(data['deviceBehavior']));
          }
          break;
      }
    }
  }

  Future<void> _connect(String ip, int port) async {
    _connectionStatus = "Connecting...";
    _sendStateUpdate();
    _logToMain("Connecting to $ip:$port");
    try {
      await _api?.connectTcp(ip, port);
      _connectionStatus = "Checking firmware...";
      _sendStateUpdate();

      final resp = await _api!.requestFirmwareVersion();
      _api!.validateFirmwareVersion(resp);

      final v = resp.stm32FirmwareVersion2;
      _firmwareVersion = 'v${v.major}.${v.minor}.${v.revision} (${v.branch})';
      _connectionStatus = "Connected";
      _logToMain("Connected: $_firmwareVersion");

      _resetNotificationWatchdog();
      _sendStateUpdate();
      _updateNotificationDetails(null);
    } catch (e) {
      _connectionStatus = "Error: $e";
      _logToMain("Connection failed: $e");
      _disconnect();
    }
  }

  void _disconnect() {
    _notificationWatchdog?.cancel();
    _notificationWatchdog = null;
    _isLoopRunning = false;
    _isSlowConnection = false;
    _connectionStatus = "Disconnected";
    _threePhaseLoop?.stop().catchError((e) => null);
    _fourPhaseLoop?.stop().catchError((e) => null);
    _api?.disconnect();
    _sendStateUpdate();
    _updateNotificationDetails(null);
  }

  Future<void> _toggleLoop() async {
    if (_api == null || !_api!.isConnected) return;

    if (_isLoopRunning) {
      await _stopStimulation();
    } else {
      await _startStimulation();
    }
    _sendStateUpdate();
    _updateNotificationDetails(null);
  }

  Future<void> _startStimulation() async {
    try {
      if (_deviceMode == DeviceMode.fourPhase) {
        await _fourPhaseLoop?.start();
      } else {
        await _threePhaseLoop?.start();
      }
      _isLoopRunning = true;
      _logToMain("Stimulation started.");
    } catch (e) {
      _logToMain("Failed to start stimulation: $e");
      _isLoopRunning = false;
    }
  }

  Future<void> _stopStimulation() async {
    try {
      if (_deviceMode == DeviceMode.fourPhase) {
        await _fourPhaseLoop?.stop();
      } else {
        await _threePhaseLoop?.stop();
      }
      _isLoopRunning = false;
      _isSlowConnection = false;
      _logToMain("Stimulation stopped.");
    } catch (e) {
      _logToMain("Failed to stop stimulation: $e");
    }
  }

  void _resetNotificationWatchdog() {
    _notificationWatchdog?.cancel();
    if (_api != null && _api!.isConnected) {
      _notificationWatchdog = Timer(const Duration(seconds: 30), () {
        _logToMain("Watchdog: Device stopped responding.");
        _disconnect();
      });
    }
  }

  void _handleNotification(Notification n) {
    _resetNotificationWatchdog();

    final data = <String, dynamic>{
      'type': 'notification',
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
      _isPotLocked = n.notificationDeviceVolume.locked;
      data['isPotLocked'] = _isPotLocked;
    }

    if (n.hasNotificationButtonPress()) {
      final bp = n.notificationButtonPress;
      final firmwareTs = bp.timestampMs != 0 ? bp.timestampMs : null;
      if (bp.state == ButtonState.BUTTON_DOWN) {
        _buttonEventTimestampMs = firmwareTs;
        _buttonEventDateTime = firmwareTs == null ? DateTime.now() : null;
      } else if (bp.state == ButtonState.BUTTON_UP) {
        final downFirmwareTs = _buttonEventTimestampMs;
        final downDateTime = _buttonEventDateTime;
        _buttonEventTimestampMs = firmwareTs;
        _buttonEventDateTime = firmwareTs == null ? DateTime.now() : null;

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
          _executeButtonAction(action);
        }
      }
    }

    if (n.hasNotificationDebugString()) {
      final msg = n.notificationDebugString.message;
      data['debugMessage'] = msg;
    }

    // Cache telemetry (excluding 'type')
    final cacheData = Map<String, dynamic>.from(data)..remove('type');
    _lastTelemetry.addAll(cacheData);

    FlutterForegroundTask.sendDataToMain(data);
    _updateNotificationDetails(n);
  }

  void _updateNotificationDetails(Notification? n) {
    if (_connectionStatus != "Connected") {
      FlutterForegroundTask.updateService(
        notificationTitle: "FOC Companion - $_connectionStatus",
        notificationText: _connectionStatus == "Connecting..."
            ? "Establishing link..."
            : "Disconnected from device.",
        notificationButtons: [
          const NotificationButton(id: 'disconnect', text: 'Dismiss'),
        ],
      );
      return;
    }

    String stateStr = _isLoopRunning ? "Playing" : "Connected";
    String detailsStr = "";

    if (_isLoopRunning) {
      String patternName = "";
      if (_deviceMode == DeviceMode.fourPhase) {
        patternName = _fourPhaseLoop?.pattern.name ?? "4-Phase";
      } else {
        patternName = _threePhaseLoop?.pattern.name ?? "3-Phase";
      }
      detailsStr = "Stimulating: $patternName";
    } else {
      detailsStr = "Connected | Idle";
    }

    if (n != null && n.hasNotificationBattery()) {
      final soc = (n.notificationBattery.batterySoc * 100).toInt();
      detailsStr += " | Battery: $soc%";
    }

    FlutterForegroundTask.updateService(
      notificationTitle: "FOC Companion - $stateStr",
      notificationText: detailsStr,
      notificationButtons: _isLoopRunning
          ? [
              const NotificationButton(id: 'stop_stimulation', text: 'Stop'),
            ]
          : [
              const NotificationButton(id: 'disconnect', text: 'Disconnect'),
            ],
    );
  }

  void _executeButtonAction(ButtonAction action) {
    _logToMain("Button action: $action");
    switch (action) {
      case ButtonAction.nothing:
        break;
      case ButtonAction.togglePlayPause:
        _toggleLoop();
        break;
      case ButtonAction.toggleVolumeLock:
        _togglePotLock();
        break;
    }
  }

  Future<void> _togglePotLock() async {
    if (_api == null || !_api!.isConnected) return;
    try {
      await _api!.lockDeviceVolume(!_isPotLocked);
    } catch (e) {
      _logToMain("Failed to toggle pot lock: $e");
    }
  }

  void _sendStateUpdate() {
    FlutterForegroundTask.sendDataToMain({
      'type': 'stateUpdate',
      'connectionStatus': _connectionStatus,
      'firmwareVersion': _firmwareVersion,
      'isLoopRunning': _isLoopRunning,
      'isSlowConnection': _isSlowConnection,
      'isPotLocked': _isPotLocked,
    });
  }

  void _logToMain(String message) {
    FlutterForegroundTask.sendDataToMain({
      'type': 'log',
      'message': message,
    });
  }

  void _handleSlowConnection(bool slow) {
    if (_isSlowConnection == slow) return;
    _isSlowConnection = slow;
    _sendStateUpdate();
  }

  void _handleLoopTimeout(String error) {
    _logToMain("[TIMEOUT_ERROR] $error");
    _isLoopRunning = false;
    _isSlowConnection = false;
    _connectionStatus = "Timeout: $error";
    _api?.stopSignal().catchError((e) => null);
    _sendStateUpdate();
    _updateNotificationDetails(null);
  }

  void _handleDisconnect() {
    _disconnect();
  }

  void _handleError(String err) {
    _connectionStatus = "Error: $err";
    _logToMain("Socket error: $err");
    _disconnect();
  }
}
