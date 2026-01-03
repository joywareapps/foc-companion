class DeviceSettings {
  double minFrequency = 500;
  double maxFrequency = 1500;
  double waveformAmplitude = 0.120; // 120mA
  
  // Calibration
  double calibration3Center = -0.5;
  double calibration3Up = 0.0;
  double calibration3Left = 0.0;

  Map<String, dynamic> toJson() => {
        'minFrequency': minFrequency,
        'maxFrequency': maxFrequency,
        'waveformAmplitude': waveformAmplitude,
        'calibration3Center': calibration3Center,
        'calibration3Up': calibration3Up,
        'calibration3Left': calibration3Left,
      };

  DeviceSettings.fromJson(Map<String, dynamic> json) {
    minFrequency = json['minFrequency'] ?? 500;
    maxFrequency = json['maxFrequency'] ?? 1500;
    waveformAmplitude = json['waveformAmplitude'] ?? 0.120;
    calibration3Center = json['calibration3Center'] ?? -0.5;
    calibration3Up = json['calibration3Up'] ?? 0.0;
    calibration3Left = json['calibration3Left'] ?? 0.0;
  }
  
  DeviceSettings();
}

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
