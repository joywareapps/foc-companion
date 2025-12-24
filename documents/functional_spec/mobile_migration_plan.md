# Mobile Migration Plan for Restim

This document proposes a high-level architecture and technology stack for migrating the Restim desktop application to a React Native application for Android, based on the analysis of the existing codebase and the development guidelines provided.

## 1. Core Architecture

A modular, feature-based architecture is recommended, adhering to the guidelines in `.agent-instructions/guidelines.md`.

-   **Framework**: React Native 0.83+ (using the New Architecture: JSI, TurboModules, Fabric).
-   **Infrastructure**: Expo SDK 53+ (Managed Workflow).
-   **Language**: TypeScript (`strict: true`).
-   **State Management**: A centralized state management library like **Zustand** or **Redux Toolkit** should be used to manage the application's global state, including device connection, playback status, and UI parameters.

## 2. Communication Layer

The communication with the hardware is the most critical part of the migration.

### 2.1. USB Serial Communication (FOC-Stim & NeoStim)

-   **Recommended Library**: `react-native-serial-transport` is recommended by the guidelines. An alternative like `@fugood/react-native-usb-serialport` should also be evaluated for maintenance status and compatibility.
-   **Implementation**:
    1.  A **Native Module** (Java/Kotlin) must be created to handle Android's `UsbManager` API.
    2.  This module will be responsible for:
        -   Requesting USB permissions from the user.
        -   Enumerating connected USB-to-Serial devices.
        -   Opening and closing a connection to the selected device.
        -   Passing raw data between the serial port and the JavaScript layer.
    3.  **JSI (JavaScript Interface)** should be used for high-performance, low-latency communication between the native module and the JavaScript thread, as recommended for real-time applications.
    4.  An `Expo Config Plugin` will be needed to add the required `android.permission.USB_PERMISSION` and `<uses-feature android:name="android.hardware.usb.host" />` to the `AndroidManifest.xml`.

### 2.2. TCP/IP and WebSocket Communication

-   **FOC-Stim (TCP)**: The `react-native-tcp-socket` library can be used to implement the TCP transport for the `FOCStimProtoAPI`.
-   **Media Sync & T-Code**: React Native's built-in `WebSocket` API and `fetch` API can be used to replicate the functionality of the existing media player and T-code integrations (MPC, VLC, Kodi, HereSphere, etc.).

## 3. Protocol Implementation

-   **Protobuf & HDLC**: The Protobuf definitions (`.proto` files) can be used to generate TypeScript classes using `ts-protoc-gen` or a similar tool. The HDLC framing logic from `device/focstim/hdlc.py` must be ported to TypeScript. A single `FOCStimProtoAPI` class can be created in TypeScript to handle the application-level protocol, capable of using either a Serial or TCP transport layer implementation.
-   **NeoStim Protocol**: The custom binary protocol for NeoStim, including its CRC algorithms, must be re-implemented in TypeScript.

## 4. The "Command Loop" and Waveform Generation

To ensure timing accuracy and avoid being throttled by the OS, the command loop and signal generation should not run on the main JavaScript UI thread.

-   **Recommended Approach**: **React Native Worklets (`react-native-worklets-core`)**.
    -   A worklet is a small piece of JavaScript code that can be run synchronously on a dedicated, high-priority thread.
    -   This is the ideal place to host the "command loop" for `FOCStimProtoDevice` and `NeoStim`, which periodically sends device updates.
-   **Implementation Plan**:
    1.  The core signal generation algorithms from `stim_math` should be ported to TypeScript.
    2.  An `AlgorithmManager` running on a worklet will be created.
    3.  This manager will contain a loop (driven by `setInterval` or a similar mechanism within the worklet).
    4.  On each iteration, it will:
        -   Read the latest values from the global state store (e.g., funscript-derived position, UI-controlled parameters).
        -   Call the active algorithm's `parameter_dict()` (for FOC-Stim) or `update_params()` (for NeoStim).
        -   Send the resulting commands to the device via the JSI bridge to the native serial/TCP module.

This approach isolates the real-time logic from the UI, preventing UI stutters and ensuring more reliable device communication, fulfilling the requirements of the "New Architecture" specified in the guidelines.

## 5. Deprioritized Features

Based on the mobile impact analysis, the following features should be **deprioritized or excluded** from the initial mobile version:

-   **Firmware Flashing**: High risk and complexity. The desktop app should remain the official tool for updates.
-   **File System-based Tools**: Funscript conversion, decomposition, and simfile conversion tools should be excluded initially. They rely on heavy file I/O that is not user-friendly on Android.
-   **Hosting Servers**: The TCP, UDP, and WebSocket *servers* should be deprioritized. The mobile app's primary role is as a client. Client functionality (like connecting to Buttplug) should be retained.
-   **Teleplot Integration**: This is a developer-focused debugging tool and is not essential for the core user experience.