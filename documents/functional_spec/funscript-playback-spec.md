# Funscript Playback Feature — Functional Specification

**Version:** 1.0
**Date:** 2026-06-07
**Branch:** `feature/funscript-playback`
**Status:** Draft — Implementation pending

---

## 1. Overview

Enable FOC Companion to load and play back funscript files as an alternative to built-in procedural patterns. Funscripts drive device axes (alpha, beta, volume, frequency, pulse settings) over time, turning the device into a playback-driven experience.

### 1.1 Goals

- Load funscript bundles (`.focb` zip files) containing multiple per-axis funscripts
- Support "Open with" / "Share to" from Android file manager or browser
- Maintain a local library of loaded bundles
- Play back funscripts with full transport controls (play/pause/seek/stop)
- Integrate with existing `CommandLoop` — funscripts feed axis values during tick
- Support dual-box (per-box bundle loading)

### 1.2 Non-Goals (v1)

- Media player sync (HereSphere, VLC, MPC) — separate future feature
- Funscript creation/editing
- SMB/WebDAV remote file loading
- 4-phase axis funscript support (e1-e4) — add later
- Vibration LFO funscripts (vib1_*, vib2_*) — add later

---

## 2. Funscript Format

### 2.1 File Format (Standard)

```json
{
  "version": "1.0",
  "inverted": false,
  "range": 100,
  "metadata": { ... },
  "actions": [
    { "at": 1234, "pos": 75 },
    { "at": 2000, "pos": 50 }
  ]
}
```

- `at` = timestamp in milliseconds
- `pos` = position value 0–100 (normalize to 0.0–1.0 internally)

### 2.2 Axis Suffix Convention (from restim)

Funscript filenames use suffixes to identify which axis they drive:

| Suffix | Axis | Range | Protocol Axis |
|--------|------|-------|---------------|
| `.alpha.funscript` | POSITION_ALPHA | -1.0 → 1.0 | AXIS_POSITION_ALPHA |
| `.beta.funscript` | POSITION_BETA | -1.0 → 1.0 | AXIS_POSITION_BETA |
| `.volume.funscript` | VOLUME_API | 0.0 → 1.0 | AXIS_WAVEFORM_AMPLITUDE_AMPS (scaled) |
| `.frequency.funscript` | CARRIER_FREQUENCY | 500 → 2000 Hz | AXIS_CARRIER_FREQUENCY_HZ |
| `.pulse_frequency.funscript` | PULSE_FREQUENCY | 1 → 100 Hz | AXIS_PULSE_PULSE_FREQUENCY_HZ |
| `.pulse_width.funscript` | PULSE_WIDTH | 3 → 15 cycles | AXIS_PULSE_WIDTH_IN_CYCLES |
| `.pulse_rise_time.funscript` | PULSE_RISE_TIME | 2 → 20 cycles | AXIS_PULSE_RISE_TIME_CYCLES |
| `.pulse_interval_random.funscript` | PULSE_INTERVAL_RANDOM | 0.0 → 1.0 | AXIS_PULSE_INTERVAL_RANDOM_PERCENT |

**Example bundle contents:**
```
my_scene.focb (zip)
  ├── my_scene.alpha.funscript
  ├── my_scene.beta.funscript
  ├── my_scene.volume.funscript
  └── my_scene.frequency.funscript
```

### 2.3 Value Mapping

Funscript `pos` is 0–100. Mapping to device ranges:

```
normalized = pos / 100.0   →  0.0 to 1.0

For position axes (alpha, beta):
  device_value = normalized * 2.0 - 1.0   →  -1.0 to 1.0

For volume:
  device_value = normalized   →  0.0 to 1.0
  (CommandLoop scales: amplitude = volume * device.waveformAmplitude)

For frequency:
  device_value = minFreq + normalized * (maxFreq - minFreq)
  (uses device.minFrequency / device.maxFrequency)

For pulse parameters:
  device_value = paramMin + normalized * (paramMax - paramMin)
```

---

## 3. Bundle Format (`.focb`)

### 3.1 File Structure

A `.focb` file is a standard ZIP archive with a custom extension. Contents:

