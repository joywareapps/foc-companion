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