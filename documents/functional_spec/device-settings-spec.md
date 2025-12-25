# Device Settings Specification for FOC Companion Mobile App

**Document Version:** 1.0
**Date:** 2025-12-25
**Based on:** restim-desktop repository analysis

---

## 1. Overview

This document specifies the device settings that need to be implemented in the FOC Companion mobile application, based on the desktop application's settings structure. The settings are divided into two main categories:

1. **Device Selection Settings** (Setup → Device Selection)
2. **Preferences Settings** (Setup → Preferences)

---

## 2. Device Selection Settings

### 2.1 Device Type
**Location:** Device Configuration Wizard
**Setting Key:** `device_configuration/device_type`
**Type:** Enum (int)
**Default:** 0 (NONE)

**Available Device Types:**
```typescript
enum DeviceType {
  NONE = 0,
  AUDIO_THREE_PHASE = 1,
  FOCSTIM_THREE_PHASE = 5,  // FOC-Stim V3 (primary for mobile app)
  NEOSTIM_THREE_PHASE = 6,
  FOCSTIM_FOUR_PHASE = 7
}
```

**Mobile Implementation:** Support `FOCSTIM_THREE_PHASE` only for MVP.

### 2.2 Waveform Type
**Location:** Device Configuration Wizard
**Setting Key:** `device_configuration/waveform_type`
**Type:** Enum (int)
**Default:** 1 (CONTINUOUS)

**Available Waveform Types:**
```typescript
enum WaveformType {
  CONTINUOUS = 1,      // Continuous carrier signal
  PULSE_BASED = 2,     // Pulse-based modulation
  A_B_TESTING = 3      // A/B testing mode
}
```

**Mobile Implementation:** Support both CONTINUOUS and PULSE_BASED modes.

### 2.3 Carrier Frequency Range (Safety Limits)

#### 2.3.1 Minimum Frequency
**Location:** Device Configuration Wizard → Safety Limits
**Setting Key:** `device_configuration/min_frequency`
**Type:** float (Hz)
**Default:** 500 Hz
**Valid Range:** 500 - 2000 Hz (from `limits.CarrierFrequencyFOC`)
**User Requested Default:** 500 Hz

**Usage:** Lower bound for carrier frequency safety limit. Applied to carrier frequency controls to prevent dangerous low-frequency settings.

#### 2.3.2 Maximum Frequency
**Location:** Device Configuration Wizard → Safety Limits
**Setting Key:** `device_configuration/max_frequency`
**Type:** float (Hz)
**Default:** 1000 Hz
**User Requested Default:** 1500 Hz
**Valid Range:** 500 - 2000 Hz (from `limits.CarrierFrequencyFOC`)

**Usage:** Upper bound for carrier frequency safety limit. Applied to carrier frequency controls to define the safe operating range.

**Validation:** `min_frequency < max_frequency` (enforced in device wizard)

### 2.4 Waveform Amplitude
**Location:** Device Configuration Wizard → Safety Limits (FOC-Stim)
**Setting Key:** `device_configuration/waveform_amplitude_amps`
**Type:** float (Amperes)
**Default:** 0.120 A (120 mA)
**Valid Range:** 0.01 - 0.15 A (10 - 150 mA, from `limits.WaveformAmpltiudeFOC`)
**UI Display Units:** Milliamps (mA)
**User Requested Default:** 120 mA

**Usage:** Maximum waveform amplitude for FOC-Stim device. Controls the intensity of the electrical stimulation.

**Current Mobile Implementation:** Hardcoded 0.01 A (10 mA) in `CommandLoop.ts:120` - very conservative safe value.

---

## 3. Preferences Settings

### 3.1 FOC-Stim Tab

#### 3.1.1 Communication Method
**Setting Keys:**
- `focstim/communication_serial` - Default: true (bool)
- `focstim/communication_wifi` - Default: false (bool)

**Mobile Implementation:** Only WiFi mode supported initially (Serial/USB lower priority).

#### 3.1.2 WiFi Configuration
**Setting Keys:**
- `focstim/wifi_ssid` - Default: '' (string) - WiFi network name
- `focstim/wifi_password` - Default: '' (string) - WiFi password
- `focstim/wifi_ip` - Default: '' (string) - Device IP address

**Mobile Implementation:**
- Display IP address input field (already implemented in Settings screen)
- Add SSID and password fields for WiFi configuration sync (future feature)
- Include "Read IP" and "Sync WiFi Settings" buttons (requires serial connection)

#### 3.1.3 Debugging Features (Optional for Mobile)
**Setting Keys:**
- `focstim/use_teleplot` - Default: true (bool) - Enable Teleplot visualization
- `focstim/teleplot_prefix` - Default: '' (string) - Teleplot topic prefix
- `focstim/dump_notifications_to_file` - Default: false (bool) - Log notifications