```
bundle_name.focb/
  ├── bundle_name.alpha.funscript       (optional)
  ├── bundle_name.beta.funscript        (optional)
  ├── bundle_name.volume.funscript      (optional)
  ├── bundle_name.frequency.funscript   (optional)
  ├── bundle_name.pulse_frequency.funscript  (optional)
  ├── bundle_name.pulse_width.funscript  (optional)
  ├── bundle_name.pulse_rise_time.funscript  (optional)
  ├── bundle_name.pulse_interval_random.funscript (optional)
  └── bundle_name.meta.json             (auto-generated on import)
```

### 3.2 Meta File (generated on import)

```json
{
  "name": "Scene Name",
  "importDate": "2026-06-07T20:00:00Z",
  "durationMs": 1234567,
  "axes": ["alpha", "beta", "volume"],
  "sourceFile": "bundle_name.focb"
}
```

### 3.3 Android Integration

**"Open With" support** via AndroidManifest intent filter:

```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="content"/>
  <data android:scheme="file"/>
  <data android:mimeType="application/octet-stream"/>
  <data android:host="*"/>
  <data android:pathPattern=".*\\.focb"/>
  <data android:pathPattern=".*\\..*\\.focb"/>
  <data android:pathPattern=".*\\..*\\..*\\.focb"/>
</intent-filter>
```

**"Share To" support** via `receive_sharing_intent` package.

---

## 4. Architecture

### 4.1 New Files

```
lib/
  models/
    funscript.dart              — Funscript data model (parsed actions)
    funscript_bundle.dart        — Bundle model (meta + per-axis funscripts)
    funscript_library.dart      — Library management (import, list, delete)
  services/
    funscript_parser.dart       — JSON parsing + linear interpolation
    funscript_bundle_loader.dart — ZIP extraction, axis detection, import to library
    funscript_playback_controller.dart — Transport control (play/pause/seek/stop)
  screens/
    funscript_library_screen.dart  — Bundle library browser
    funscript_player_screen.dart   — Playback controls + live axis display
  widgets/
    waveform_preview.dart         — Mini waveform visualization of loaded funscript
```

### 4.2 Modified Files

```
lib/core/command_loop.dart          — Add funscript source mode (vs pattern mode)
lib/services/background_service.dart — Wire playback controller
lib/providers/settings_provider.dart — Add library path setting
lib/providers/device_provider.dart   — Playback state exposure
lib/main.dart                        — Register receive_sharing_intent
lib/screens/home_screen.dart         — Add "Library" entry point
```

### 4.3 Data Flow

```
User opens .focb
  → receive_sharing_intent / file picker
  → FunscriptBundleLoader.import(uri)
    → Extracts ZIP to temp
    → Detects axis suffixes
    → Parses each funscript → List<Funscript>
    → Generates meta.json
    → Copies to library directory
    → Returns FunscriptBundle model
  → Shows in FunscriptLibraryScreen

User taps bundle → FunscriptPlayerScreen
  → FunscriptPlaybackController.load(bundle)
  → User taps Play
    → PlaybackController.start()
      → Starts CommandLoop in funscript mode
      → CommandLoop._tick() calls:
          pos = pattern.update(dt * velocity)   // OLD
          → replaced by:
          playbackController.getValueAt(elapsedMs, 'alpha')
          playbackController.getValueAt(elapsedMs, 'beta')
          playbackController.getValueAt(elapsedMs, 'volume')
          etc.
      → Values sent to device via existing send() mechanism
```

---

## 5. Core Components

### 5.1 FunscriptParser

```dart
class FunscriptParser {
  /// Parse raw JSON string into sorted action list.
  static Funscript parse(String jsonContent);

  /// Get interpolated value at given time (ms).
  /// Returns 0.0–1.0 normalized value.
  /// Uses linear interpolation between nearest actions.
  static double getValueAt(Funscript script, int timeMs);

  /// Get total duration of funscript in ms.
  static int getDuration(Funscript script);
}

class Funscript {
  final List<FunscriptAction> actions; // sorted by at
  final int? version;
  final bool? inverted;

  int get durationMs => actions.last.at;
}

class FunscriptAction {
  final int at;    // ms
  final int pos;   // 0–100
}
```

