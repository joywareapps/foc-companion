# Phase 7: Video-Player Sync for Funscript Playback

## Overview

Sync funscript playback position with an external video player (HereSphere or MPC-HC) so device output stays in sync with the video timeline. The funscript player reads the video player's current timestamp and seeks to match, replacing its own internal clock with the video player's authoritative time.

## Goals

- One-tap link from funscript player to the configured video player
- Video player timestamp drives funscript position (not the other way around)
- Graceful handling when video timestamp exceeds funscript duration
- Support both HereSphere (WebSocket protocol, already partially implemented) and MPC-HC (HTTP JSON-RPC)

---

## Settings

`MediaSyncScreen` already exists with HereSphere IP/port fields but is **not wired into navigation**. This feature adds an entry point from the main settings screen and extends the existing `MediaSyncScreen` with MPC-HC config and a player selector.

### Settings Screen (entry point)

Add a **"Video Sync"** tile in `SettingsScreen` (between "Device Behavior" and "Application Log"):

```
┌─────────────────────────────────┐
│  Connection (Box 1)              │
│  Safety Limits (Box 1)          │
│  ...                             │
│                                  │
│  🎬 Video Sync            >      │  ← ListTile, onTap → Navigator.push(MediaSyncScreen)
│                                  │
│  Device Behavior                 │
│  Application Log                │
└─────────────────────────────────┘
```

### MediaSyncScreen (extend existing)

Add to the top of the existing screen (before the HereSphere section):

```
Video Sync
├── Active Player: [None ▼]      ← dropdown: None / HereSphere / MPC-HC
│
├── HereSphere                    ← existing section, shown when activePlayer=heresphere
│   ├── IP Address: [________]    ← (already exists)
│   └── Port: [23554]             ← (already exists)
│
├── MPC-HC                        ← NEW section, shown when activePlayer=mpcHc
│   ├── IP Address: [________]
│   └── Port: [13579]
│
├── Funscript Locations           ← (already exists, keep as-is)
└── [Save Media Settings]         ← (already exists)
```

Only the selected player's section is visible. `activePlayer` saves/loads with the rest of `MediaSyncSettings`.

---

## Data Models

### MediaSyncSettings (additions to `settings_models.dart`)

```dart
enum VideoPlayerType { none, heresphere, mpcHc }

class MediaSyncSettings {
  // Existing fields...
  bool hereSphereEnabled = false;
  String hereSphereIp = "";
  int hereSpherePort = 23554;
  List<FunscriptLocation> funscriptLocations = [];

  // NEW fields:
  VideoPlayerType activePlayer = VideoPlayerType.none;
  String mpcHcIp = "";
  int mpcHcPort = 13579;
  
  // JSON round-trip updated...
}
```

### VideoPlayerStatus (new, shared contract)

```dart
/// Normalized status from any video player backend.
class VideoPlayerStatus {
  final bool connected;
  final bool isPlaying;
  final double currentTimeMs;   // video position in ms
  final double durationMs;        // total video length in ms
  final String? filePath;         // currently playing file path/name
  final double playbackSpeed;

  const VideoPlayerStatus({
    this.connected = false,
    this.isPlaying = false,
    this.currentTimeMs = 0,
    this.durationMs = 0,
    this.filePath,
    this.playbackSpeed = 1.0,
  });

  const VideoPlayerStatus.disconnected()
      : connected = false, isPlaying = false, currentTimeMs = 0,
        durationMs = 0, filePath = null, playbackSpeed = 1.0;
}
```

---

## Video Player Services

### HereSphereService (extend existing)

Already has WebSocket connection with 4-byte length header + JSON protocol. Needs:

- **`Stream<VideoPlayerStatus> get statusStream`** — already emits `HereSphereStatus`, add a mapper to `VideoPlayerStatus`
- **Pause/Resume command** — send play/pause JSON to HereSphere (if needed for future bidirectional sync)
- **Seek command** — send seek JSON to HereSphere if we ever want reverse sync

No protocol changes needed — current implementation already parses `currentTime`, `playerState`, `path`.

### MpcHcService (new: `lib/services/mpc_hc_service.dart`)

MPC-HC exposes a JSON-RPC HTTP API on its configured web interface port.

**Protocol:** HTTP GET/POST to `http://{ip}:{port}/api`

| Command | HTTP | Description |
|---------|------|-------------|
| Get status | `GET /api/?q={}` | Returns: playing state, position, duration, file path |
| Play/Pause | `POST /api/?q={%22command%22:%22playpause%22}` | Toggle play/pause |
| Seek | `POST /api/?q={%22command%22:%22seek%22,%22param%22:12345}` | Seek to ms |

