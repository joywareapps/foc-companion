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

# 💡 MVP Implementation (COMPLETED)

* [x] **Project Initialization:** Latest React Native + Expo + New Architecture.
* [x] **Protobuf Integration:** `buf` build process + TypeScript modules.
* [x] **Core Logic Porting:** `stim_math` + `CirclePattern` ported to TypeScript.
* [x] **TCP Layer:** `react-native-tcp-socket` + HDLC framing (untested on real device).
* [x] **Protocol API:** `FocStimApiService` for Protobuf-based communication.
* [x] **State Management:** Zustand store for connection and pattern control.
* [x] **Command Loop:** `react-native-worklets` high-priority 60Hz loop.
* [x] **UI:** Main Control Screen with connection management and pattern control.