**Interpolation algorithm (from restim):**
```dart
static double getValueAt(Funscript script, int timeMs) {
  final actions = script.actions;
  if (timeMs <= actions.first.at) return actions.first.pos / 100.0;
  if (timeMs >= actions.last.at) return actions.last.pos / 100.0;

  // Binary search for surrounding actions
  int lo = 0, hi = actions.length - 1;
  while (hi - lo > 1) {
    final mid = (lo + hi) ~/ 2;
    if (actions[mid].at <= timeMs) lo = mid;
    else hi = mid;
  }

  final a = actions[lo], b = actions[hi];
  final t = (timeMs - a.at) / (b.at - a.at);
  return ((a.pos + t * (b.pos - a.pos)) / 100.0).clamp(0.0, 1.0);
}
```

### 5.2 FunscriptBundle

```dart
class FunscriptBundle {
  final String id;           // UUID
  final String name;         // Display name (from filename or meta)
  final DateTime importDate;
  final int durationMs;      // Max duration across all axes
  final String sourceFile;  // Original .focb filename

  /// Map of axis suffix → parsed Funscript
  /// e.g. {'alpha': Funscript(...), 'volume': Funscript(...)}
  final Map<String, Funscript> axes;

  /// Which axes are available in this bundle
  List<String> get axisNames => axes.keys.toList();

  bool get hasAlpha => axes.containsKey('alpha');
  bool get hasBeta => axes.containsKey('beta');
  bool get hasVolume => axes.containsKey('volume');
  // ... etc
}
```

### 5.3 FunscriptBundleLoader

```dart
class FunscriptBundleLoader {
  /// Import a .focb file from URI (shared/opened file).
  /// Copies to library, parses all funscripts, returns bundle model.
  static Future<FunscriptBundle> import(Uri sourceUri);

  /// Load a previously imported bundle from library.
  static Future<FunscriptBundle> loadFromLibrary(String bundleId);

  /// Delete a bundle from library.
  static Future<void> delete(String bundleId);

  /// List all bundles in library.
  static Future<List<FunscriptBundleMeta>> listAll();

  /// Extract axis suffix from filename: "video.alpha.funscript" → "alpha"
  static String? detectAxisSuffix(String filename);
}
```

**Import process:**
1. Copy source URI to temp file
2. Open as ZIP archive (`dart:io` `ZipDecoder` or `archive` package)
3. List entries, filter `.funscript` files
4. Detect axis suffix from each filename
5. Parse each funscript JSON
6. Determine bundle name (strip suffix, or use zip filename)
7. Calculate duration (max across all axes)
8. Generate bundle ID (UUID)
9. Save zip + meta.json to library directory
10. Return FunscriptBundle

### 5.4 FunscriptPlaybackController

```dart
enum PlaybackState { stopped, playing, paused }

class FunscriptPlaybackController extends ChangeNotifier {
  FunscriptBundle? _bundle;
  PlaybackState _state = PlaybackState.stopped;
  int _positionMs = 0;         // Current playback position
  int _lastTickMs = 0;         // For delta-time tracking
  bool _loop = false;          // Loop playback

  // Per-axis current values (updated each tick)
  final Map<String, double> _currentValues = {};

  PlaybackState get state => _state;
  int get positionMs => _positionMs;
  int get durationMs => _bundle?.durationMs ?? 0;
  double get progress => durationMs > 0 ? positionMs / durationMs : 0.0;

  /// Load a bundle for playback.
  void load(FunscriptBundle bundle);

  /// Start playback from current position.
  void play();

  /// Pause playback (freeze position, keep signal running with last values).
  void pause();

  /// Stop playback and reset position to 0.
  void stop();

  /// Seek to absolute position in ms.
  void seek(int ms);

  /// Called by CommandLoop each tick (~30Hz).
  /// Updates internal clock, computes all axis values.
  /// Returns true if playback is active.
  bool tick();

  /// Get current value for a specific axis (0.0–1.0 normalized).
  /// Returns null if axis not available or not playing.
  double? getValue(String axisSuffix);

  /// Get device-ready value for an axis (mapped to device range).
  /// Returns null if axis not available.
  double? getDeviceValue(String axisSuffix, {double? min, double? max});
}
```

