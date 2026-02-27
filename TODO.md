# 💡 FOC Companion - Task List

## **Objective**
Develop the "FOC Companion" Android application using Flutter. The app connects to a FOC-Stim device over TCP, manages signal parameters, and executes patterns.

---

## 🏁 Completed Work
See [DONE.md](DONE.md) for a detailed history of completed phases and implemented features.

---

## 🔥 ACTIVE TASKS

### Task 03: Hardware Validation 🎨
- **Priority:** HIGH
- **Status:** 🟡 Testing Required
- **Prompt:** `todo/03-pattern-system-overhaul.md`
- **Summary:** 
  - Verify all ported patterns (3-phase & 4-phase) on real hardware.
  - Test pulse frequency modulation (LFO) stability at 60Hz.
  - Verify calibration persistence and effect on output.

### Task 06: Background Execution 🔄
- **Priority:** MEDIUM
- **Status:** 🟡 Planning
- **Prompt:** `todo/06-background-execution.md`
- **Summary:** 
  - Implement Android Foreground Service to keep 60Hz loop alive when app is minimized.
  - Configure persistent notification for active stimulation.
  - Implement WakeLocks and WiFi locks to prevent connection drops.

### Task 07: Firmware Version Compatibility Check 🔧
- **Priority:** MEDIUM
- **Status:** 🟡 Not Started
- **Summary:**
  - Implement firmware version validation on app startup/connection.
  - **Requirement:** Validate firmware version is at least 1.1.x but less than 2.0.0.
  - **Implementation:**
    - Parse firmware version string from device response (e.g., "1.1.5", "1.2.0").
    - Compare against minimum (1.1.0) and maximum (2.0.0 exclusive).
    - Show clear error message if incompatible:
      - Too old (< 1.1.0): "Firmware too old. Please update to at least version 1.1.0"
      - Too new (≥ 2.0.0): "Firmware too new. App requires version < 2.0.0"
    - Block pattern execution if version check fails.
  - **Location:** Add to `focstim_api_service.dart` connection logic.
  - **Testing:** Test with mock versions (1.0.9, 1.1.0, 1.1.5, 1.9.9, 2.0.0).

### Task 09: Impedance Display in Calibration Screen ✅
- **Priority:** LOW–MEDIUM
- **Status:** ✅ Completed (2026-02-27)
- **Prompt:** `todo/09-model-estimation-display.md`
- **Summary:**
  - Handle `NotificationModelEstimation` from firmware in `DeviceProvider`.
  - Expose `impedanceA/B/C/D` (nullable double, ohms) updated at ~1.2 Hz while playing.
  - Show coloured impedance badges next to each electrode in the calibration overlay.
  - 4-phase: badge per slider (A/B/C/D). 3-phase: compact row below sliders (Ch A/B/C).

### Task 08: Command Loop Optimization ⚡ ✅
- **Priority:** MEDIUM
- **Status:** ✅ Completed (2026-02-23)
- **Summary:**
  - Implemented all optimizations from restim-desktop:
    1. ✅ Delta updates - only send changed axis values
    2. ✅ Periodic full sync every 1 second
    3. ✅ TCP_NODELAY enabled for lower latency
    4. ✅ Loop rate reduced to 30 Hz (from 60 Hz)
  - **Result:** Bandwidth reduced from ~330 req/s to ~70 req/s

---

## 📋 PLANNED / PARKED FEATURES

### Media Synchronization
- **Status:** 🟡 Parked
- **Goal:** Synchronize with HereSphere and other players.
- **Docs:** `documents/features-parked/MEDIA_SYNC_USAGE.md`

### Serial / USB Communication
- **Status:** 🟡 Planned
- **Goal:** Direct USB connection to FOC-Stim devices.
- **Reference:** `documents/features-future.md`

---

## 📋 ARCHIVE (Legacy)
Legacy React Native implementation and research has been moved to `documents/archive/`.
