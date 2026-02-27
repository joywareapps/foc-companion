enum DeviceMode { threePhase, fourPhase }

enum ButtonAction { nothing, togglePlayPause, toggleVolumeLock }

class DeviceBehaviorSettings {
  ButtonAction shortPressAction;
  ButtonAction longPressAction;
  int longPressMillis;

  DeviceBehaviorSettings({
    this.shortPressAction = ButtonAction.nothing,
    this.longPressAction = ButtonAction.nothing,
    this.longPressMillis = 800,
  });

  Map<String, dynamic> toJson() => {
        'shortPressAction': shortPressAction.name,
        'longPressAction': longPressAction.name,
        'longPressMillis': longPressMillis,
      };

  DeviceBehaviorSettings.fromJson(Map<String, dynamic> json)
      : shortPressAction = ButtonAction.values.firstWhere(
            (e) => e.name == json['shortPressAction'],
            orElse: () => ButtonAction.nothing),
        longPressAction = ButtonAction.values.firstWhere(
            (e) => e.name == json['longPressAction'],
            orElse: () => ButtonAction.nothing),
        longPressMillis = (json['longPressMillis'] ?? 800) as int;
}

// ──────────────────────────────────────────────
// Pulse frequency modulation config
// (JSON-serialisable; String function field for SharedPreferences)
// ──────────────────────────────────────────────

class PulseModulationConfig {
  /// Active axes: 'off' | 'freq' | 'width' | 'both'
  String mode;
  String function; // 'sine' | 'triangle' | 'saw' | 'square'
  double speedMultiplier;
  double minHz;      // lower bound of frequency oscillation
  double maxHz;      // upper bound of frequency oscillation
  double minWidth;      // lower bound of width oscillation (cycles)
  double maxWidth;      // upper bound of width oscillation (cycles)
  int phaseShiftDeg;    // width phase offset relative to freq: 0 | 90 | 180 | 270
  double center;        // saw peak position (0–1)
  double dutyCycle;     // square duty cycle (0.1–0.9)

  PulseModulationConfig({
    this.mode = 'off',
    this.function = 'sine',
    this.speedMultiplier = 1.0,
    this.minHz = 20.0,
    this.maxHz = 80.0,
    this.minWidth = 3.0,
    this.maxWidth = 15.0,
    this.phaseShiftDeg = 180,
    this.center = 0.5,
    this.dutyCycle = 0.5,
  });

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'function': function,
        'speedMultiplier': speedMultiplier,
        'minHz': minHz,
        'maxHz': maxHz,
        'minWidth': minWidth,
        'maxWidth': maxWidth,
        'phaseShiftDeg': phaseShiftDeg,
        'center': center,
        'dutyCycle': dutyCycle,
      };

  PulseModulationConfig.fromJson(Map<String, dynamic> json)
      // Migrate old boolean 'enabled' field: true → 'freq', false → 'off'
      : mode = json['mode'] ?? (json['enabled'] == true ? 'freq' : 'off'),
        function = json['function'] ?? 'sine',
        speedMultiplier = (json['speedMultiplier'] ?? 1.0).toDouble(),
        minHz = (json['minHz'] ?? 20.0).toDouble(),
        maxHz = (json['maxHz'] ?? 80.0).toDouble(),
        minWidth = (json['minWidth'] ?? 3.0).toDouble(),
        maxWidth = (json['maxWidth'] ?? 15.0).toDouble(),
        phaseShiftDeg = (json['phaseShiftDeg'] ?? 180) as int,
        center = (json['center'] ?? 0.5).toDouble(),
        dutyCycle = (json['dutyCycle'] ?? 0.5).toDouble();
}

// ──────────────────────────────────────────────
// Cockpit settings (pattern picker, speed, modulation)
// ──────────────────────────────────────────────

class CockpitSettings {
  String name;
  int patternIndex; // index into ThreephasePatternRegistry.all
  double velocity;
  PulseModulationConfig pulseFreqMod;

  CockpitSettings({
    this.name = "Default",
    this.patternIndex = 0,
    this.velocity = 1.0,
    PulseModulationConfig? pulseFreqMod,
  }) : pulseFreqMod = pulseFreqMod ?? PulseModulationConfig();

  Map<String, dynamic> toJson() => {
        'name': name,
        'patternIndex': patternIndex,
        'velocity': velocity,
        'pulseFreqMod': pulseFreqMod.toJson(),
      };

  CockpitSettings.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? "Default",
        patternIndex = json['patternIndex'] ?? 0,
        velocity = (json['velocity'] ?? 1.0).toDouble(),
        pulseFreqMod = json['pulseFreqMod'] != null
            ? PulseModulationConfig.fromJson(json['pulseFreqMod'])
            : PulseModulationConfig();
}

// ──────────────────────────────────────────────
// Device settings
// ──────────────────────────────────────────────

class DeviceSettings {
  double minFrequency = 500;
  double maxFrequency = 1500;
  double waveformAmplitude = 0.120; // 120mA
  DeviceMode deviceMode = DeviceMode.threePhase;

