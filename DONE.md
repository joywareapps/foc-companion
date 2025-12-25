### 💡 Agent Execution Instructions
- **Step-by-Step:** Complete one checkbox at a time. Do not skip ahead.
- **Context Awareness:** Use the project index to find calls to `socket` or `serial`.
- **Error Handling:** - If a library is unknown: Search for its documentation or log it in `migration_issues.md`.
    - If the Python logic is too "Desktop-centric" (e.g., heavy threading/multiprocessing): Summarize the intent and flag it for "Native Module" discussion.
- **Output:** Every time a phase is completed, update `TODO.md` with [x] and provide a summary of the newly created documentation.


Since your app involves hardware communication (**Serial/TCP**) and **Protobuf**, the transition to React Native/Android requires careful planning for hardware permissions and background task management.

---

# 💡 Agent Task: Python to React Native Migration Analysis (COMPLETED)

## **📋 Phase 1: Structural & Logic Discovery**

* [x] **Identify Protobuf Definitions:** Locate all `.proto` files or Python-generated protobuf modules. Document the message structures used for device communication.
* [x] **Map the "Command Loop":** Analyze the main loop responsible for generating waveform commands.
* [x] **Analyze Communication Layers:**
    * [x] Document the **Serial (PySerial)** implementation.
    * [x] Document the **TCP (Socket)** implementation.
    * [x] Confirm if the protocol is identical across both transports.
* [x] **Extract Data Processing:** Identify how the app handles incoming signals/responses from the device for visualization or logging.

## **📋 Phase 2: Feature & Mobile Feasibility Audit**

* [x] **Feature Inventory:** Create a list of all current desktop features.
* [x] **Mobile Impact Analysis:** Flag features that are difficult on Android.
* [x] **State Management:** Document how the app tracks device state.

## **📋 Phase 3: Deliverables Generation**

* [x] **`documents/protocol_spec.md`**: Definition of Protobuf messages and flow.
* [x] **`documents/logic_flow.md`**: Waveform generation algorithm logic.
* [x] **`documents/mobile_migration_plan.md`**: Proposed React Native architecture.

---

# 💡 MVP Implementation (COMPLETED ✅ 2025-12-25)

## **Core Implementation**
* [x] **Project Initialization:** React Native 0.83.1 + React 19.2.3 + Expo SDK 54 + New Architecture.
* [x] **Protobuf Integration:** `buf` build process + TypeScript modules from FOC-Stim repository.
* [x] **Core Logic Porting:** `CirclePattern` ported to TypeScript with normalized coordinates.

## **Communication & Protocol**
* [x] **TCP Layer:** `react-native-tcp-socket` + HDLC framing - ✅ TESTED ON REAL DEVICE
* [x] **Protocol API:** `FocStimApiService` with full Protobuf RPC support:
  * [x] Request/response handling with timeout (5s)
  * [x] Notification decoding (system stats, battery, signal stats)
  * [x] Signal control (`startSignal()`, `stopSignal()`)
* [x] **Signal Parameter Initialization:**
  * [x] Carrier frequency (700 Hz)
  * [x] Pulse frequency (50 Hz)
  * [x] Pulse width (5 cycles)
  * [x] Pulse rise time (10 cycles)

## **Command Loop**
* [x] **Command Loop Implementation:**
  * [x] Removed `react-native-worklets` (incompatible with Expo SDK 54)
  * [x] Implemented with `setInterval` at 60Hz (~16ms)
  * [x] Threephase algorithm: position (ALPHA/BETA) + amplitude updates
  * [x] Conservative amplitude: 0.01 amps (safe default)
  * [x] ✅ **VERIFIED: Circle pattern plays correctly on real device**

## **State Management**
* [x] **Zustand Store:**
  * [x] Connection status tracking
  * [x] Device status monitoring (temperature, battery, pulse frequency)
  * [x] Real-time notification handling
  * [x] Error state management

