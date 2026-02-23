# Task 07: Firmware Version Compatibility Check

## Objective
Implement firmware version validation to ensure compatibility between the FOC Companion app and the FOC-Stim device firmware.

## Requirement
Validate that firmware version is at least **1.1.x** but less than **2.0.0**.

| Version | Status |
|---------|--------|
| 1.0.9 | ❌ Too old |
| 1.1.0 | ✅ Compatible (min) |
| 1.1.5 | ✅ Compatible |
| 1.9.9 | ✅ Compatible |
| 2.0.0 | ❌ Too new |
| 2.1.0 | ❌ Too new |

## Implementation

### Step 1: Version Utility
```dart
// lib/utils/version_utils.dart
class Version {
  final int major;
  final int minor;
  final int patch;
  
  Version(this.major, this.minor, this.patch);
  
  factory Version.fromString(String s) {
    // Parse "1.1.5", "v1.2", "1.3.0-beta" etc.
    final clean = s.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = clean.split('.');
    return Version(
      int.parse(parts[0]),
      parts.length > 1 ? int.parse(parts[1]) : 0,
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );
  }
  
  bool operator >=(Version o) =>
    major > o.major || (major == o.major && minor > o.minor) ||
    (major == o.major && minor == o.minor && patch >= o.patch);
  
  bool operator <(Version o) => !(this >= o);
  
  @override
  String toString() => '$major.$minor.$patch';
}

class VersionCheck {
  static const minVersion = Version(1, 1, 0);
  static const maxVersion = Version(2, 0, 0);
  
  static bool isCompatible(Version v) =>
    v >= minVersion && v < maxVersion;
  
  static String getMessage(Version v) {
    if (v < minVersion) {
      return 'Firmware ${v} too old. Update to at least $minVersion.';
    } else if (v >= maxVersion) {
      return 'Firmware ${v} too new. App requires < $maxVersion.';
    }
    return 'Firmware ${v} compatible ✓';
  }
}
```

### Step 2: Add to FOCStimApiService
```dart
// In focstim_api_service.dart
Version? firmwareVersion;
bool get isVersionCompatible => 
  firmwareVersion != null && VersionCheck.isCompatible(firmwareVersion!);

Future<Version?> getFirmwareVersion() async {
  final response = await _sendRequest(RequestFirmwareVersion());
  if (response is ResponseFirmwareVersion) {
    firmwareVersion = Version.fromString(response.version);
    return firmwareVersion;
  }
  return null;
}
```

### Step 3: Check on Connect
```dart
Future<void> connect(String ip, int port) async {
  // ... existing connection logic ...
  
  final version = await getFirmwareVersion();
  if (version == null) {
    throw Exception('Could not get firmware version');
  }
  
  if (!isVersionCompatible) {
    throw Exception(VersionCheck.getMessage(version));
  }
  
  // ... continue ...
}
```

### Step 4: Show in UI
- Display firmware version in connection status
- Green checkmark if compatible
- Warning/error message if not
- Block pattern execution if incompatible

## Files to Modify
1. `lib/utils/version_utils.dart` (new)
2. `lib/services/focstim_api_service.dart`
3. `lib/screens/control_screen.dart`

## Estimated Effort: 2-3 hours

## Priority: MEDIUM