**Mobile Implementation:** Consider for debugging/developer mode only.

### 3.2 Network Tab
**Mobile Implementation:** Leave empty for now (placeholder for future serial/USB support).

### 3.3 Funscript/T-Code Tab

**Scope:** All settings EXCEPT those with names starting with "vibration".

#### 3.3.1 Pulse Settings

**Desktop Settings Keys:**
```python
pulse_carrier_frequency = 'carrier/pulse_carrier_frequency'    # Default: 700 Hz
pulse_frequency = 'carrier/pulse_frequency'                    # Default: 50 Hz
pulse_width = 'carrier/pulse_width'                            # Default: 5 cycles
pulse_interval_random = 'carrier/pulse_interval_random'        # Default: 10%
pulse_rise_time = 'carrier/pulse_rise_time'                    # Default: 10 cycles
```

**Valid Ranges (from `stim_math/limits.py`):**
- **Pulse Carrier Frequency:** Use device min/max frequency settings
- **Pulse Frequency:** 1 - 300 Hz (`limits.PulseFrequency`)
- **Pulse Width:** 3 - 100 cycles (`limits.PulseWidth`)
- **Pulse Interval Random:** 0 - 100% (randomization factor)
- **Pulse Rise Time:** 2 - 100 cycles (`limits.PulseRiseTime`)

**Current Mobile Implementation:** Hardcoded in `CommandLoop.ts` `setupSignalParameters()`:
```typescript
carrier_frequency: 700 Hz  (line 59)
pulse_frequency: 50 Hz     (line 65)
pulse_width: 5 cycles      (line 71)
pulse_rise_time: 10 cycles (line 77)
```

**Mobile Implementation Required:**
- Create UI controls for all pulse settings
- Use configured values instead of hardcoded constants
- Apply validation based on limits
- Display duty cycle warning if `(pulse_freq * pulse_width / carrier_freq) > 1`

#### 3.3.2 Volume Settings

**Desktop Settings Keys:**
```python
volume_default_level = 'volume/default_level'                    # Default: 10.0
volume_ramp_target = 'volume/ramp_target'                        # Default: 1.0
volume_ramp_increment_rate = 'volume/increment_rate'             # Default: 1.0
volume_inactivity_time = 'volume/inactivity_ramp_time'           # Default: 3.0s
volume_inactivity_threshold = 'volume/inactivity_inactive_threshold' # Default: 2.0
volume_inactivity_volume = 'volume/inactivity_reduction'         # Default: 0.0
volume_slow_start_time = 'volume/slow_start_time'                # Default: 1.0s
tau_us = 'volume/tau_us'                                         # Default: 355μs
```

**Mobile Implementation:** Consider for later phase (not critical for MVP).

#### 3.3.3 Funscript Conversion Settings

**Desktop Settings Keys:**
```python
funscript_conversion_random_direction_change_probability = 'funscript/random_direction_change_probability'  # Default: 0.1
```

**Mobile Implementation:** Defer to future phase (funscript playback feature).

#### 3.3.4 Settings to EXCLUDE (Vibration-related)

**All settings starting with "vibration" must be excluded per user request:**

```python
# EXCLUDED - Do not implement in mobile app
vibration_1_enabled = 'vibration/vibration_1_enabled'
vibration_1_frequency = 'vibration/vibration_1_frequency'
vibration_1_strength = 'vibration/vibration_1_strength'
vibration_1_left_right_bias = 'vibration/vibration_1_left_right_bias'
vibration_1_high_low_bias = 'vibration/vibration_1_high_low_bias'
vibration_1_random = 'vibration/vibration_1_random'

vibration_2_enabled = 'vibration/vibration_2_enabled'
vibration_2_frequency = 'vibration/vibration_2_frequency'
vibration_2_strength = 'vibration/vibration_2_strength'
vibration_2_left_right_bias = 'vibration/vibration_2_left_right_bias'
vibration_2_high_low_bias = 'vibration/vibration_2_high_low_bias'
vibration_2_random = 'vibration/vibration_2_random'
```

**Reason:** Vibration features are not applicable to FOC-Stim threephase operation.

---

## 4. Desktop UI Structure Analysis

### 4.1 Preferences Dialog Structure
**File:** `qt_ui/preferences_dialog.py`

**Tab Organization:**
1. **Network Tab** - Server settings (WebSocket, TCP, UDP, Serial, Buttplug)
2. **Audio Tab** - Audio device selection
3. **FOC-Stim Tab** - FOC-Stim specific settings (serial port, WiFi, debugging)
4. **NeoStim Tab** - NeoStim specific settings
5. **Media Sync Tab** - Media player integration
6. **Display Tab** - Display FPS and latency
7. **Funscript Tab** - Funscript mapping table
8. **Patterns Tab** - Pattern enable/disable

