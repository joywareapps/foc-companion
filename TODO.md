# 💡 Agent Task: "FOC Companion" MVP Implementation

## **Objective**

Develop a Minimum Viable Product (MVP) for the "FOC Companion" Android application. The MVP will connect to a FOC-Stim device over TCP, generate commands for a predefined pattern, and send them to the device.

---

## **📋 Phase 1: Project Setup & Core Dependencies**

- [ ] **Project Initialization:**
    - [ ] Set up a new React Native project using the latest version, following the "New Architecture" guidelines.
    - [ ] Configure the project for Android development.
- [ ] **Protobuf Integration:**
    - [ ] Establish a build process to compile `.proto` files from the `FOC-Stim` repository into TypeScript modules.
    - [ ] Add the generated modules to the project.
- [ ] **Core Logic Porting:**
    - [ ] Port the necessary Python `stim_math` functions for waveform generation to a TypeScript module.
    - [ ] Port the "circle" pattern logic from the desktop application's `patterns` module.

## **📋 Phase 2: Communication & Command Loop**

- [ ] **TCP Communication Layer:**
    - [ ] Implement a TCP socket service using a library like `react-native-tcp-socket`.
    - [ ] Implement the HDLC framing/deframing logic in TypeScript to wrap/unwrap Protobuf messages.
- [ ] **Protocol API:**
    - [ ] Create a `FocStimApiService` that uses the TCP service and generated Protobuf modules to send commands and handle responses.
- [ ] **State Management:**
    - [ ] Integrate a state management library (e.g., Zustand) to manage application state, including connection status, device IP, and errors.
- [ ] **High-Frequency Command Loop:**
    - [ ] Set up `react-native-worklets-core`.
    - [ ] Implement the main command loop on a Worklet to run the "circle" pattern logic and send commands via the `FocStimApiService` at a consistent rate.

## **📋 Phase 3: User Interface**

- [ ] **Settings Screen:**
    - [ ] Create a simple UI screen for users to input and save the IP address of the FOC-Stim device.
- [ ] **Main Control Screen:**
    - [ ] Add a "Connect/Disconnect" button that uses the `FocStimApiService` and updates the application state.
    - [ ] Display the current connection status (e.g., "Disconnected", "Connecting...", "Connected").
    - [ ] Add a "Start/Stop Pattern" button to control the command loop.
    - [ ] (Optional) Display basic output metrics if available from the command loop or device responses.