## **User Interface**
* [x] **Settings Screen:** IP address configuration with persistence
* [x] **Main Control Screen:**
  * [x] Connection management (Connect/Disconnect)
  * [x] Connection status display
  * [x] Pattern control (Start/Stop Circle Pattern)
  * [x] Real-time device status display:
    * [x] Temperature monitoring
    * [x] Battery voltage and charge percentage
    * [x] Pulse frequency
    * [x] Power source indicator
  * [x] ScrollView layout for full accessibility
  * [x] Compact, optimized spacing

## **Testing & Validation**
* [x] **Real Device Testing (2025-12-25):**
  * [x] TCP connection to FOC-Stim V3 device
  * [x] Signal parameter initialization
  * [x] Circle pattern execution verified
  * [x] Device status notifications received and displayed
  * [x] Start/Stop signal control working correctly

---

# 💡 Device Settings Discovery & Documentation (COMPLETED ✅ 2025-12-25)

## **Phase 4.1: Desktop App Settings Analysis**

* [x] **Settings Structure Analysis:**
  * [x] Analyzed Device Selection settings (Setup → Device Selection)
  * [x] Analyzed Preferences dialog structure (Setup → Preferences)
  * [x] Analyzed 10 desktop source files for settings implementation

* [x] **Settings Identification:**
  * [x] Device Configuration settings (min/max carrier frequency, waveform amplitude)
  * [x] Pulse settings (carrier freq, pulse freq/width/rise time, interval random)
  * [x] FOC-Stim connection settings (WiFi IP, SSID, password)
  * [x] Identified 12 vibration settings to EXCLUDE (not applicable to FOC-Stim)

* [x] **Validation & Limits Documentation:**
  * [x] Documented ranges from `stim_math/limits.py`:
    * [x] Carrier Frequency: 500-2000 Hz (FOC-Stim)
    * [x] Waveform Amplitude: 0.01-0.15 A (10-150 mA)
    * [x] Pulse Frequency: 1-300 Hz
    * [x] Pulse Width: 3-100 cycles
    * [x] Pulse Rise Time: 2-100 cycles
  * [x] Duty cycle validation formula: `(pulseFreq * pulseWidth) / carrierFreq`

* [x] **Current Mobile Implementation Gaps:**
  * [x] Identified 6 hardcoded values in CommandLoop.ts requiring replacement:
    * [x] Line 59: Carrier frequency (700 Hz → user-configurable)
    * [x] Line 65: Pulse frequency (50 Hz → user-configurable)
    * [x] Line 71: Pulse width (5 cycles → user-configurable)
    * [x] Line 77: Pulse rise time (10 cycles → user-configurable)
    * [x] Line 120: Amplitude (0.01 A → 0.120 A default, user-configurable)
  * [x] Critical finding: Current amplitude 10 mA vs desktop default 120 mA (12x lower)

## **Deliverables Created**

* [x] **Comprehensive Settings Specification** (`documents/functional_spec/device-settings-spec.md`):
  * [x] 11 detailed sections covering all implementation aspects
  * [x] Complete settings inventory with defaults and valid ranges
  * [x] TypeScript interface definitions for all settings structures
  * [x] Validation rules with code examples
  * [x] UI/UX design recommendations
  * [x] Testing requirements and success criteria

* [x] **Analysis Summary** (`documents/functional_spec/device-settings-analysis-summary.md`):
  * [x] Executive summary of findings
  * [x] Settings breakdown by priority (Priority 1-3)
  * [x] Current mobile implementation gaps identified
  * [x] Risk assessment (high/medium/low)
  * [x] Implementation phases with clear next steps

* [x] **Task Breakdown** (TODO.md Phase 4):
  * [x] 8 subsections with detailed implementation tasks
  * [x] Priority levels assigned (Priority 1 = Critical)
  * [x] Clear separation: Infrastructure → UI → Integration → Testing

## **Desktop Files Analyzed**