**Tick behavior:**
```dart
bool tick() {
  if (_state != PlaybackState.playing || _bundle == null) return false;

  final now = DateTime.now().millisecondsSinceEpoch;
  if (_lastTickMs == 0) _lastTickMs = now;
  _positionMs += (now - _lastTickMs);
  _lastTickMs = now;

  // Handle end-of-file
  if (_positionMs >= durationMs) {
    if (_loop) {
      _positionMs %= durationMs;
    } else {
      _state = PlaybackState.stopped;
      _positionMs = durationMs;
      notifyListeners();
      return false;
    }
  }

  // Update all axis values
  _currentValues.clear();
  for (final entry in _bundle!.axes.entries) {
    _currentValues[entry.key] = FunscriptParser.getValueAt(entry.value, _positionMs);
  }

  notifyListeners();
  return true;
}
```

### 5.5 CommandLoop Integration

The CommandLoop gains a **source mode** toggle:

```dart
class CommandLoop {
  // Existing pattern mode:
  ThreephasePattern pattern = CirclePattern();
  
  // NEW: Funscript mode
  FunscriptPlaybackController? funscriptController;

  /// Determines current source: funscript > pattern
  bool get isFunscriptMode => funscriptController?.state == PlaybackState.playing;

  // In _tick():
  void _tick(Timer _) async {
    // ... existing backpressure logic ...

    double alpha, beta, amp, freq, pulseFreq, pulseWidth, etc.;

    if (isFunscriptMode) {
      // Funscript values override pattern
      alpha = _funscriptDeviceValue('alpha', min: -1.0, max: 1.0);
      beta = _funscriptDeviceValue('beta', min: -1.0, max: 1.0);
      amp = _funscriptDeviceValue('volume', min: 0.0, max: 1.0)
            * _device.waveformAmplitude * ramp;
      freq = _funscriptDeviceValue('frequency',
              min: _device.minFrequency.toDouble(),
              max: _device.maxFrequency.toDouble());
      pulseFreq = _funscriptDeviceValue('pulse_frequency',
                  min: 1.0, max: 100.0);
      pulseWidth = _funscriptDeviceValue('pulse_width',
                     min: 3.0, max: 15.0);
      // ... etc
    } else {
      // Existing pattern logic
      final pos = pattern.update(dt * velocity);
      alpha = pos.x;
      beta = pos.y;
      amp = volume * _device.waveformAmplitude * ramp;
      // ... etc
    }

    // Send to device (same as before)
    send(AxisType.AXIS_POSITION_ALPHA, alpha);
    send(AxisType.AXIS_POSITION_BETA, beta);
    send(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, amp);
    // ...
  }

  double _funscriptDeviceValue(String axis, {double min = 0.0, double max = 1.0}) {
    final normalized = funscriptController?.getValue(axis) ?? 0.5;
    return min + normalized * (max - min);
  }
}
```

**Key design decision:** Funscript values override pattern values per-axis. If a funscript bundle only has alpha+volume, beta falls back to the pattern. This matches restim's behavior.

---

## 6. UI Design

### 6.1 Library Screen (`FunscriptLibraryScreen`)

**Navigation:** New tab or entry from home screen.

**Layout:**
```
┌─────────────────────────────────────────┐
│ Funscript Library                    [+] │
├─────────────────────────────────────────┤
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📦 My Scene                        │ │
│ │    12:34 • alpha, beta, volume     │ │
│ │    Imported Jun 7, 2026            │ │
│ │    [▶ Play]  [🗑️ Delete]         │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📦 Another Scene                   │ │
│ │    8:45 • alpha, beta             │ │
│ │    Imported Jun 6, 2026            │ │
│ │    [▶ Play]  [🗑️ Delete]         │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ (empty state)                           │
│ "No bundles yet. Share a .focb file     │
│  with FOC Companion or tap + to import."│
└─────────────────────────────────────────┘
```

- `[+]` button opens file picker for `.focb` files
- Long-press for additional options
- Swipe to delete

### 6.2 Player Screen (`FunscriptPlayerScreen`)

**Layout:**
```
┌─────────────────────────────────────────┐
│ ← Funscript Player                       │
├─────────────────────────────────────────┤
│                                         │
│  Bundle: My Scene                        │
│  Axes: alpha ● beta ● volume ●         │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  ╱╲  ╱╲     ╱╲                 │   │
│  │ ╱  ╲╱  ╲   ╱  ╲  (alpha wave)  │   │
│  │╱        ╲╱╱    ╲               │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ⏮ ─────────●──────────── ⏭           │
│        3:45 / 12:34                    │
│                                         │
│  Alpha: 0.42  Beta: -0.18             │
│  Volume: 0.75  Freq: 850 Hz           │
│                                         │
│  [⏪] [⏯ Play] [⏩]  [🔁 Loop]         │
│                                         │
├─────────────────────────────────────────┤
│  [Back to Pattern]                       │
└─────────────────────────────────────────┘
```

