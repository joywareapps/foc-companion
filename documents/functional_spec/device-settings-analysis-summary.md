# Device Settings Analysis Summary

**Analysis Date:** 2025-12-25
**Status:** Discovery phase completed ✅

---

## Executive Summary

Comprehensive analysis of the desktop app's device settings has been completed. All required settings for the mobile app have been identified, documented, and organized into implementation phases.

**Key Findings:**
1. **Device Settings:** Min/max carrier frequency (500/1500 Hz defaults) and waveform amplitude (120 mA default)
2. **Pulse Settings:** Five configurable parameters with validation rules
3. **Vibration Settings:** Identified 12 vibration-related settings to EXCLUDE from mobile implementation
4. **Current Mobile Gaps:** All signal parameters currently hardcoded in CommandLoop - need to be replaced with user-configurable settings

---

## Files Analyzed

### Desktop Application Source Files
1. **`qt_ui/preferences_dialog.py`** - Main preferences dialog with all tabs
2. **`qt_ui/carrier_settings_widget.py`** - Carrier frequency UI with safety limits
3. **`qt_ui/pulse_settings_widget.py`** - Pulse settings UI with duty cycle validation
4. **`qt_ui/vibration_settings_widget.py`** - Vibration settings (EXCLUDED from mobile)
5. **`qt_ui/three_phase_settings_widget.py`** - Threephase calibration settings
6. **`qt_ui/tcode_command_router.py`** - T-Code routing and axis mapping
7. **`qt_ui/settings.py`** - All settings definitions with defaults
8. **`qt_ui/device_wizard/enums.py`** - Device configuration enums
9. **`qt_ui/device_wizard/safety_limits_foc.py`** - FOC-Stim safety limits
10. **`stim_math/limits.py`** - Validation limits and ranges

### Current Mobile Application Files
1. **`src/core/CommandLoop.ts`** - Contains hardcoded signal parameters (needs update)
2. **`src/store/deviceStore.ts`** - Device state management (needs settings extension)
3. **`src/app/(tabs)/settings.tsx`** - Settings UI (currently only IP address)

---

## Key Settings Identified

### 1. Device Configuration Settings (Priority 1)

| Setting | Key | Type | Default | Range | Mobile Implementation |
|---------|-----|------|---------|-------|----------------------|
| Min Carrier Frequency | `device_configuration/min_frequency` | float (Hz) | 500 | 500-2000 | User requested: 500 Hz |
| Max Carrier Frequency | `device_configuration/max_frequency` | float (Hz) | 1000 | 500-2000 | User requested: 1500 Hz |
| Waveform Amplitude | `device_configuration/waveform_amplitude_amps` | float (A) | 0.120 | 0.01-0.15 | User requested: 120 mA |
| Device Type | `device_configuration/device_type` | int (enum) | 0 (NONE) | 0-7 | Fixed: FOCSTIM_THREE_PHASE (5) |
| Waveform Type | `device_configuration/waveform_type` | int (enum) | 1 (CONTINUOUS) | 1-3 | Support: CONTINUOUS (1), PULSE_BASED (2) |

**Current Mobile Status:**
- Carrier frequency: HARDCODED 700 Hz in `CommandLoop.ts:59`
- Amplitude: HARDCODED 0.01 A in `CommandLoop.ts:120` (should be 0.120 A)

### 2. Pulse Settings (Priority 2)

| Setting | Key | Type | Default | Range | Desktop Source |
|---------|-----|------|---------|-------|----------------|
| Pulse Carrier Frequency | `carrier/pulse_carrier_frequency` | float (Hz) | 700 | Device min-max | `pulse_settings_widget.py` |
| Pulse Frequency | `carrier/pulse_frequency` | float (Hz) | 50 | 1-300 | `limits.PulseFrequency` |
| Pulse Width | `carrier/pulse_width` | float (cycles) | 5 | 3-100 | `limits.PulseWidth` |
| Pulse Rise Time | `carrier/pulse_rise_time` | float (cycles) | 10 | 2-100 | `limits.PulseRiseTime` |
| Pulse Interval Random | `carrier/pulse_interval_random` | float (%) | 10 | 0-100 | `pulse_settings_widget.py` |

**Current Mobile Status:**
- Pulse frequency: HARDCODED 50 Hz in `CommandLoop.ts:65`
- Pulse width: HARDCODED 5 cycles in `CommandLoop.ts:71`
- Pulse rise time: HARDCODED 10 cycles in `CommandLoop.ts:77`

**Duty Cycle Validation:**
```
dutyCycle = (pulseFrequency * pulseWidth) / carrierFrequency
if dutyCycle > 1.0:
    Display warning: "Duty cycle exceeds 100%"
```

### 3. FOC-Stim Settings (Priority 2-3)