**Polling strategy:** HTTP GET every 250ms (4Hz) when linked. This is sufficient for sync — funscript resolution is typically 20–100ms per action point, and human perception of drift is >200ms.

```dart
class MpcHcService {
  final String ip;
  final int port;
  Timer? _pollTimer;
  final StreamController<VideoPlayerStatus> _statusController = ...;
  
  Stream<VideoPlayerStatus> get statusStream => _statusController.stream;
  
  Future<void> startPolling();
  void stopPolling();
  Future<VideoPlayerStatus> fetchStatus();  // single HTTP GET
  
  void dispose();
}
```

**Response format (MPC-HC):**
```json
{
  "playing": true,
  "position": 12345,
  "duration": 600000,
  "filename": "video.mp4",
  "filepath": "C:\\Videos\\video.mp4"
}
```

> **Note:** mpv with `--input-ipc-server` and the `mpv-jsonipc` Lua script also speaks this JSON-RPC protocol. The same service works for both.

---

## VideoSyncController (new: `lib/services/video_sync_controller.dart`)

Orchestrates the link between a video player backend and the funscript playback controller.

```dart
class VideoSyncController extends ChangeNotifier {
  // Dependencies
  final FunscriptPlaybackController _funscriptController;
  final HereSphereService? _heresphereService;
  final MpcHcService? _mpcHcService;
  
  // State
  bool isLinked = false;
  VideoPlayerType linkedPlayer = VideoPlayerType.none;
  VideoPlayerStatus playerStatus = const VideoPlayerStatus.disconnected();
  SyncState syncState = SyncState.idle;  // idle / syncing / exceeded / error
  
  // Graceful exceed state
  bool get isVideoBeyondScript => 
      playerStatus.connected && 
      playerStatus.currentTimeMs > _funscriptController.durationMs;
  
  /// Link to video player. Starts receiving timestamps.
  Future<void> link(VideoPlayerType player);
  
  /// Unlink from video player. Stops receiving timestamps.
  void unlink();
  
  /// Internal: react to video player status updates
  void _onPlayerStatus(VideoPlayerStatus status);
}

enum SyncState { idle, syncing, exceeded, error }
```

### Sync Logic (`_onPlayerStatus`)

```
On each video player status update:
  1. Store latest playerStatus
  2. If !playerStatus.connected → syncState = error, notify
  3. If !playerStatus.isPlaying → freeze funscript (pause if playing)
  4. If playerStatus.currentTimeMs > funscriptController.durationMs:
     a. syncState = exceeded
     b. Seek funscript to end (positionMs = durationMs)
     c. Hold last value (don't stop — device keeps output at last point)
     d. Notify UI to show "Script ended" indicator
     e. Continue polling — if video seeks back within range, resume sync
  5. If playerStatus.currentTimeMs within [0, durationMs]:
     a. syncState = syncing
     b. Seek funscript controller to playerStatus.currentTimeMs
        (funscriptController.seek(status.currentTimeMs.toInt()))
     c. If funscript not playing → auto-play
```

**Key design decisions:**

- **Video is time master.** The funscript player always seeks to match the video position. It does NOT use its own internal clock while linked.
- **Funscript pauses when video pauses.** If the video player pauses (or stops), the funscript controller pauses too.
- **Seek works both ways.** User seeking in the video player causes the funscript to jump to the same position.
- **Script end is not a hard stop.** When video exceeds funscript length, the funscript holds its last position value rather than stopping and clearing output. This avoids jarring device drops.

---

## Funscript Player Screen — Sync Toggle Button

The **only UI change** is a sync toggle button added to the existing funscript player screen (`FunscriptPlayerScreen`). No new screens, no settings screen changes.

### Button Placement

Small icon button in the transport bar area (next to play/pause/stop):

```
  ▶  ⏸  ⏹  [🔗]    01:23 / 05:00
```

### Button States

| State | Icon | Color | Behavior |
|-------|------|-------|----------|
| Not linked | `link_off` | muted/gray | Tap → read `activePlayer` from `MediaSyncSettings`, start sync |
| Connecting | `sync` (circular progress) | accent | Auto-transitions to linked or error |
| Linked & syncing | `link` | accent/green | Tap → unlink |
| Linked, video beyond script | `link` + amber badge | amber | Tap → unlink |
| Connection error | `link_off` | red | Tap → retry connect |

### Tap Behavior

- **Not linked → tap:**
  1. Read `activePlayer` from `MediaSyncSettings`
  2. If `none`, show snackbar: "No video player configured. Set up in Settings → Video Sync."
  3. Otherwise, instantiate `VideoSyncController` and call `link(player)`
  4. Connect to the player using stored IP/port from settings
