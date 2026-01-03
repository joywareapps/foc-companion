# Media Sync Implementation Todo (Flutter)

## Feature Comparison Status

| Feature | Expo (`src`) | Flutter (`restim-flutter`) | Status |
| :--- | :--- | :--- | :--- |
| **HereSphere Settings** | Configurable IP, Port, Toggle. | Implemented in `MediaSyncScreen`. | ✅ **Done** |
| **HereSphere Service** | TCP connection, Keep-alive, Status parsing. | Implemented in `HereSphereService` class. | ✅ **Done** |
| **Location Management** | List, Delete, Add (Modal), Edit. | List, Delete, Add (Basic/Hardcoded). | ⚠️ **Partial** |
| **SMB/Samba Support** | (Used WebDAV as fallback). | Missing. | ❌ **Todo** |
| **Funscript Parsing** | `FunscriptService` (parsing, interpolation). | Minimal `FileSourceService` (listing only). | ❌ **Todo** |
| **Playback Logic** | `SyncedPlayback` coordinator (HS -> Device). | Missing. | ❌ **Todo** |
| **Playback UI** | Test Connection, Start/Stop, Live Status. | Missing. | ❌ **Todo** |

---

## Todo List

### 1. Core Logic (Priority High)
- [ ] **Implement `FunscriptService`**
    - Port `FunscriptService.ts` to Dart.
    - Implement `parseFunscript` to handle JSON structure.
    - Implement `getPositionAt(timeMs)` for linear interpolation of script actions.
- [ ] **Implement `SyncedPlayback` Controller**
    - Port `SyncedPlayback.ts`.
    - Create a controller that listens to `HereSphereService` streams.
    - Implement logic to load funscripts when video filename changes.
    - Implement the control loop: `HereSphere Time -> Funscript Position -> Device Position -> API Command`.
    - Handle Pause/Resume (ramp amplitude down/up).

### 2. Services
- [ ] **Implement `SambaService`** (Replacing WebDAV)
    - Add an SMB/CIFS client library for Flutter.
    - Implement directory listing and file reading for remote SMB shares.
    - *Note: WebDAV was used in Expo due to lack of SMB support; Flutter has better native/plugin support for SMB.*
- [ ] **Enhance `FunscriptCollector`**
    - Update `FileSourceService` or create `FunscriptCollector`.
    - Logic to search all configured locations (Local + SMB) for matching funscript files (`video.funscript`, `video.alpha.funscript`, etc.).

### 3. UI - Location Management
- [ ] **Add Location Editor**
    - Replace the hardcoded "Add Local Location" button with a dialog/screen.
    - Add support for selecting Location Type (Local vs SMB).
    - Add fields for SMB Host/IP, Share Name, Username, Password.
    - Add file picker for Local path selection.

### 4. UI - Playback Control
- [ ] **Test Connection Button**
    - Add button to verify HereSphere TCP connection before starting.
- [ ] **Start/Stop Playback**
    - Add controls to actively start the synchronization loop (distinct from just "Connecting").
- [ ] **Live Status Dashboard**
    - Display currently detected video filename.
    - Display active funscripts (loaded channels).
    - Show current device position/amplitude in real-time.

### 5. Integration
- [ ] **Connect Playback to Device**
    - Ensure `DeviceProvider` allows sending high-frequency streaming commands from the new `SyncedPlayback` controller.