| Setting | Key | Type | Default | Mobile Status |
|---------|-----|------|---------|---------------|
| WiFi IP | `focstim/wifi_ip` | string | '' | ✅ Already implemented |
| WiFi SSID | `focstim/wifi_ssid` | string | '' | Future feature |
| WiFi Password | `focstim/wifi_password` | string | '' | Future feature |
| Communication Serial | `focstim/communication_serial` | bool | true | False for mobile |
| Communication WiFi | `focstim/communication_wifi` | bool | false | True for mobile |
| Use Teleplot | `focstim/use_teleplot` | bool | true | Optional (debug mode) |
| Dump Notifications | `focstim/dump_notifications_to_file` | bool | false | Optional (debug mode) |

### 4. EXCLUDED Settings (Vibration - Not Applicable to FOC-Stim)

**12 vibration settings identified and EXCLUDED per user request:**

```python
# Vibration 1 settings
vibration_1_enabled = 'vibration/vibration_1_enabled'
vibration_1_frequency = 'vibration/vibration_1_frequency'
vibration_1_strength = 'vibration/vibration_1_strength'
vibration_1_left_right_bias = 'vibration/vibration_1_left_right_bias'
vibration_1_high_low_bias = 'vibration/vibration_1_high_low_bias'
vibration_1_random = 'vibration/vibration_1_random'

# Vibration 2 settings
vibration_2_enabled = 'vibration/vibration_2_enabled'
vibration_2_frequency = 'vibration/vibration_2_frequency'
vibration_2_strength = 'vibration/vibration_2_strength'
vibration_2_left_right_bias = 'vibration/vibration_2_left_right_bias'
vibration_2_high_low_bias = 'vibration/vibration_2_high_low_bias'
vibration_2_random = 'vibration/vibration_2_random'
```

**Reason for exclusion:** These settings control amplitude modulation vibration overlays for audio-based devices. FOC-Stim uses direct electrical stimulation and does not use the vibration modulation system.

---

## Implementation Plan

### Phase 1: Settings Infrastructure (Priority 1)
**Goal:** Create settings service with persistence
**Tasks:**
- TypeScript interfaces for all settings structures
- AsyncStorage persistence layer with load/save methods
- Settings validation utilities
- Zustand store integration

**Critical:** This enables all subsequent phases.

### Phase 2: Device Settings UI (Priority 1)
**Goal:** User-configurable safety limits
**Tasks:**
- New "Device Settings" tab screen
- Min/max carrier frequency sliders (500-2000 Hz range)
- Waveform amplitude slider (10-150 mA range)
- Real-time validation with error messages
- Reset to defaults button

**User Impact:** Replaces hardcoded values with safe, user-controlled limits.

### Phase 3: CommandLoop Integration (Priority 1 - CRITICAL)
**Goal:** Use configured settings instead of hardcoded values
**Tasks:**
- Inject settings into CommandLoop
- Replace 6 hardcoded values with setting references
- Add validation before pattern start
- Test with real device

**Safety Critical:** Ensures device operates within user-configured safety limits.

### Phase 4: Pulse Settings UI (Priority 2)
**Goal:** Advanced pulse configuration
**Tasks:**
- Pulse parameters UI panel
- Duty cycle calculation and warning display
- Settings persistence
- Real device testing with various configurations

**User Impact:** Allows fine-tuning of stimulation patterns.

### Phase 5: FOC-Stim Preferences (Priority 3)
**Goal:** Enhanced preferences
**Tasks:**
- WiFi SSID/password configuration (future)
- Debugging toggles (developer mode)
- Network tab placeholder

**User Impact:** Quality-of-life improvements, not critical for MVP.

---

## Validation Rules Summary

### Frequency Validation
```typescript
// Individual ranges
minFrequency >= 500 && minFrequency <= 2000
maxFrequency >= 500 && maxFrequency <= 2000

// Relationship
minFrequency < maxFrequency
```

### Amplitude Validation
```typescript
waveformAmplitude >= 0.01 && waveformAmplitude <= 0.15  // Amperes
// Display in mA: value * 1000
```

### Pulse Parameter Validation
```typescript
pulseFrequency >= 1 && pulseFrequency <= 300  // Hz
pulseWidth >= 3 && pulseWidth <= 100          // cycles
pulseRiseTime >= 2 && pulseRiseTime <= 100    // cycles
pulseIntervalRandom >= 0 && pulseIntervalRandom <= 100  // %
```

### Duty Cycle Warning
```typescript
const dutyCycle = (pulseFrequency * pulseWidth) / carrierFrequency;
if (dutyCycle > 1.0) {
  showWarning("Duty cycle exceeds 100% - reduce pulse width or frequency");
}
```

---

## Current Mobile Implementation Gaps

### Hardcoded Values in `CommandLoop.ts`

**File:** `src/core/CommandLoop.ts`