- **Linked → tap:** `unlink()` — stop receiving timestamps, funscript resumes using its own internal clock

### Script-ended Indicator

When `syncState == exceeded` and `isLinked`, show a subtle amber chip below the waveform:

```
  ⚠️ Video at 06:23 — script ended at 05:00
```

Auto-hides when video seeks back within range.

---

## Sequence Diagrams

### Link & Sync Flow

```
User          PlayerScreen      VideoSyncController    VideoPlayerService    FunscriptController
 │                  │                      │                      │                      │
 │  tap [link]      │                      │                      │                      │
 │─────────────────>│                      │                      │                      │
 │                  │  link(heresphere)     │                      │                      │
 │                  │─────────────────────>│                      │                      │
 │                  │                      │  connect()           │                      │
 │                  │                      │─────────────────────>│                      │
 │                  │                      │  status events ──────>│                      │
 │                  │                      │<─────────────────────│                      │
 │                  │                      │                      │                      │
 │                  │                      │  onStatus(time=1234) │                      │
 │                  │                      │──────────────────────────────────────────>│
 │                  │                      │                      │      seek(1234)      │
 │                  │                      │                      │─────────────────────>│
 │                  │                      │                      │      play()           │
 │                  │                      │                      │─────────────────────>│
 │                  │                      │                      │                      │
 │                  │  UI: linked ✓        │                      │                      │
 │<─────────────────│                      │                      │                      │
```

### Video Beyond Script

```
VideoPlayerService    VideoSyncController         FunscriptController         UI
       │                       │                          │                  │
       │ time=320000ms         │                          │                  │
       │ (duration=300000ms)   │                          │                  │
       │──────────────────────>│                          │                  │
       │                       │ time > duration!         │                  │
       │                       │ syncState = exceeded     │                  │
       │                       │─────────────────────────>│                  │
       │                       │ seek(durationMs)         │                  │
       │                       │ hold last value          │                  │
       │                       │──────────────────────────────────────────>│
       │                       │                          │  show ⚠️ banner │
       │                       │                          │─────────────────>│
       │                       │                          │                  │
       │  ...user seeks back    │                          │                  │
       │ time=280000ms         │                          │                  │
       │──────────────────────>│                          │                  │
       │                       │ within range again       │                  │
       │                       │ syncState = syncing     │                  │
       │                       │─────────────────────────>│                  │
       │                       │ seek(280000)             │                  │
       │                       │ play()                   │                  │
       │                       │─────────────────────────>│                  │
       │                       │                          │  hide banner     │
       │                       │                          │─────────────────>│
```

---

## Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `lib/models/settings_models.dart` | Modify | Add `VideoPlayerType` enum, `mpcHcIp`, `mpcHcPort`, `activePlayer` to `MediaSyncSettings` |
| `lib/services/video_player_status.dart` | **Create** | `VideoPlayerStatus` model class |
| `lib/services/mpc_hc_service.dart` | **Create** | MPC-HC HTTP JSON-RPC polling service |
| `lib/services/video_sync_controller.dart` | **Create** | Sync orchestrator linking video player ↔ funscript controller |
| `lib/services/heresphere_service.dart` | Modify | Add `VideoPlayerStatus` mapper on `statusStream` |
| `lib/screens/settings_screen.dart` | Modify | Add "Video Sync" ListTile → navigate to MediaSyncScreen |
| `lib/screens/media_sync_screen.dart` | Modify | Add active player dropdown at top, MPC-HC IP/port section |
| `lib/screens/funscript_player_screen.dart` | Modify | Add sync toggle button in transport bar, script-ended chip |

---

## Testing Strategy

- **Unit:** `VideoSyncController` sync logic with mock `VideoPlayerStatus` events (within range, beyond range, seek back)
- **Unit:** `MpcHcService` HTTP parsing with recorded JSON responses
- **Integration:** `HereSphereService` + `VideoSyncController` + `FunscriptPlaybackController` wired together with fake clock
- **Manual:** Real HereSphere on Quest + app on same network, verify sync holds within ±100ms over 5 minutes
- **Manual:** MPC-HC playing a known-length video, verify funscript seeks correctly and handles end-of-script gracefully

---

## Non-Goals (v1)

- **Reverse sync** (funscript → video seek) — video is always the time master
- **Speed matching** — video playback speed is not applied to funscript (both typically play at 1x)
- **Auto-launch video** — user opens the video in their player separately
- **File matching** — no attempt to auto-detect which .focb matches which video file
- **Playlist/queue** — only single video sync at a time