**Controls:**
- **Play/Pause** — toggle playback state
- **Seek bar** — scrub through timeline
- **Skip ±10s** — quick seek
- **Loop toggle** — repeat when reaching end
- **Back to Pattern** — stop funscript playback, return to procedural pattern mode
- **Live axis readout** — current values per axis (updated at ~30Hz)
- **Waveform preview** — static overview of selected axis waveform

---

## 7. Dual-Box Considerations

Each box can independently load a different funscript bundle or use procedural patterns. The design:

- `ActiveBoxState` in background service gets its own `FunscriptPlaybackController`
- `CommandLoop.boxIndex` already routes to correct box — funscript controller attached per-loop
- UI shows which box is active and which bundle is loaded per box
- Bundle loaded on per-box basis (box selector in library/player)

---

## 8. Dependencies

### New Flutter Packages

| Package | Purpose |
|---------|---------|
| `archive` | ZIP file reading/extracting (.focb bundles) |
| `receive_sharing_intent` | "Share to" / "Open with" from other apps |
| `uuid` | Bundle ID generation |
| `path_provider` | Get app-specific storage directory for library |

### Existing (no changes needed)

- `provider` — state management (already used)
- `shared_preferences` — settings persistence (already used)

---

## 9. Implementation Plan

### Phase A: Core Parsing & Models (estimate: 2-3h)

- [ ] `lib/models/funscript.dart` — data model
- [ ] `lib/services/funscript_parser.dart` — parse JSON, interpolation
- [ ] Unit tests for parser (edge cases: empty, single action, before/after range)

### Phase B: Bundle Loading & Library (estimate: 3-4h)

- [ ] `lib/models/funscript_bundle.dart` — bundle model
- [ ] `lib/services/funscript_bundle_loader.dart` — ZIP import, axis detection
- [ ] `lib/models/funscript_library.dart` — library CRUD
- [ ] `receive_sharing_intent` integration in `main.dart`
- [ ] AndroidManifest intent filter for `.focb`
- [ ] `lib/screens/funscript_library_screen.dart` — library UI

### Phase C: Playback Controller (estimate: 2-3h)

- [ ] `lib/services/funscript_playback_controller.dart` — transport controls
- [ ] CommandLoop integration (funscript source mode)
- [ ] Test: funscript playback drives device correctly

### Phase D: Player UI (estimate: 3-4h)

- [ ] `lib/screens/funscript_player_screen.dart` — full player
- [ ] `lib/widgets/waveform_preview.dart` — axis waveform visualization
- [ ] Transport controls wiring
- [ ] Live axis value display

### Phase E: Polish & Testing (estimate: 2h)

- [ ] Empty states, error handling, large file handling
- [ ] Edge cases: corrupt zip, missing meta, empty funscript
- [ ] Performance: funscripts with 100k+ actions
- [ ] Dual-box playback test
- [ ] Update docs, TODO.md

**Total estimate: 12-16h**

---

## 10. Testing Strategy

### Unit Tests

- FunscriptParser: parsing, interpolation, edge cases
- FunscriptBundleLoader: axis suffix detection, meta generation
- FunscriptPlaybackController: tick behavior, seek, pause/resume, loop, EOF

### Integration Tests

- Import .focb via file picker → appears in library
- Load bundle → play → verify CommandLoop receives funscript values
- Seek → values update correctly
- Dual-box: load different bundles, verify per-box isolation

### Manual Testing

- "Share to" from Chrome (downloaded .focb)
- "Open with" from file manager
- Large funscripts (100k+ actions) — no frame drops
- Playback with device connected — verify physical response

---

## 11. Future Enhancements (Post-v1)

- Media player sync (HereSphere TCP, VLC HTTP API)
- 4-phase axes (e1, e2, e3, e4)
- Vibration LFO funscripts (vib1/vib2 parameters)
- Funscript editor / trimmer
- Export bundle from device recordings
- Cloud sync / backup of library
- Funscript marketplace / sharing