| Line | Current Value | Should Be | Setting Source |
|------|---------------|-----------|----------------|
| 59 | `AXIS_CARRIER_FREQUENCY_HZ: 700` | User-configured | `deviceSettings.minFrequency` (or use as default) |
| 65 | `AXIS_PULSE_FREQUENCY_HZ: 50` | User-configured | `pulseSettings.pulseFrequency` |
| 71 | `AXIS_PULSE_WIDTH_IN_CYCLES: 5` | User-configured | `pulseSettings.pulseWidth` |
| 77 | `AXIS_PULSE_RISE_TIME_CYCLES: 10` | User-configured | `pulseSettings.pulseRiseTime` |
| 120 | `AXIS_WAVEFORM_AMPLITUDE_AMPS: 0.01` | User-configured (0.120 default) | `deviceSettings.waveformAmplitude` |

**Impact:** Current conservative amplitude (0.01 A = 10 mA) is 12x lower than desktop default (0.120 A = 120 mA). Users may experience weak stimulation.

---

## Deliverables Completed

1. ✅ **Comprehensive Settings Specification** - `documents/functional_spec/device-settings-spec.md`
   - 11 sections covering all aspects of settings implementation
   - TypeScript interface definitions
   - Validation rules with code examples
   - UI/UX design recommendations
   - Testing requirements

2. ✅ **Updated TODO.md** - Detailed task breakdown in `TODO.md`
   - 8 subsections in Phase 4: Device Settings Implementation
   - 4.1 Discovery & Documentation (COMPLETED)
   - 4.2 Settings Infrastructure (Priority 1)
   - 4.3 Device Settings UI (Priority 1)
   - 4.4 Pulse Settings UI (Priority 2)
   - 4.5 FOC-Stim Preferences UI (Priority 2)
   - 4.6 CommandLoop Integration (Priority 1 - CRITICAL)
   - 4.7 Testing & Validation (Priority 1)
   - 4.8 Documentation Updates

3. ✅ **Analysis Summary** - This document
   - Executive summary of findings
   - Complete settings inventory
   - Implementation phases
   - Current gaps identified

---

## Next Steps

### Immediate Priority (Start Implementation)

1. **Create Settings Service** (`src/services/SettingsService.ts`)
   - TypeScript interfaces for all settings
   - AsyncStorage persistence
   - Default values (min: 500Hz, max: 1500Hz, amplitude: 0.120A)
   - Validation functions

2. **Extend Device Store** (`src/store/deviceStore.ts`)
   - Add settings state
   - Add load/save actions
   - Initialize on app start

3. **Update CommandLoop** (`src/core/CommandLoop.ts`)
   - Replace 6 hardcoded values with settings
   - Add validation before pattern start
   - Test with real device

4. **Create Device Settings UI** (`src/app/(tabs)/device-settings.tsx`)
   - Frequency range sliders
   - Amplitude slider
   - Validation and save

---

## Risk Assessment

### High Risk (Immediate Attention)
- **Hardcoded Amplitude Too Low:** Current 10 mA vs desktop 120 mA default may cause weak/ineffective stimulation
- **No User Control:** Users cannot adjust safety limits or stimulation intensity
- **No Validation:** No protection against unsafe parameter combinations

### Medium Risk (Phase 2)
- **Duty Cycle Issues:** Without duty cycle validation, users could configure harmful pulse parameters
- **Settings Persistence:** Without proper save/load, settings may be lost on app restart

### Low Risk (Future Phases)
- **Missing Advanced Features:** Volume settings, funscript conversion (deferred to later phases)

---

## Success Criteria

### Phase 1 (Settings Infrastructure)
- [ ] Settings load/save correctly to AsyncStorage
- [ ] Default values match desktop app specifications
- [ ] Validation functions prevent invalid configurations
- [ ] Settings persist across app restarts

### Phase 2 (Device Settings UI)
- [ ] Users can configure min/max frequency (500-2000 Hz range)
- [ ] Users can configure amplitude (10-150 mA range)
- [ ] Real-time validation with error messages
- [ ] Reset to defaults works correctly

### Phase 3 (CommandLoop Integration)
- [ ] All 6 hardcoded values replaced with settings
- [ ] Amplitude defaults to 120 mA (not 10 mA)
- [ ] Pattern behavior changes correctly with different settings
- [ ] Real device testing confirms safe operation

### Phase 4 (Pulse Settings)
- [ ] Duty cycle calculation and warning display
- [ ] All pulse parameters user-configurable
- [ ] Real device testing with various configurations

---

## Conclusion

**Discovery phase completed successfully.** All required settings have been identified, documented, and organized for implementation. The desktop app analysis revealed:

1. **12 settings to implement** across device configuration, pulse parameters, and FOC-Stim preferences
2. **12 settings to exclude** (vibration-related, not applicable to FOC-Stim)
3. **6 critical hardcoded values** in CommandLoop that need to be replaced
4. **Clear implementation path** with prioritized phases

**Ready to begin implementation** following the task breakdown in TODO.md Phase 4.
