# Task 10: FOC-Stim Firmware v2 Protocol Support

- **Priority:** HIGH (current app refuses to connect to any v2.x box)
- **Status:** ✅ Completed (2026-10-29), released in v1.6.0. Tested on 1.x and 2.x firmware.
- **Upstream checked:** FOC-Stim `30c7b69` (v2.0.3, 2026-10-27), restim `8d0524b` (v1.67, 2026-10-27)

## What changed upstream

### FOC-Stim firmware (v1.3.2 → v2.0.3)

| Version | Change | Impact on us |
|---|---|---|
| v1.3.0 | New axis `AXIS_CALIBRATION_4_REDUCTION_IN_CENTER = 45` (ratio 0–0.2, default 0.14) | Not in our proto; we never send it, so the firmware default applies. Optional to add. |
| v1.3.0 | Body current max raised to 200 mA | None (our max amplitude is user-limited). |
| v1.3.1 | Improved 3-phase signal generation (`project_threephase_2`) | None at the protocol level. |
| **v2.0.0** | **3-phase calibration axes replaced.** `AXIS_CALIBRATION_3_CENTER/UP/LEFT` (30/31/32) removed. New `AXIS_CALIBRATION_3_A/B/C` (33/34/35, in dB, −10…10) and `AXIS_CALIBRATION_3_REDUCTION_IN_CENTER` (36, ratio 0–0.2, default 0.14) | **Breaking.** Our 3-phase loop sends 30/31/32. On v2, the firmware ignores unknown axes silently (`handle_request_axis_move_to` has `// todo: error out if not found?`), so the calibration would just stop working with no error. |
| v2.0.0 | API major version bumped to 2 | **Breaking.** `validateFirmwareVersion` requires `major == 1`, so the app refuses to connect. |
| v2.0.0 | Pulse frequency axis max raised 100 → 200 Hz; minimum inter-pulse pause now 5 ms; maximum pulse duration 35 ms | Our `gapPulseFrequencyHz` already uses a 5 ms minimum gap and clamps to 100 Hz. Nothing needed. |
| v2.0.1 | `ResponseFirmwareVersion.esp32_firmware_version = 4` | Additive. v2.0.3 stopped populating it (older ESP32 firmware hangs), so it is currently always empty. |

Everything else in the four `.proto` files is identical to ours (we synced in June 2026).
The 4-phase axes 41–44 (dB) and electrode power axes 50–53 are unchanged.

### restim (v1.63 → v1.67)

- Requires firmware **2.x only** (`FOCSTIM_VERSION_MAJOR = 2`, min minor 0). It drops 1.x.
- 3-phase: keeps the old UI model (center / neutral (UD) / right (LR) in dB) and converts it on every tick:
  - `calib_abc_db = 10·log10(ud_lr_to_intensity_ratio(ud, lr))` → axes 33/34/35
  - `center_reduction = 1 − 10^(center_db/10)` → axis 36
- 4-phase: sends `AXIS_CALIBRATION_4_REDUCTION_IN_CENTER` from a new setting (restim default 0.07).
- App-level features that do not touch the protocol (could port later): pulse-frequency volume calibration (`PulseFrequencyCalibration`, volume × 0.92–1.05), burst gap mode, A/B test algorithm, OFS input, T-Code axis display.

## Can we follow? Yes, and it is a small change

Our app is already set up for it:

- The 3-phase calibration UI and the stored settings already use **Electrode A/B/C in dB** (`calibration3A/B/C`). Today `SettingsProvider.updateCalibration3Modern` converts them *back* to UD/LR (`intensityRatioToUdLr`) only to satisfy the v1 protocol. On v2 we send A/B/C directly, which removes a lossy round trip.
- `calibration3Center` is in dB, the same as restim's `center`, so the restim formula applies as is.
- Wire compatibility: axis numbers 30–32 and 33–36 do not overlap, and each firmware silently ignores the axes it does not know. So we can keep both sets of enum values in our local proto and choose by firmware major at connect time.

## Decision: support 1.x and 2.x at the same time

Recommended. Mobile users flash firmware through restim on a desktop, so some boxes will stay on 1.x for a while. Supporting both costs one branch in two places. Remove 1.x support later, once most boxes are on 2.x.

(The alternative is to go 2.x only, like restim. That is simpler, but anyone who has not reflashed gets an "Incompatible firmware" error.)

## Implementation plan

1. **Proto sync** (`foc-companion/proto/`)
   - `constants.proto`: add 33–36 and 45. **Keep** 30/31/32 (marked `// v1 firmware only`) rather than commenting them out like upstream does, so the Dart enum still has them.
   - `messages.proto`: add `FirmwareVersion esp32_firmware_version = 4;`.
   - Run `./generate_protos.sh` and commit the regenerated `lib/generated/protobuf/*` (CI also regenerates).
2. **Version gate** (`lib/services/focstim_api_service.dart`)
   - Accept major 1 (minor ≥ 1) **or** major 2 (minor ≥ 0). Branch must still be `"main"`.
   - Expose the negotiated major (for example `int apiMajor`) on the API or box state, set in `_connect` / `_connectSerial` in `background_service.dart`.
3. **3-phase command loop** (`lib/core/command_loop.dart`, delta tick at ~L552 and full sync at ~L602)
   - v2: send `AXIS_CALIBRATION_3_A/B/C = calibration3A/B/C` and `AXIS_CALIBRATION_3_REDUCTION_IN_CENTER = (1 − 10^(calibration3Center/10)).clamp(0, 0.2)`.
   - v1: keep the current CENTER/UP/LEFT sends unchanged.
   - Make sure the delta cache keys on the axis, so switching boxes or reconnecting does not suppress the first send.
4. **4-phase center reduction** (optional, but restim exposes it)
   - Add `calibration4CenterReduction` to `DeviceSettings` (default 0.07 to match restim, or 0.14 to match the firmware default; decide when testing), with JSON persistence and reset/load/save in `SettingsProvider`.
   - Add a slider to the 4-phase calibration UI (0–20%).
   - Send axis 45 in both 4-phase loops. On 1.1–1.2 firmware it is ignored, which is harmless.
5. **UI/info**
   - Show the firmware major in the connection status. Show the ESP32 version when present.
   - Update the error text: "needs 1.1+ or 2.x".
6. **Tests** (`foc-companion/test/`)
   - Unit tests: version gate (1.0.9 ✗, 1.1.0 ✓, 1.3.2 ✓, 2.0.0 ✓, 2.0.3 ✓, 3.0.0 ✗, branch ≠ main ✗).
   - Unit tests: center dB → reduction conversion (−0.604 dB ≈ 0.13).
   - Unit tests: v1 vs v2 axis selection in the 3-phase loop.
7. **Hardware validation**
   - On a v2.0.3 box: 3-phase calibration A/B/C and center reduction audibly take effect, 4-phase reduction slider works, and patterns play normally.
   - On a v1.3.2 box: no regression.
8. **Docs**: update `documents/functional_spec/protocol_spec.md`, Task 07 in `TODO.md` (the version range has changed), and `DONE.md`. Bump the app version.

**Estimate:** steps 1–3 and 5–6 come to about half a day. Step 4 adds about 2 h. The main risk is hardware validation (step 7).

## Later / optional (restim parity, not protocol)

- Pulse-frequency volume calibration: multiply volume by `scale(pulseHz)` from `restim/stim_math/pulse_frequency_calibration.py`. This matters more now that pulse frequency can go up to 200 Hz.
- Raise our pulse-frequency clamp from 100 Hz to 200 Hz. In practice the firmware's 5 ms minimum pause caps it at about 150–200 Hz.