  // 3-Phase calibration
  double calibration3Center = -0.5;
  double calibration3Up = 0.0;
  double calibration3Left = 0.0;

  // 4-Phase calibration
  double calibration4A = 0.0;
  double calibration4B = 0.0;
  double calibration4C = 0.0;
  double calibration4D = 0.0;

  Map<String, dynamic> toJson() => {
        'minFrequency': minFrequency,
        'maxFrequency': maxFrequency,
        'waveformAmplitude': waveformAmplitude,
        'deviceMode': deviceMode.name,
        'calibration3Center': calibration3Center,
        'calibration3Up': calibration3Up,
        'calibration3Left': calibration3Left,
        'calibration4A': calibration4A,
        'calibration4B': calibration4B,
        'calibration4C': calibration4C,
        'calibration4D': calibration4D,
      };

  DeviceSettings.fromJson(Map<String, dynamic> json) {
    minFrequency = json['minFrequency'] ?? 500;
    maxFrequency = json['maxFrequency'] ?? 1500;
    waveformAmplitude = json['waveformAmplitude'] ?? 0.120;
    deviceMode = DeviceMode.values.firstWhere(
      (e) => e.name == json['deviceMode'],
      orElse: () => DeviceMode.threePhase,
    );
    calibration3Center = json['calibration3Center'] ?? -0.5;
    calibration3Up = json['calibration3Up'] ?? 0.0;
    calibration3Left = json['calibration3Left'] ?? 0.0;
    calibration4A = json['calibration4A'] ?? 0.0;
    calibration4B = json['calibration4B'] ?? 0.0;
    calibration4C = json['calibration4C'] ?? 0.0;
    calibration4D = json['calibration4D'] ?? 0.0;
  }

  DeviceSettings();
}

// ──────────────────────────────────────────────
// Pulse settings
// ──────────────────────────────────────────────

class PulseSettings {
  double carrierFrequency = 700;
  double pulseFrequency = 50;
  double pulseWidth = 5;
  double pulseRiseTime = 3;
  double pulseIntervalRandom = 10;

  Map<String, dynamic> toJson() => {
        'carrierFrequency': carrierFrequency,
        'pulseFrequency': pulseFrequency,
        'pulseWidth': pulseWidth,
        'pulseRiseTime': pulseRiseTime,
        'pulseIntervalRandom': pulseIntervalRandom,
      };

  PulseSettings.fromJson(Map<String, dynamic> json) {
    carrierFrequency = json['carrierFrequency'] ?? 700;
    pulseFrequency = json['pulseFrequency'] ?? 50;
    pulseWidth = json['pulseWidth'] ?? 5;
    pulseRiseTime = json['pulseRiseTime'] ?? 3;
    pulseIntervalRandom = json['pulseIntervalRandom'] ?? 10;
  }

  PulseSettings();
}

// ──────────────────────────────────────────────
// Connection settings
// ──────────────────────────────────────────────

class FocStimSettings {
  String wifiIp = "192.168.1.1";
  int wifiPort = 55533;

  Map<String, dynamic> toJson() => {
    'wifiIp': wifiIp,
    'wifiPort': wifiPort,
  };

  FocStimSettings.fromJson(Map<String, dynamic> json) {
    wifiIp = json['wifiIp'] ?? "192.168.1.1";
    wifiPort = json['wifiPort'] ?? 55533;
  }

  FocStimSettings();
}

// ──────────────────────────────────────────────
// Media sync settings
// ──────────────────────────────────────────────

class MediaSyncSettings {
  bool hereSphereEnabled = false;
  String hereSphereIp = "";
  int hereSpherePort = 23554;
  List<FunscriptLocation> funscriptLocations = [];

  Map<String, dynamic> toJson() => {
    'hereSphereEnabled': hereSphereEnabled,
    'hereSphereIp': hereSphereIp,
    'hereSpherePort': hereSpherePort,
    'funscriptLocations': funscriptLocations.map((e) => e.toJson()).toList(),
  };

  MediaSyncSettings.fromJson(Map<String, dynamic> json) {
    hereSphereEnabled = json['hereSphereEnabled'] ?? false;
    hereSphereIp = json['hereSphereIp'] ?? "";
    hereSpherePort = json['hereSpherePort'] ?? 23554;
    if (json['funscriptLocations'] != null) {
      funscriptLocations = (json['funscriptLocations'] as List)
          .map((e) => FunscriptLocation.fromJson(e))
          .toList();
    }
  }

  MediaSyncSettings();
}

class FunscriptLocation {
  String id = DateTime.now().millisecondsSinceEpoch.toString();
  String name = "";
  String type = "local";
  String localPath = "";

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'localPath': localPath,
  };

  FunscriptLocation.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    name = json['name'] ?? "";
    type = json['type'] ?? "local";
    localPath = json['localPath'] ?? "";
  }

  FunscriptLocation();
}
