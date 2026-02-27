# Task 09: Model Estimation (Impedance) Display

## Status: DONE (2026-02-27)

## Background

The FOC-Stim firmware continuously estimates the electrical impedance of each output
channel using a gradient-descent algorithm that compares commanded vs. measured
current. It sends these estimates via `NotificationModelEstimation` (proto field 4
in `Notification`).

### What the firmware measures

Each channel's load impedance is modelled as a complex number:

```
Z_a = resistance_a + j * reluctance_a   (channel A)
Z_b = resistance_b + j * reluctance_b   (channel B)
Z_c = resistance_c + j * reluctance_c   (channel C)
Z_d = resistance_d + j * reluctance_d   (channel D, 4-phase only)
```

The `resistance_*` fields carry the real (resistive) part and `reluctance_*` carries
the imaginary (reactive) part. Both are in ohms. The firmware already applies the
`STIM_WINDING_RATIO_SQ` scaling before transmitting, so the values represent the
**body-side impedance** in ohms directly.

The `constant` field (proto field 20) represents the fixed output-stage resistance;
not currently populated by the firmware (always 0).

### Derived quantity displayed

```
|Z_a| = sqrt(resistance_a² + reluctance_a²)   # magnitude in Ω
```

restim (commit c0f012c, 2026-02-26) also logs the phase angle `atan2(reluctance,
resistance)` to its teleplot overlay, but the app only shows magnitude as it is
the most useful quantity for electrode contact quality.

### Transmission cadence

- Sent every **50 pulses** (at `pulse_counter % 50 == 20`) by the firmware.
- At 60 Hz pulse frequency this is roughly **1.2 Hz**.
- Only sent while **actively playing** (3-phase or 4-phase). Not sent when stopped.
- In **3-phase** mode: channels A, B, C carry data; D fields are zero.
- In **4-phase** mode: all four channels carry data.

---

## Implementation (completed)

### `device_provider.dart`

Added four nullable `double?` fields: `impedanceA`, `impedanceB`, `impedanceC`,
`impedanceD`. These are updated in `_handleNotification` when
`hasNotificationModelEstimation()` is true, and cleared to `null` on disconnect.
`impedanceD` is kept `null` in 3-phase mode (firmware sends 0.0/0.0 for D).

```dart
static double _calcImpedance(double r, double x) => math.sqrt(r * r + x * x);
```

### `device_settings_screen.dart` (calibration overlay)

**4-phase mode**: `impedance` parameter added to `_buildSlider`. Each electrode
slider (A/B/C/D) shows a coloured badge `_ImpedanceBadge` to the right of the
label when data is available.

**3-phase mode**: sliders don't map 1:1 to channels, so a compact `_ImpedanceRow`
is appended below the sliders when data is available showing Ch A / Ch B / Ch C.

### Badge colour thresholds

| Impedance (Ω) | Colour | Interpretation |
|---------------|--------|----------------|
| < 600         | Green  | Good contact   |
| 600 – 1000    | Amber  | Fair contact   |
| > 1000        | Red    | Poor contact   |

---

## Notes

- Values appear only while the device is actively playing; badges are hidden
  otherwise (field is `null`).
- The estimate needs a few seconds to converge after starting — early readings
  may be noisy, especially at low volume.
- At very low output levels (< ~20 mA) the firmware skips the phase angle update
  but magnitude still updates.
