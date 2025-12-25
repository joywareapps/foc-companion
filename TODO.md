# 💡 Agent Task: "FOC Companion" MVP Implementation

## **Objective**

Develop a Minimum Viable Product (MVP) for the "FOC Companion" Android application. The MVP will connect to a FOC-Stim device over TCP, generate commands for a predefined pattern, and send them to the device.

---

## **📋 Phase 1: Project Setup & Core Dependencies**

- [x] **Project Initialization:**
    - [x] Set up a new React Native project using the latest version, following the "New Architecture" guidelines.
    - [x] Configure the project for Android development.
- [x] **Protobuf Integration:**
    - [x] Establish a build process to compile `.proto` files from the `FOC-Stim` repository into TypeScript modules.
    - [x] Add the generated modules to the project.
- [x] **Core Logic Porting:**
    - [x] Port the necessary Python `stim_math` functions for waveform generation to a TypeScript module.
    - [x] Port the "circle" pattern logic from the desktop application's `patterns` module.

## **📋 Phase 2: Communication & Command Loop**

- [x] **TCP Communication Layer:**
    - [x] Implement a TCP socket service using a library like `react-native-tcp-socket`.
    - [x] Implement the HDLC framing/deframing logic in TypeScript to wrap/unwrap Protobuf messages.
    - [x] **Test TCP connection on real device** - ✅ VERIFIED WORKING (2025-12-25)
- [x] **Protocol API:**
    - [x] Create a `FocStimApiService` that uses the TCP service and generated Protobuf modules to send commands and handle responses.
    - [x] Implement `startSignal()` and `stopSignal()` methods for signal control.
    - [x] Add notification handler for real-time device status updates.
- [x] **State Management:**
    - [x] Integrate a state management library (Zustand) to manage application state, including connection status, device IP, and errors.
    - [x] Add device status tracking (temperature, battery, pulse frequency).
- [x] **High-Frequency Command Loop:**
    - [x] Remove `react-native-worklets` dependency (incompatible with Expo SDK 54).
    - [x] Implement command loop using `setInterval` (60Hz @ ~16ms).
    - [x] Add signal parameter initialization (carrier frequency, pulse parameters).
    - [x] Implement threephase algorithm (position + amplitude updates).
    - [x] **Verify circle pattern execution on real device** - ✅ WORKING (2025-12-25)

## **📋 Phase 3: User Interface**

- [x] **Settings Screen:**
    - [x] Create a simple UI screen for users to input and save the IP address of the FOC-Stim device.
- [x] **Main Control Screen:**
    - [x] Add a "Connect/Disconnect" button that uses the `FocStimApiService` and updates the application state.
    - [x] Display the current connection status (e.g., "Disconnected", "Connecting...", "Connected").
    - [x] Add a "Start/Stop Pattern" button to control the command loop.
    - [x] Display device status metrics (temperature, battery voltage/charge, pulse frequency, power source).
    - [x] Optimize UI layout with ScrollView for compact display and full accessibility.

## **📋 Phase 4: Device Settings Implementation**

### **4.1 Discovery & Documentation** ✅ COMPLETED

- [x] **Desktop App Settings Analysis:**
    - [x] Analyze Device Selection settings structure (Setup → Device Selection)
    - [x] Analyze Preferences dialog structure (Setup → Preferences)
    - [x] Identify FOC-Stim specific settings (carrier frequency min/max, waveform amplitude)
    - [x] Identify Funscript/T-Code settings (pulse parameters, volume settings)
    - [x] Identify vibration-related settings to EXCLUDE
    - [x] Document valid ranges and default values from `stim_math/limits.py`
    - [x] Create comprehensive specification document: `documents/functional_spec/device-settings-spec.md`

### **4.2 Settings Infrastructure** (Priority 1)