* [x] `qt_ui/preferences_dialog.py` - Main preferences dialog with all tabs
* [x] `qt_ui/carrier_settings_widget.py` - Carrier frequency with safety limits
* [x] `qt_ui/pulse_settings_widget.py` - Pulse settings with duty cycle validation
* [x] `qt_ui/vibration_settings_widget.py` - Vibration settings (excluded)
* [x] `qt_ui/three_phase_settings_widget.py` - Threephase calibration
* [x] `qt_ui/tcode_command_router.py` - T-Code routing
* [x] `qt_ui/settings.py` - All settings definitions with defaults
* [x] `qt_ui/device_wizard/enums.py` - Device configuration enums
* [x] `qt_ui/device_wizard/safety_limits_foc.py` - FOC-Stim safety limits
* [x] `stim_math/limits.py` - Validation limits and ranges

## **Key Findings Summary**

**Settings to Implement (12 total):**
- Device Settings: min/max freq (500/1500 Hz), amplitude (120 mA)
- Pulse Settings: carrier freq, pulse freq, width, rise time, interval random
- FOC-Stim Settings: WiFi IP, SSID, password

**Settings Excluded (12 total):**
- All vibration settings (vibration_1_* and vibration_2_*) - not applicable to FOC-Stim

**Implementation Priority:**
1. Priority 1 (Critical): Settings infrastructure, Device Settings UI, CommandLoop integration
2. Priority 2: Pulse Settings UI, FOC-Stim Preferences
3. Priority 3: Advanced features (volume, funscript conversion)

---

## **Phase 4.6: CommandLoop Integration** ✅ COMPLETED (Dec 25, 2024)

### **Overview**
Replaced all hardcoded values in CommandLoop with user-configurable settings from deviceStore, enabling dynamic pattern configuration and fixing the amplitude issue (was 12x too low).

### **Changes Made**

**Modified: `src/core/CommandLoop.ts`**
- Added imports: `useDeviceStore`, `validateAppSettings`
- **Settings Validation**: Added pre-flight validation in `start()` method
  - Validates all settings before starting pattern
  - Throws error with detailed message if validation fails
  - Logs settings being used for debugging
- **Signal Parameter Setup** (`setupSignalParameters()`):
  - Replaced hardcoded 700 Hz → `pulseSettings.carrierFrequency` (default: 700 Hz)
  - Replaced hardcoded 50 Hz → `pulseSettings.pulseFrequency` (default: 50 Hz)
  - Replaced hardcoded 5 cycles → `pulseSettings.pulseWidth` (default: 5 cycles)
  - Replaced hardcoded 10 cycles → `pulseSettings.pulseRiseTime` (default: 10 cycles)
  - Added comprehensive logging of configured parameters
- **Amplitude Update** (`tick()` method):
  - **CRITICAL FIX**: Replaced hardcoded 0.01 A (10 mA) → `deviceSettings.waveformAmplitude` (default: 0.120 A / 120 mA)
  - This was the most critical change - previous amplitude was 12x too low
  - Amplitude now dynamically reads from settings on every tick
- **Settings Refresh**: Settings are read fresh from store on each `start()` call, allowing changes to take effect on next pattern start

### **Key Benefits**
1. **No More Hardcoded Values**: All signal parameters now configurable by user
2. **Amplitude Fix**: Device now uses correct default amplitude (120 mA instead of 10 mA)
3. **Dynamic Configuration**: Settings changes apply on next pattern start (no app restart needed)
4. **Safety Validation**: Pre-flight checks ensure settings are valid before starting
5. **Better Debugging**: Comprehensive logging of all signal parameters

### **Technical Details**
- Used `useDeviceStore.getState()` for non-React context (class-based)
- Settings validated using `validateAppSettings()` before pattern start
- Settings read in two places:
  - `start()`: For validation and setup parameters
  - `tick()`: For amplitude (allows future hot-reload of amplitude)
- Errors throw with detailed validation messages for user feedback

### **Testing Status**
- ✅ TypeScript compilation successful
- ⏳ Real device testing pending (user to test with actual FOC-Stim hardware)

### **Files Modified**
1. `src/core/CommandLoop.ts` - Complete integration of settings
2. `TODO.md` - Marked Phase 4.6 as completed
3. `DONE.md` - Added this completion entry