**Mobile Simplification:**
- Combine relevant settings into fewer screens
- Focus on FOC-Stim specific settings only
- Defer pattern management and media sync features

### 4.2 Settings Persistence
**Desktop Implementation:** Qt Settings (QSettings) with key-value pairs

**Mobile Implementation Recommendation:**
- Use `@react-native-async-storage/async-storage` for persistence
- Create TypeScript interfaces matching setting structures
- Implement settings context or extend Zustand store

---

## 5. Integration with Current Mobile Implementation

### 5.1 Current Hardcoded Values to Replace

**File:** `src/core/CommandLoop.ts`

#### In `setupSignalParameters()` method:
```typescript
// Line 46-48: Initialize position axes to 0
AXIS_POSITION_ALPHA: 0
AXIS_POSITION_BETA: 0

// Line 56-60: Carrier frequency (REPLACE WITH SETTING)
AXIS_CARRIER_FREQUENCY_HZ: 700  // Should use device_config_min_freq default

// Line 62-66: Pulse frequency (REPLACE WITH SETTING)
AXIS_PULSE_FREQUENCY_HZ: 50  // Should use pulse_frequency setting

// Line 68-72: Pulse width (REPLACE WITH SETTING)
AXIS_PULSE_WIDTH_IN_CYCLES: 5  // Should use pulse_width setting

// Line 74-78: Pulse rise time (REPLACE WITH SETTING)
AXIS_PULSE_RISE_TIME_CYCLES: 10  // Should use pulse_rise_time setting
```

#### In `tick()` method:
```typescript
// Line 120: Waveform amplitude (REPLACE WITH SETTING)
AXIS_WAVEFORM_AMPLITUDE_AMPS: 0.01  // Should use device_config_waveform_amplitude_amps (0.120)
```

### 5.2 Required Changes

1. **Create Settings Service:**
   - Define TypeScript interfaces for all settings
   - Implement AsyncStorage persistence layer
   - Provide default values matching desktop app
   - Export hooks for React components

2. **Extend Device Store:**
   - Add settings state to `deviceStore.ts`
   - Add actions for loading/saving settings
   - Initialize settings on app start

3. **Update CommandLoop:**
   - Inject settings dependency
   - Replace all hardcoded values with setting references
   - Validate settings before use

4. **Create Settings UI:**
   - Device Settings screen (min/max frequency, amplitude)
   - Preferences screen with tabs (FOC-Stim, Pulse, Network)
   - Form validation and error handling

---

## 6. Recommended Implementation Phases

### Phase 1: Core Device Settings (Priority 1)
**Scope:** Essential settings for safe device operation
- Min/Max carrier frequency (500/1500 Hz defaults)
- Waveform amplitude (120 mA default)
- Settings persistence (AsyncStorage)
- Update CommandLoop to use settings

**Deliverables:**
- Settings service with AsyncStorage
- Device Settings UI screen
- Integration with CommandLoop
- Settings validation

### Phase 2: Pulse Settings (Priority 2)
**Scope:** Pulse-based waveform configuration
- Pulse carrier frequency
- Pulse frequency, width, rise time
- Pulse interval randomization
- Duty cycle validation

**Deliverables:**
- Pulse Settings UI in Preferences
- Pulse settings integration in CommandLoop
- Duty cycle warning display

### Phase 3: FOC-Stim Preferences (Priority 3)
**Scope:** Device-specific preferences
- WiFi IP address (already implemented)
- SSID and password configuration
- Communication mode selection
- Debugging options (developer mode)

**Deliverables:**
- Enhanced Preferences screen
- WiFi configuration UI
- Optional debugging toggles

### Phase 4: Advanced Features (Future)
**Scope:** Lower priority features
- Volume settings
- Funscript conversion settings
- Serial/USB communication (Network tab)
- Pattern management

---

## 7. Settings Schema for Mobile App

### 7.1 TypeScript Interface Definitions

```typescript
// Device Configuration Settings
interface DeviceSettings {
  deviceType: DeviceType;
  waveformType: WaveformType;
  minFrequency: number;      // Hz, default: 500
  maxFrequency: number;      // Hz, default: 1500
  waveformAmplitude: number; // Amps, default: 0.120
}

// Pulse Settings
interface PulseSettings {
  carrierFrequency: number;  // Hz, default: 700
  pulseFrequency: number;    // Hz, default: 50
  pulseWidth: number;        // cycles, default: 5
  pulseRiseTime: number;     // cycles, default: 10
  pulseIntervalRandom: number; // %, default: 10
}

// FOC-Stim Connection Settings
interface FocStimSettings {
  communicationSerial: boolean;  // default: false (mobile)
  communicationWifi: boolean;    // default: true (mobile)
  wifiSsid: string;             // default: ''
  wifiPassword: string;         // default: ''
  wifiIp: string;               // default: ''
}

// Complete Settings
interface AppSettings {
  device: DeviceSettings;
  pulse: PulseSettings;
  focstim: FocStimSettings;
}
```

