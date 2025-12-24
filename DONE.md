### 💡 Agent Execution Instructions
- **Step-by-Step:** Complete one checkbox at a time. Do not skip ahead.
- **Context Awareness:** Use the project index to find calls to `socket` or `serial`.
- **Error Handling:** - If a library is unknown: Search for its documentation or log it in `migration_issues.md`.
    - If the Python logic is too "Desktop-centric" (e.g., heavy threading/multiprocessing): Summarize the intent and flag it for "Native Module" discussion.
- **Output:** Every time a phase is completed, update `TODO.md` with [x] and provide a summary of the newly created documentation.


Since your app involves hardware communication (**Serial/TCP**) and **Protobuf**, the transition to React Native/Android requires careful planning for hardware permissions and background task management.

Here is an initial "Agent Mission Brief" in Markdown. You can feed this into a tool like Cursor, Windsurf, or a custom GPT to kickstart the analysis.

---

# 💡 Agent Task: Python to React Native Migration Analysis

## **Objective**

Analyze the provided Python source code to document the core logic, hardware communication protocols, and command generation loops. The goal is to prepare for a rewrite in **React Native (Android)** while deprioritizing desktop-specific features.

---

## **📋 Phase 1: Structural & Logic Discovery**

* [x] **Identify Protobuf Definitions:** Locate all `.proto` files or Python-generated protobuf modules. Document the message structures used for device communication.
* [x] **Map the "Command Loop":** Analyze the main loop responsible for generating waveform commands.
* *Goal:* Isolate the mathematical logic from the timing/threading logic.


* [x] **Analyze Communication Layers:**
* [x] Document the **Serial (PySerial)** implementation.
* [x] Document the **TCP (Socket)** implementation.
* [x] Confirm if the protocol is identical across both transports.


* [x] **Extract Data Processing:** Identify how the app handles incoming signals/responses from the device for visualization or logging.

## **📋 Phase 2: Feature & Mobile Feasibility Audit**

* [x] **Feature Inventory:** Create a list of all current desktop features.
* [x] **Mobile Impact Analysis:** Flag features that are difficult on Android (e.g., direct filesystem access, specific Serial-to-USB drivers).
* [x] **State Management:** Document how the app currently tracks device state (connected/disconnected, active waveforms, error states).

## **📋 Phase 3: Deliverables Generation**

* [x] **`docs/protocol_spec.md`**: A clean definition of the Protobuf messages and the handshake/heartbeat flow.
* [x] **`docs/logic_flow.md`**: A pseudocode representation of the waveform generation algorithm.
* [x] **`docs/mobile_migration_plan.md`**: A proposed architecture for React Native, including:
* [x] Recommended libraries for **USB Serial** and **TCP Sockets** in React Native.
* [x] A plan for the "Command Loop" (using Worklets or Native Modules to ensure timing accuracy).