- [ ] **Settings Service:**
    - [ ] Create TypeScript interfaces for settings structures:
        - [ ] `DeviceSettings` interface (device type, waveform type, min/max freq, amplitude)
        - [ ] `PulseSettings` interface (carrier freq, pulse freq, pulse width, rise time, interval random)
        - [ ] `FocStimSettings` interface (WiFi IP, SSID, password, communication mode)
        - [ ] `AppSettings` interface (combines all settings)
    - [ ] Implement AsyncStorage persistence layer:
        - [ ] `SettingsService.ts` with load/save methods
        - [ ] Storage keys: `@foccompanion/device_settings`, `@foccompanion/pulse_settings`, etc.
        - [ ] Default values matching desktop app (min_freq: 500Hz, max_freq: 1500Hz, amplitude: 0.120A)
    - [ ] Create settings validation utilities:
        - [ ] Min/max frequency validation (500-2000 Hz range, min < max)
        - [ ] Waveform amplitude validation (0.01-0.15 A range)
        - [ ] Pulse parameter validation (frequency: 1-300Hz, width: 3-100 cycles, rise: 2-100 cycles)
        - [ ] Duty cycle calculation and warning logic

- [ ] **State Management Integration:**
    - [ ] Extend `deviceStore.ts` with settings state:
        - [ ] Add `deviceSettings`, `pulseSettings`, `focstimSettings` state
        - [ ] Add `loadSettings()` action (load from AsyncStorage on app start)
        - [ ] Add `saveDeviceSettings()`, `savePulseSettings()` actions
        - [ ] Add `resetToDefaults()` action
    - [ ] Initialize settings on app start in store creation

### **4.3 Device Settings UI** (Priority 1)

- [ ] **Device Settings Screen:**
    - [ ] Create new screen: `src/app/(tabs)/device-settings.tsx`
    - [ ] Add tab bar icon and navigation
    - [ ] Implement UI sections:
        - [ ] **Safety Limits Section:**
            - [ ] Min Carrier Frequency slider (500-2000 Hz, default: 500 Hz, step: 10 Hz)
            - [ ] Max Carrier Frequency slider (500-2000 Hz, default: 1500 Hz, step: 10 Hz)
            - [ ] Validation: display error if min >= max
            - [ ] Waveform Amplitude slider (10-150 mA, default: 120 mA, step: 1 mA)
            - [ ] Display current values with units (Hz, mA)
        - [ ] **Device Type Section:**
            - [ ] Display current device type (FOC-Stim V3 / 3-Phase)
            - [ ] Waveform type selector (Continuous / Pulse-Based)
        - [ ] **Actions:**
            - [ ] "Reset to Defaults" button
            - [ ] "Save Settings" button
            - [ ] Real-time validation with error messages
    - [ ] Add ScrollView for accessibility
    - [ ] Implement haptic feedback for slider adjustments

### **4.4 Pulse Settings UI** (Priority 2)

- [ ] **Pulse Settings Tab in Preferences:**
    - [ ] Create `src/components/PulseSettingsPanel.tsx` component
    - [ ] Implement UI controls:
        - [ ] **Carrier Settings:**
            - [ ] Pulse Carrier Frequency (readonly display from device settings)
            - [ ] Carrier frequency range display (min-max from device settings)
        - [ ] **Pulse Parameters:**
            - [ ] Pulse Frequency slider (1-300 Hz, default: 50 Hz, step: 1 Hz)
            - [ ] Pulse Width slider (3-100 cycles, default: 5 cycles, step: 1)
            - [ ] Pulse Rise Time slider (2-100 cycles, default: 10 cycles, step: 1)
            - [ ] Pulse Interval Random slider (0-100%, default: 10%, step: 1%)
        - [ ] **Duty Cycle Display:**
            - [ ] Calculate duty cycle: `(pulseFreq * pulseWidth) / carrierFreq`
            - [ ] Display percentage with warning icon if > 100%
            - [ ] Show warning message: "Duty cycle exceeds 100% - reduce pulse width or frequency"
    - [ ] Add tooltips/help text for each parameter
    - [ ] Save button with validation

### **4.5 FOC-Stim Preferences UI** (Priority 2)

- [ ] **Enhance Existing Settings Screen:**
    - [ ] Refactor `src/app/(tabs)/settings.tsx` to organize settings
    - [ ] Add sections:
        - [ ] **WiFi Configuration:**
            - [ ] IP Address input (existing)
            - [ ] SSID input (future feature - placeholder)
            - [ ] Password input (future feature - placeholder)
            - [ ] Communication mode toggle: Serial/WiFi (WiFi default for mobile)
        - [ ] **Network Tab:**
            - [ ] Placeholder message: "Serial/USB support coming soon"
        - [ ] **Debugging (Developer Mode):**
            - [ ] Toggle for Teleplot visualization (optional)
            - [ ] Toggle for notification logging (optional)

