# 💡 FOC Companion - Flutter Implementation Status

## **Objective**
Develop the "FOC Companion" Android application using Flutter. The app connects to a FOC-Stim device over TCP, manages signal parameters, and executes patterns.

---

## 🔥 PRIORITY TASKS

### Task 03: Pattern System Overhaul 🎨
- **Priority:** HIGH
- **Status:** 🟡 In Progress
- **Prompt:** `todo/03-pattern-system-overhaul.md`
- **Summary:** 
  - Port patterns from restim-desktop (17+ available)
  - Create "Driver Cockpit" UI for real-time pattern control
  - Implement modulation system for pulse parameters
  - Speed multipliers and modulation functions (sin, triangle, saw, square)

### Task 04: Security Audit & Open Source Preparation 🔒
- **Priority:** HIGH
- **Status:** 🟢 Complete
- **Summary:** Repository sanitized, LICENSE/SECURITY.md added, documentation updated.

### Task 05: Android App Distribution Research 📱
- **Priority:** MEDIUM
- **Status:** 🟢 Complete (Research Phase)
- **Summary:** Firebase App Distribution recommended for beta testing.

### Task 06: Randomization Parameter Check ⚠️
- **Priority:** MEDIUM
- **Status:** 🟡 Needs Investigation
- **Summary:**
  - Check if pulse interval randomization parameter is still supported by firmware
  - Verify `AXIS_PULSE_INTERVAL_RANDOM_PERCENT` axis in command loop
  - Review FOC-stim proto files for randomization support
  - Update app UI if feature deprecated, or fix implementation if broken

### Task 07: Calibration Implementation 🎛️
- **Priority:** HIGH
- **Status:** 🟡 Not Started
- **Summary:**
  - Implement calibration feature based on desktop version (`~/code/restim-desktop/`)
  - Add calibration button next to play button on control screen
  - Create calibration screen with different options for 3-phase and 4-phase modes
  - Auto-select appropriate calibration screen based on connected device mode
  - Reference desktop implementation for calibration logic and UI

---

## **📋 Phase 1: Core Implementation (Flutter)**

- [x] **Project Initialization:**
    - [x] Set up Flutter project in `foc-companion/`.
    - [x] Configure Android build settings.
- [x] **Protobuf Integration:**
    - [x] Compilation of `.proto` files to Dart (`foc-companion/lib/generated/`).
    - [x] Integration with communication layer.
- [x] **Communication Layer:**
    - [x] TCP Socket service implementation.
    - [x] HDLC framing/deframing logic in Dart.
    - [x] **Test TCP connection on real device** - ✅ VERIFIED WORKING
- [x] **Protocol API:**
    - [x] `FocStimApiService` for Protobuf-based requests/notifications.
    - [x] Signal start/stop control.
- [x] **State Management:**
    - [x] `Provider` based state management for connection and settings.
- [x] **Command Loop:**
    - [x] High-frequency loop for pattern execution (60Hz).
    - [x] Dynamic signal parameter updates.
- [x] **Device Settings UI:**
    - [x] Safety limits (min/max frequency, amplitude).
    - [x] Pulse parameters (carrier/pulse freq, width, rise time, randomness).
    - [x] Persistence using `shared_preferences`.

---

## **📋 Phase 2: Pattern System (Task 03)**

- [ ] **Pattern Porting:**
    - [ ] Port core patterns from desktop (Circle, Orbit, Spiral, etc.).
    - [ ] Implement interpolation for smooth transitions.
- [ ] **Driver Cockpit UI:**
    - [ ] Real-time control interface for running patterns.
    - [ ] Speed/Velocity adjustment.
- [ ] **Modulation System:**
    - [ ] LFO-based modulation for pulse parameters.
    - [ ] Waveform selection (sin, triangle, saw, square).

---

## **📋 Planned / Parked Features**

### Media Synchronization
- **Status:** 🟡 Parked
- **Goal:** Synchronize with HereSphere and other players.
- **Docs:** `documents/features-parked/MEDIA_SYNC_USAGE.md`

### Serial / USB Communication
- **Status:** 🟡 Planned
- **Goal:** Direct USB connection to FOC-Stim devices.
- **Reference:** `documents/features-future.md`

### Hardware Calibration UI
- **Status:** 🟡 Planned
- **Goal:** Visual interface for output calibration.

---

## **📋 Archive (Legacy Implementation)**
Legacy React Native implementation and research has been moved to `documents/archive/`.
- `documents/archive/mobile_migration_plan.md`
- `documents/archive/WORKLETS_MIGRATION.md`
