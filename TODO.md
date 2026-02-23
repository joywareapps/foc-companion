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