### **4.6 CommandLoop Integration** ✅ COMPLETED

- [x] **Update CommandLoop to Use Settings:**
    - [x] Inject settings dependency into `CommandLoop` class (via `useDeviceStore.getState()`)
    - [x] Replace hardcoded values in `setupSignalParameters()`:
        - [x] Use `pulseSettings.carrierFrequency` instead of hardcoded 700 Hz
        - [x] Use `pulseSettings.pulseFrequency` instead of hardcoded 50 Hz
        - [x] Use `pulseSettings.pulseWidth` instead of hardcoded 5 cycles
        - [x] Use `pulseSettings.pulseRiseTime` instead of hardcoded 10 cycles
    - [x] Replace hardcoded amplitude in `tick()`:
        - [x] Use `deviceSettings.waveformAmplitude` instead of hardcoded 0.01 A (now defaults to 0.120 A / 120 mA)
    - [x] Add settings validation before starting pattern
    - [x] Handle settings changes (apply on next pattern start - settings are read fresh on each start())

- [ ] **Settings Hot Reload (Future Enhancement):**
    - [ ] Detect when settings change while pattern is running
    - [ ] Option 1: Warn user to restart pattern for changes to take effect
    - [ ] Option 2: Apply amplitude changes immediately, require restart for frequency changes

### **4.7 Testing & Validation** (Priority 1)

- [ ] **Unit Tests:**
    - [ ] Test SettingsService load/save operations
    - [ ] Test validation functions (frequency ranges, amplitude limits, duty cycle)
    - [ ] Test default value initialization
    - [ ] Test settings state management in deviceStore

- [ ] **Integration Tests:**
    - [ ] Test settings persistence across app restarts
    - [ ] Test CommandLoop uses configured settings (not hardcoded values)
    - [ ] Test settings validation in UI (error messages, disabled save button)
    - [ ] Test reset to defaults functionality

- [ ] **Real Device Testing:**
    - [ ] Test with various min/max frequency settings (500-1500Hz, 700-1200Hz, etc.)
    - [ ] Test with various amplitude settings (10mA, 50mA, 120mA)
    - [ ] Test with various pulse parameter combinations
    - [ ] Verify duty cycle warning appears correctly
    - [ ] Verify pattern behavior changes with different settings
    - [ ] Test safety: ensure device respects configured limits

### **4.8 Documentation Updates**

- [ ] **Update User Documentation:**
    - [ ] Add settings guide to README.md
    - [ ] Document default values and safe ranges
    - [ ] Add troubleshooting for settings issues

- [ ] **Update DONE.md:**
    - [ ] Document completed settings implementation
    - [ ] List all implemented settings and their defaults
    - [ ] Document testing results with real device

---

## **📋 Phase 5: Serial/USB Communication (Lower Priority)**

- [ ] **Serial Library Integration:**
    - [ ] Add `react-native-serial-transport` or `@fugood/react-native-usb-serialport` dependency.
    - [ ] Research library compatibility with Expo managed workflow and New Architecture.
- [ ] **USB Permissions Configuration:**
    - [ ] Add `android.permission.USB_PERMISSION` via Expo Config Plugin.
    - [ ] Add `android.hardware.usb.host` feature declaration.
    - [ ] Implement runtime permission handling for USB access.
- [ ] **Serial Transport Abstraction:**
    - [ ] Create `SerialTransport` class mirroring TCP interface.
    - [ ] Reuse existing HDLC framing/deframing logic.
    - [ ] Share Protobuf encoding/decoding with TCP implementation.
- [ ] **Unified API Service:**
    - [ ] Extend `FocStimApiService` to support both TCP and Serial transports.
    - [ ] Add transport selection in UI (TCP vs USB).
    - [ ] Implement device detection for USB-connected FOC-Stim devices.
- [ ] **Testing & Validation:**
    - [ ] Test Serial communication with real FOC-Stim device via USB.
    - [ ] Verify protocol compatibility across both transports.
    - [ ] Validate permission handling and error scenarios.
