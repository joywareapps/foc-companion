# Future & Parked Features - FOC Companion

This document tracks features that are either "parked" (deferred for later), "nice-to-have," or planned for future development.

## 1. Media Synchronization (Parked)

The Media Sync feature allows synchronizing stimulation with external media players (like HereSphere).

**Status:** Parked. Core logic exists but needs porting and stabilization in Flutter.

**Target Players:**
- HereSphere (TCP Socket)
- MPC-HC (Web Interface)
- VLC
- Kodi

**Key Components:**
- WebDAV Funscript Loading
- Multi-channel Synchronization
- Real-time Position Tracking

**Reference Docs:**
- `documents/features-parked/MEDIA_SYNC_USAGE.md`
- `documents/features-parked/NETWORK_TROUBLESHOOTING.md`

---

## 2. Serial / USB Communication (Planned)

Support for connecting to FOC-Stim devices via USB serial on Android.

**Status:** Planned. Requires library integration (e.g., `usb_serial` in Flutter).

**Technical Requirements:**
- Android USB Host permissions
- Serial transport abstraction
- Shared HDLC/Protobuf logic with TCP transport

---

## 3. Advanced Volume Control & Modulation (Planned)

Enhanced volume management based on desktop features.

**Features:**
- **Inactivity Volume Reduction:** Automatically lower volume when pattern is static.
- **Slow Start:** Gentle ramp-up on pattern start.
- **Volume-Frequency Adjustment (Tau):** Maintain perceived intensity across frequencies.
- **LFO Modulation:** Independent LFOs for vibration/texture effects.

---

## 4. Hardware Calibration UI (Nice-to-Have)

Visual interface for calibrating FOC-Stim 3-phase and 4-phase outputs.

**Settings:**
- 3-Phase: Center, Up, Left
- 4-Phase: Center, A, B, C, D

---

## 5. Teleplot Integration (Nice-to-Have)

Real-time visualization of device data (currents, stats) using the Teleplot protocol or internal charting.

---

## 6. F-Droid / Play Store Distribution (Planned)

Automated distribution and public release.

**Reference Docs:**
- `todo/05-distribution-research.md`