### 7.2 AsyncStorage Keys
```typescript
const STORAGE_KEYS = {
  DEVICE_SETTINGS: '@foccompanion/device_settings',
  PULSE_SETTINGS: '@foccompanion/pulse_settings',
  FOCSTIM_SETTINGS: '@foccompanion/focstim_settings',
};
```

---

## 8. Validation Rules

### 8.1 Device Settings Validation
```typescript
// Carrier frequency range
minFrequency >= 500 && minFrequency <= 2000
maxFrequency >= 500 && maxFrequency <= 2000
minFrequency < maxFrequency

// Waveform amplitude
waveformAmplitude >= 0.01 && waveformAmplitude <= 0.15
```

### 8.2 Pulse Settings Validation
```typescript
// Pulse frequency
pulseFrequency >= 1 && pulseFrequency <= 300

// Pulse width
pulseWidth >= 3 && pulseWidth <= 100

// Pulse rise time
pulseRiseTime >= 2 && pulseRiseTime <= 100

// Pulse interval random
pulseIntervalRandom >= 0 && pulseIntervalRandom <= 100

// Duty cycle warning
const dutyCycle = (pulseFrequency * pulseWidth) / carrierFrequency;
if (dutyCycle > 1) {
  // Show warning: "Duty cycle exceeds 100%"
}
```

---

## 9. UI/UX Considerations

### 9.1 Device Settings Screen
**Layout:**
- Section header: "Safety Limits"
- Min Frequency slider/input (500-2000 Hz)
- Max Frequency slider/input (500-2000 Hz)
- Waveform Amplitude slider/input (10-150 mA)
- Reset to defaults button

**Validation:**
- Real-time validation with error messages
- Disable save button if validation fails
- Show current values vs defaults

### 9.2 Preferences Screen (Tabs)
**Tab 1: FOC-Stim**
- WiFi IP address input
- SSID input (future)
- Password input (future)
- Communication mode toggle (future)

**Tab 2: Pulse Settings**
- Carrier frequency (readonly, from device settings)
- Pulse frequency slider
- Pulse width slider
- Pulse rise time slider
- Interval randomization slider
- Duty cycle display with warning indicator

**Tab 3: Network** (Empty placeholder)
- Message: "Serial/USB support coming soon"

### 9.3 Mobile-Specific Enhancements
- Use React Native slider components for numeric ranges
- Implement haptic feedback for slider adjustments
- Add "Advanced" toggle to hide complex settings
- Provide tooltips/help text for each setting
- Include safety warnings for amplitude settings

---

## 10. Testing Requirements

### 10.1 Settings Persistence
- [ ] Settings save correctly to AsyncStorage
- [ ] Settings load correctly on app start
- [ ] Default values applied on first launch
- [ ] Settings persist across app restarts

### 10.2 Validation
- [ ] Min/max frequency validation enforced
- [ ] Amplitude range validation enforced
- [ ] Pulse parameter validation enforced
- [ ] Duty cycle warning displayed correctly

### 10.3 Integration
- [ ] CommandLoop uses configured settings (not hardcoded values)
- [ ] Settings changes apply immediately or on next pattern start
- [ ] Device respects safety limits
- [ ] Real device testing with various setting combinations

### 10.4 Safety
- [ ] Cannot set dangerous frequency ranges
- [ ] Cannot exceed amplitude limits
- [ ] Duty cycle warnings prevent harmful configurations
- [ ] Settings reset to safe defaults on validation failure

---

## 11. References

**Desktop App Files Analyzed:**
- `qt_ui/preferences_dialog.py` - Main preferences dialog
- `qt_ui/carrier_settings_widget.py` - Carrier frequency UI
- `qt_ui/pulse_settings_widget.py` - Pulse settings UI
- `qt_ui/vibration_settings_widget.py` - Vibration settings (excluded)
- `qt_ui/three_phase_settings_widget.py` - Threephase calibration
- `qt_ui/tcode_command_router.py` - T-Code routing
- `qt_ui/settings.py` - All settings definitions
- `qt_ui/device_wizard/enums.py` - Device configuration enums
- `qt_ui/device_wizard/safety_limits_foc.py` - FOC safety limits
- `stim_math/limits.py` - Validation limits

**Current Mobile App Files:**
- `src/core/CommandLoop.ts` - Hardcoded signal parameters
- `src/store/deviceStore.ts` - Device state management
- `src/app/(tabs)/settings.tsx` - Settings UI (IP address only)
