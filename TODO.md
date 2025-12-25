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
    - [ ] **Test TCP connection on real device** (currently untested).
- [x] **Protocol API:**
    - [x] Create a `FocStimApiService` that uses the TCP service and generated Protobuf modules to send commands and handle responses.
- [x] **State Management:**
    - [x] Integrate a state management library (e.g., Zustand) to manage application state, including connection status, device IP, and errors.
- [x] **High-Frequency Command Loop:**
    - [x] Set up `react-native-worklets` (Note: using `react-native-worklets`, not `react-native-worklets-core` as per guidelines).
    - [x] Implement the main command loop on a Worklet to run the "circle" pattern logic and send commands via the `FocStimApiService` at a consistent rate.

## **📋 Phase 3: User Interface**

- [x] **Settings Screen:**
    - [x] Create a simple UI screen for users to input and save the IP address of the FOC-Stim device.
- [x] **Main Control Screen:**
    - [x] Add a "Connect/Disconnect" button that uses the `FocStimApiService` and updates the application state.
    - [x] Display the current connection status (e.g., "Disconnected", "Connecting...", "Connected").
    - [x] Add a "Start/Stop Pattern" button to control the command loop.
    - [ ] (Optional) Display basic output metrics if available from the command loop or device responses.

## **📋 Phase 4: Serial/USB Communication (Lower Priority)**

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
