# Future & Parked Features - FOC Companion

This document tracks features that are either "parked" (deferred for later), "nice-to-have," or planned for future development.

## 1. Media Synchronization (Parked)

The Media Sync feature allows synchronizing stimulation with external media players (like HereSphere).

**Status:** Active. Dual-box support implemented (Phase 5, 2026-06-07). Next: Media Sync feature (see TODO.md).

**Completed Phases:**
1. ✅ MVP Core — TCP/Protobuf, connection, patterns, device status
2. ✅ Phase 4 — Settings infrastructure, device/pulse settings UI, CommandLoop integration
3. ✅ Phase 5 — Dual-box Android Foreground Service (two simultaneous FOC-Stim devices)

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

## 4. Hardware Calibration UI (Completed)

Visual interface for calibrating FOC-Stim 3-phase and 4-phase outputs. Fully implemented (Phase 4) and polished in the Control tab / App Bar overlay (Phase 6). Now supports per-box calibration via BoxProfile model.

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
