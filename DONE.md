# FOC Companion - Completed Milestones

## 🏁 Phase 0: Research & Analysis
- [x] **Desktop App Analysis:** Comprehensive review of restim-desktop Python code.
- [x] **Protocol Specification:** Documented Protobuf-based communication protocol.
- [x] **Logic Porting:** Waveform generation and pattern logic analyzed for mobile port.

## 🏁 Phase 1: React Native MVP (Obsolete)
- [x] Core connection logic implemented in React Native/Expo.
- [x] TCP communication and Protobuf integration verified.
- [x] Circle pattern execution tested on real device.
- *Status:* This version has been superseded by the Flutter implementation.

## 🏁 Phase 2: Flutter Implementation (Current)
- [x] **Project Scaffold:** Flutter project initialized in `foc-companion/`.
- [x] **Protobuf Integration:** Automated Dart code generation for FOC-Stim protocol.
- [x] **TCP Communication:** Stable socket connection with HDLC framing.
- [x] **State Management:** Provider-based state for settings and device status.
- [x] **Device Settings UI:** Full implementation of safety limits and pulse parameters.
- [x] **Persistence:** Local storage for user preferences.

## 🏁 Phase 3: Security & Open Source
- [x] **Security Audit:** Scan of git history and current codebase for secrets.
- [x] **Sanitization:** Internal IP addresses (192.168.x.x) and personal identifiers removed.
- [x] **License:** MIT License added to the repository.
- [x] **Security Policy:** `SECURITY.md` established.
- [x] **Documentation Refresh:** Root `README.md` and `QUICK_START.md` updated.

## 🏁 Phase 4: Feature Parity & Implementation
- [x] **4-Phase Support:** Implementation of 4-phase output mode logic.
- [x] **Firmware Version Handling:** Support for latest FOC-Stim firmware message format.
- [x] **3-Phase Patterns:** Ported Circle, Figure Eight, Vertical Osc., Panning 1/2, Rose Curve, and Tremor Circle. *(Note: Untested on hardware)*
- [x] **4-Phase Patterns:** Sequence-based pattern registry implemented. *(Note: Untested on hardware)*
- [x] **Pulse Modulation:** LFO system for frequency modulation (Sin, Tri, Saw, Sqr) implemented. *(Note: Untested on hardware)*
- [x] **Calibration:** Implemented hardware calibration (Center, Up, Left for 3-phase; A, B, C, D, Center for 4-phase) in the Device Settings tab.
- [x] **Randomization:** Verified `AXIS_PULSE_INTERVAL_RANDOM_PERCENT` support in firmware and implemented in command loops.

## 🏁 Phase 5 (2026-02-23): UX Polish & Live Settings
- [x] **Live Device/Pulse Settings:** All axis values (carrier freq, pulse freq, width, rise time, randomization, calibration) now sent every tick — changes take effect immediately without restarting. *(Note: Untested on hardware)*
- [x] **Persistent Play Bar:** Start/Stop control moved to a persistent bar above the NavigationBar, always visible regardless of active tab.
  - Stopped state: full-width green "Start \<pattern\>" button.
  - Running state: volume slider (0–100%) + compact red stop icon button.
- [x] **Dynamic App Bar:** When connected, app bar replaces "FOC Companion" title with connection status + temp/battery info, and shows a red disconnect icon button. "FOC Companion" title restored when disconnected.
- [x] **Safety Limits moved to Settings tab:** Min/Max carrier frequency and max amplitude moved from Device tab to the Settings tab. Device tab now shows only calibration sliders.
- [x] **Pattern Verification:** Confirmed all 3-phase mobile patterns match restim-desktop implementations. Fixed Panning 1 arc angle (was 2×π×120/180, corrected to π×120/180) and Tremor Circle frequency scaling (rad/s, not Hz). *(Note: Untested on hardware)*
- [x] **Volume Architecture:** Volume (0–1) separated from max amplitude (safety limit, amps). Matches desktop: `AXIS_WAVEFORM_AMPLITUDE_AMPS = volume × maxAmp` (3-phase) or `volume² × maxAmp` (4-phase). Volume not persisted; max amplitude persists. *(default corrected to 10% in Phase 6)* *(Note: Untested on hardware)*
- [x] **Settings Locking:** IP/Port fields disabled when device is connected. Safety limits disabled when loop is playing. Save buttons disabled accordingly. *(Calibration and pulse locking later removed — see Phase 6)*

## 🏁 Phase 6 (2026-02-23): Navigation & Calibration UX Redesign
- [x] **Device tab removed:** Calibration UI moved out of its own tab to reduce clutter.
- [x] **Calibration in Control tab (disconnected):** When not connected, the Control tab shows the calibration card inline below the Connect section. Sliders are always enabled when disconnected.
- [x] **Calibration overlay (connected):** When connected, a calibration icon (⚙) appears in the AppBar. Tapping it replaces the body with the full calibration screen and swaps the play bar for a "Back" button. Tapping the icon again, or any NavigationBar tab, or the Back button returns to normal.
- [x] **Disconnected status in AppBar:** The AppBar title now shows `device.connectionStatus` ("Disconnected") when not connected, instead of the static "FOC Companion" string.
- [x] **Volume defaults to 10%:** Volume resets to 10% on app start and on each device connect, to prevent accidental high-intensity starts.
- [x] **Reset / Load / Save buttons:** All settings screens (calibration, pulse, connection+limits) now show a three-button row. Reset restores factory defaults; Load reloads the last saved values from storage (shows "Nothing saved yet" if absent); Save persists current values. Granular per-category methods added to `SettingsProvider` so Reset/Load only touch the relevant fields (e.g. resetting calibration does not affect safety limits and vice versa).
- [x] **Calibration and pulse settings always editable:** Removed `isPlaying` locking from calibration and pulse UIs — sliders and buttons are always enabled since all values are already sent on every tick. Safety limits (Settings tab) remain locked while playing; connection settings remain locked while connected.

## 🏁 Phase 8 (2026-02-23): Communication Resilience
- [x] **Tick backpressure:** Each 16 ms timer tick now awaits acknowledgement of the previous tick's full request batch (`Future.wait` with `eagerError: false`) before sending new requests. If the previous batch is still in flight when the next timer fires, the tick is skipped — preventing unbounded queue growth during WiFi glitches.
- [x] **Slow-connection warning:** After 3 consecutive skipped ticks (~48 ms behind), a yellow warning triangle (`⚠`) appears in the AppBar next to the connection status. It clears automatically when throughput recovers.
- [x] **Tick timeout (2 s):** Tick-batch requests use a 2-second timeout (vs. 5 s for setup/control requests). On timeout the loop stops itself, `isLoopRunning` is set to false, and `connectionStatus` shows the error. The device is not immediately disconnected — WiFi may recover.
- [x] **Notification watchdog:** If no notification (battery/temperature) is received for 30 seconds while connected, the device is automatically disconnected with an error message. This catches silent TCP drops where the socket stays open but the device is unreachable.
- [x] **Safe stop on broken link:** `stop()` in both loops wraps `stopSignal()` in try/catch; `_handleLoopTimeout` fires a best-effort `stopSignal()` and ignores errors, since the link may already be dead.

## 🏁 Phase 7: Automation & Distribution
- [x] **CI/CD:** GitHub Actions workflow for automated APK building and distribution.
- [x] **Firebase Distribution:** Integrated Firebase App Distribution for beta testing.
- [x] **GitHub Releases:** Automatic "dev-latest" release updates.
- [x] **Local Distribution:** Utility scripts for manual beta uploads.
