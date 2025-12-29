# FOC Companion Mobile - Implementation Status & Specifications

**Document Version:** 2.0
**Last Updated:** 2025-12-25
**Status:** Active Development - MVP Complete

---

## Table of Contents

1. [Implementation Summary](#implementation-summary)
2. [Protocol Communication Fixed](#protocol-communication-fixed)
3. [Settings System Architecture](#settings-system-architecture)
4. [Implemented Features](#implemented-features)
5. [Pending Features with Specifications](#pending-features-with-specifications)
6. [Protobuf Protocol Mapping](#protobuf-protocol-mapping)

---

## 1. Implementation Summary

### Completed Phases

**✅ Phase 1-3: MVP Core (Completed Earlier)**
- TCP/IP communication with FOC-Stim device
- Protobuf message encoding/decoding
- Device connection management
- Circle pattern playback
- Device status notifications

**✅ Phase 4.1: Desktop App Analysis (Completed)**
- Analyzed 10+ desktop app source files
- Documented all settings with defaults and limits
- Identified vibration settings to exclude
- Created comprehensive specifications

**✅ Phase 4.2: Settings Infrastructure (Completed)**
- TypeScript type system (`src/types/settings.ts`)
- AsyncStorage persistence (`src/services/SettingsService.ts`)
- Validation utilities (`src/services/SettingsValidator.ts`)
- Zustand store integration (`src/store/deviceStore.ts`)
- Settings loaded on app startup

**✅ Phase 4.3: Device Settings UI (Completed)**
- Min/Max carrier frequency sliders (500-2000 Hz)
- Waveform amplitude slider (10-150 mA)
- Real-time validation with error display
- Save/Reset functionality
- Removed inapplicable waveform type setting (vibration-only)

**✅ Phase 4.6: CommandLoop Integration (CRITICAL - Completed)**
- Replaced all 6 hardcoded values with user settings
- **CRITICAL FIX**: Amplitude from 0.01A (10mA) → 0.120A (120mA) default
- Settings validation before pattern start
- Dynamic configuration on each start

**✅ Phase 4.5 (Partial): FOC-Stim Preferences UI**
- WiFi IP configuration in Settings tab
- IP address persistence and auto-sync
- Connection info and troubleshooting tips

**✅ UI/UX Improvements**
- Compact device status display (single line format)
- IP configuration moved to Settings tab
- Cleaner Control tab focused on connection and playback

---

## 2. Protocol Communication Fixed

### Issue Discovery

Analysis of `documents/functional_spec/protocol-example.txt` revealed the correct initialization sequence.

### Critical Fixes Implemented

**Before Signal Start (Lines 5-86 in protocol-example.txt):**
```
request_axis_move_to(AXIS_POSITION_ALPHA, value=0, interval=0)
request_axis_move_to(AXIS_POSITION_BETA, value=0, interval=0)
request_axis_move_to(AXIS_WAVEFORM_AMPLITUDE_AMPS, value=0, interval=0)
request_axis_move_to(AXIS_CARRIER_FREQUENCY_HZ, value=700, interval=0)
request_axis_move_to(AXIS_PULSE_FREQUENCY_HZ, value=50, interval=0)
request_axis_move_to(AXIS_PULSE_WIDTH_IN_CYCLES, value=5, interval=0)
request_axis_move_to(AXIS_PULSE_RISE_TIME_CYCLES, value=10, interval=0)
request_axis_move_to(AXIS_PULSE_INTERVAL_RANDOM_PERCENT, value=0.1, interval=0)
request_axis_move_to(AXIS_CALIBRATION_3_CENTER, value=-0.7, interval=0)
request_axis_move_to(AXIS_CALIBRATION_3_UP, value=0, interval=0)
request_axis_move_to(AXIS_CALIBRATION_3_LEFT, value=0, interval=0)
request_signal_start(mode=OUTPUT_THREEPHASE)
```

**After Signal Start (Lines 168-474):**
- Position updates with `interval=30` (30ms interpolation)
- Amplitude updates with `interval=30`
- All signal parameter updates with `interval=30`

### Implementation Status

**✅ Implemented in `src/core/CommandLoop.ts`:**
- Initial position axes reset (alpha, beta)
- Signal parameters configured from settings before start
- Pattern loop uses `interval=50` for all updates
- Amplitude now dynamic from `deviceSettings.waveformAmplitude`
- `AXIS_PULSE_INTERVAL_RANDOM_PERCENT` from user settings (0-100% range)
- `AXIS_CALIBRATION_3_CENTER` (hardcoded: -0.7)
- `AXIS_CALIBRATION_3_UP` (hardcoded: 0)
- `AXIS_CALIBRATION_3_LEFT` (hardcoded: 0)

**⚠️ Not Yet Implemented:**
- `AXIS_WAVEFORM_AMPLITUDE_AMPS` initial reset to 0 (Phase 4.8)

---

## 3. Settings System Architecture

### Storage Keys (AsyncStorage)

```typescript
STORAGE_KEYS = {
  DEVICE_SETTINGS: '@foccompanion/device_settings',
  PULSE_SETTINGS: '@foccompanion/pulse_settings',
  FOCSTIM_SETTINGS: '@foccompanion/focstim_settings',
}
```

### Type System

**DeviceSettings:**
```typescript
interface DeviceSettings {
  deviceType: DeviceType;           // FOCSTIM_THREE_PHASE (5)
  waveformType: WaveformType;       // Not used for FOC-Stim (vibration only)
  minFrequency: number;             // Hz, default: 500
  maxFrequency: number;             // Hz, default: 1500
  waveformAmplitude: number;        // Amps, default: 0.120 (120 mA)
}
```

**PulseSettings:**
```typescript
interface PulseSettings {
  carrierFrequency: number;         // Hz, default: 700
  pulseFrequency: number;           // Hz, default: 50
  pulseWidth: number;               // cycles, default: 5
  pulseRiseTime: number;            // cycles, default: 10
  pulseIntervalRandom: number;      // %, default: 10 (0.1 in protocol)
}
```

**FocStimSettings:**
```typescript
interface FocStimSettings {
  wifiIp: string;                   // Default: ''
  wifiSsid: string;                 // Default: ''
  wifiPassword: string;             // Default: ''
}
```

### Validation Limits (from `stim_math/limits.py`)

```typescript
SettingsLimits = {
  CarrierFrequency: { min: 500, max: 2000 },      // Hz
  WaveformAmplitude: { min: 0.01, max: 0.15 },    // Amps (10-150 mA)
  PulseFrequency: { min: 1, max: 100 },           // Hz - FOC-Stim hardware limit
  PulseWidth: { min: 3, max: 15 },                // cycles - FOC-Stim hardware limit
  PulseRiseTime: { min: 2, max: 5 },              // cycles - FOC-Stim hardware limit
  PulseIntervalRandom: { min: 0, max: 100 },      // %
}
```

### Duty Cycle Validation

**Formula:** `(pulseFreq * pulseWidth) / carrierFreq`

**Warning if > 100%:** Displayed in UI with suggested fixes.

---

## 4. Implemented Features

### Device Settings Screen (`src/app/(tabs)/device-settings.tsx`)

**Safety Limits Section:**
- ✅ Min Carrier Frequency: 500-2000 Hz, step 10 Hz, default 500 Hz
- ✅ Max Carrier Frequency: 500-2000 Hz, step 10 Hz, default 1500 Hz
- ✅ Real-time validation (min < max)

**Waveform Settings Section:**
- ✅ Amplitude: 10-150 mA, step 1 mA, default 120 mA
- ✅ Display in mA (converted from/to Amps internally)

**Device Configuration Section:**
- ✅ Device Type: Display only (FOC-Stim V3 / 3-Phase)
- ✅ Info note explaining FOC-Stim operation

**Actions:**
- ✅ Save Settings: Disabled when no changes or validation errors
- ✅ Reset to Defaults: With confirmation dialog

### Settings Tab (`src/app/(tabs)/settings.tsx`)

**WiFi Configuration:**
- ✅ Device IP Address input with validation
- ✅ Auto-sync to `deviceStore.ipAddress`
- ✅ Persistence across app restarts
- ✅ Connection info and troubleshooting tips

### Control Tab (`src/app/(tabs)/index.tsx`)

**Device Connection:**
- ✅ Status display with configured IP
- ✅ Compact format: "Disconnected (192.168.1.100)"
- ✅ Link to Settings when IP not configured
- ✅ Connect button disabled without IP

**Device Status:**
- ✅ Compact single-line format
- ✅ Example: "Temp: 25.0°C | 🔋 3.7V - 85%"
- ✅ Battery (🔋) or wall power (🔌) icons
- ✅ Temperature, voltage, charge percentage

**Pattern Control:**
- ✅ Start/Stop Circle Pattern button
- ✅ Visible when connected

### CommandLoop Integration (`src/core/CommandLoop.ts`)

**Settings Usage:**
```typescript
// Before start - validation
const validation = validateAppSettings(settings);
if (!validation.valid) throw Error;

// Setup signal parameters
AXIS_CARRIER_FREQUENCY_HZ = pulseSettings.carrierFrequency
AXIS_PULSE_FREQUENCY_HZ = pulseSettings.pulseFrequency
AXIS_PULSE_WIDTH_IN_CYCLES = pulseSettings.pulseWidth
AXIS_PULSE_RISE_TIME_CYCLES = pulseSettings.pulseRiseTime

// During tick loop
AXIS_WAVEFORM_AMPLITUDE_AMPS = deviceSettings.waveformAmplitude
```

---

## 5. Pending Features with Specifications

### Phase 4.4: Pulse Settings UI (Priority 2)

**Component:** `src/components/PulseSettingsPanel.tsx` or new tab

**Settings to Implement:**

#### Carrier Frequency
- **Protobuf Axis:** `AXIS_CARRIER_FREQUENCY_HZ`
- **Range:** Device min/max frequency (500-1500 Hz by default)
- **Default:** 700 Hz
- **UI:** Slider with real-time value display
- **Validation:** Must be within `deviceSettings.minFrequency` and `maxFrequency`

#### Pulse Frequency
- **Protobuf Axis:** `AXIS_PULSE_FREQUENCY_HZ`
- **Range:** 1-300 Hz (from `SettingsLimits.PulseFrequency`)
- **Default:** 50 Hz
- **UI:** Slider with Hz display
- **Validation:** Check duty cycle calculation

#### Pulse Width
- **Protobuf Axis:** `AXIS_PULSE_WIDTH_IN_CYCLES`
- **Range:** 3-100 cycles (from `SettingsLimits.PulseWidth`)
- **Default:** 5 cycles
- **UI:** Slider with cycle count display
- **Validation:** Check duty cycle calculation
- **Duty Cycle Formula:** `(pulseFreq * pulseWidth) / carrierFreq`
- **Warning Display:** If > 100%, show: "Duty cycle (X%) exceeds 100% - reduce pulse width or frequency"

#### Pulse Rise Time
- **Protobuf Axis:** `AXIS_PULSE_RISE_TIME_CYCLES`
- **Range:** 2-100 cycles (from `SettingsLimits.PulseRiseTime`)
- **Default:** 10 cycles
- **UI:** Slider with cycle count display
- **Description:** "Controls how quickly the pulse reaches full amplitude"

#### Pulse Interval Random
- **Protobuf Axis:** `AXIS_PULSE_INTERVAL_RANDOM_PERCENT`
- **Range:** 0-100% (from `SettingsLimits.PulseIntervalRandom`)
- **Default:** 10%
- **Protocol Value:** Percentage / 100 (e.g., 10% → 0.1)
- **UI:** Slider with % display
- **Description:** "Randomizes pulse timing to prevent habituation"
- **Note:** Currently NOT sent in CommandLoop initialization

**Implementation Tasks:**
- [ ] Create pulse settings UI component
- [ ] Add duty cycle calculation display
- [ ] Add warning when duty cycle > 100%
- [ ] Real-time validation on slider changes
- [ ] Save/Reset functionality
- [ ] Update CommandLoop to send `AXIS_PULSE_INTERVAL_RANDOM_PERCENT`

### Phase 4.7: Missing Calibration Parameters (Priority 2)

**Based on protocol-example.txt analysis, these are missing:**

#### Calibration 3-Phase Center
- **Protobuf Axis:** `AXIS_CALIBRATION_3_CENTER`
- **Default:** -0.7 (from protocol example)
- **Type:** float
- **Description:** Center point calibration for 3-phase output
- **Implementation:** Add to `setupSignalParameters()` in CommandLoop
- **UI:** Advanced settings section (optional for MVP)

#### Calibration 3-Phase Up
- **Protobuf Axis:** `AXIS_CALIBRATION_3_UP`
- **Default:** 0 (from protocol example)
- **Type:** float
- **Description:** Upward axis calibration for 3-phase output
- **Implementation:** Add to `setupSignalParameters()` in CommandLoop
- **UI:** Advanced settings section (optional for MVP)

#### Calibration 3-Phase Left
- **Protobuf Axis:** `AXIS_CALIBRATION_3_LEFT`
- **Default:** 0 (from protocol example)
- **Type:** float
- **Description:** Leftward axis calibration for 3-phase output
- **Implementation:** Add to `setupSignalParameters()` in CommandLoop
- **UI:** Advanced settings section (optional for MVP)

**Implementation Tasks:**
- [ ] Add calibration settings to `DeviceSettings` type
- [ ] Add calibration defaults to `DefaultSettings`
- [ ] Update CommandLoop to send calibration parameters before signal start
- [ ] (Optional) Add UI for calibration in advanced settings

### Phase 4.8: Initial Amplitude Reset (Priority 3)

**Based on protocol-example.txt line 18-24:**

```
request_axis_move_to {
  axis: AXIS_WAVEFORM_AMPLITUDE_AMPS
  value: 0
  interval: 0
}
```

**Purpose:** Reset amplitude to 0 before signal start, then ramp up during playback

**Implementation:**
- [ ] Add amplitude reset in `setupSignalParameters()`
- [ ] Verify this doesn't conflict with dynamic amplitude setting
- [ ] Test with real device to confirm expected behavior

---

## 6. Protobuf Protocol Mapping

### Complete Axis Types Used

From `src/generated/protobuf/constants_pb.ts`:

| Axis Type | Setting Source | Default | Implemented |
|-----------|---------------|---------|-------------|
| `AXIS_POSITION_ALPHA` | Pattern calculation | 0 | ✅ |
| `AXIS_POSITION_BETA` | Pattern calculation | 0 | ✅ |
| `AXIS_WAVEFORM_AMPLITUDE_AMPS` | `deviceSettings.waveformAmplitude` | 0.120 A | ✅ |
| `AXIS_CARRIER_FREQUENCY_HZ` | `pulseSettings.carrierFrequency` | 700 Hz | ✅ |
| `AXIS_PULSE_FREQUENCY_HZ` | `pulseSettings.pulseFrequency` | 50 Hz | ✅ |
| `AXIS_PULSE_WIDTH_IN_CYCLES` | `pulseSettings.pulseWidth` | 5 cycles | ✅ |
| `AXIS_PULSE_RISE_TIME_CYCLES` | `pulseSettings.pulseRiseTime` | 3 cycles | ✅ |
| `AXIS_PULSE_INTERVAL_RANDOM_PERCENT` | `pulseSettings.pulseIntervalRandom` | 0.1 (10%) | ✅ |
| `AXIS_CALIBRATION_3_CENTER` | Hardcoded | -0.7 | ✅ |
| `AXIS_CALIBRATION_3_UP` | Hardcoded | 0 | ✅ |
| `AXIS_CALIBRATION_3_LEFT` | Hardcoded | 0 | ✅ |

### Request Message Structure

**Initial Setup (interval=0):**
```typescript
{
  case: 'requestAxisMoveTo',
  value: {
    axis: AxisType,
    value: number,
    interval: 0
  }
}
```

**Runtime Updates (interval=50ms):**
```typescript
{
  case: 'requestAxisMoveTo',
  value: {
    axis: AxisType,
    value: number,
    interval: 50  // Device interpolates to this value over 50ms
  }
}
```

### Signal Control Messages

**Start Signal:**
```typescript
{
  case: 'requestSignalStart',
  value: {
    mode: OutputMode.OUTPUT_THREEPHASE
  }
}
```

**Stop Signal:**
```typescript
{
  case: 'requestSignalStop',
  value: {}
}
```

### Notification Handling

**Implemented in `src/store/deviceStore.ts`:**

| Notification Type | Updates |
|------------------|---------|
| `notification_system_stats` | `temperature` |
| `notification_battery` | `batteryVoltage`, `batterySoc` |
| `notification_signal_stats` | `pulseFrequency` |
| Wall power detection | `wallPowerPresent` (from `battery_charge_rate_watt > 0`) |

---

## Summary

### What's Working
- ✅ Complete settings infrastructure with persistence
- ✅ Device Settings UI with validation
- ✅ WiFi IP configuration
- ✅ CommandLoop using dynamic settings
- ✅ **Critical amplitude fix** (10mA → 120mA)
- ✅ Compact UI optimizations
- ✅ Real device communication working

### What's Missing
- ⚠️ Initial amplitude reset to 0 (Phase 4.8 - optional enhancement)

### Priority Next Steps
1. ✅ ~~Create Pulse Settings UI with duty cycle display (Phase 4.4)~~ - COMPLETED
2. ✅ ~~Add missing calibration parameters to CommandLoop (Phase 4.7)~~ - COMPLETED
3. ✅ ~~Add pulse interval random to CommandLoop (Phase 4.4)~~ - COMPLETED
4. Test all settings changes with real device (Phase 4.7)
