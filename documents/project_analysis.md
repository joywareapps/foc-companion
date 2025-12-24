# Project Analysis: Restim Mobile

This document summarizes the analysis of the existing Restim desktop application and the FOC-Stim communication protocol, in preparation for creating a mobile version.

## 1. Restim Desktop Application Analysis

The Restim desktop application is a Python-based e-stim signal generator primarily built using PySide6 (Qt) for its graphical user interface. It focuses on real-time signal generation for multi-electrode setups and supports various hardware devices, including audio-based devices (Stereostim, Mk312, 2B), FOC-Stim, and NeoDK.

### 1.1. Key Technologies

*   **GUI:** PySide6 (Qt) for a modular and feature-rich user interface.
*   **Numerical Processing:** NumPy for core mathematical operations and signal processing.
*   **Audio I/O:** `sounddevice` and `soundfile` for handling audio-based e-stim.
*   **Device Communication:**
    *   Protocol Buffers (`protobuf`, `pystream-protobuf`) for structured communication, notably with FOC-Stim.
    *   `stm32loader` for interaction with STM32 microcontrollers.
    *   `crc` for data integrity.
*   **Networking:** `websockets` for potential synchronization or remote control.
*   **Visualization:** `matplotlib` for plotting/waveform displays.

### 1.2. Core Features

1.  **E-stim Signal Generation:**
    *   Real-time generation of various e-stim waveforms (e.g., sine, pulse).
    *   Support for amplitude modulation.
    *   Specialized logic for three-phase stimulation.
    *   Mathematical core handled by the `stim_math` module using `numpy`.

2.  **Hardware Device Support:**
    *   **Audio-based Devices:** Stereostim, Mk312, 2B (leveraging `sounddevice` and `soundfile`).
    *   **FOC-Stim:** Dedicated communication protocol using Protocol Buffers.
    *   **NeoDK:** Planned/upcoming support.
    *   Generic `output_device` interface for standardized interaction.
    *   Firmware loading/flashing capabilities (indicated by `stm32loader` and `focstim_flash_dialog`).

3.  **Funscript Integration:**
    *   Control of e-stim signals using "funscripts" (presumably a scripting format for e-stim patterns).
    *   Conversion and decomposition functionalities for funscripts.

4.  **Synchronization and Control:**
    *   Synchronization of e-stim with video or games (implied by `websockets` and `media_settings_widget`).
    *   Extensive UI controls for signal parameters, device settings, and user preferences.

5.  **Calibration:**
    *   Signal calibration for preferred electrode configurations.

6.  **User Interface (UI/UX):**
    *   Comprehensive `main_window` with numerous widgets and dialogs for settings, conversions, and device management.
    *   Guided device setup process (`device_wizard`).
    *   A/B testing features for waveforms (`ab_test_widget`).

7.  **Configuration and Settings:**
    *   Detailed preferences dialog (`preferences_dialog`).
    *   Specific settings for different device types (e.g., `three_phase_settings_widget`, `neostim_settings_widget`).

## 2. Proposed Mobile Application Requirements Outline

This outline serves as a starting point for defining what the mobile version should accomplish.

**1. Introduction**
    1.1. Purpose of the Mobile Application
    1.2. Scope of the Document
    1.3. Target Audience
    1.4. Definitions and Acronyms

**2. Overall Description**
    2.1. Product Perspective
        2.1.1. Relationship to Existing Desktop Application
        2.1.2. Mobile Platform Considerations (iOS/Android)
    2.2. Product Functions (High-Level Features)
    2.3. User Classes and Characteristics
    2.4. Operating Environment
    2.5. Design and Implementation Constraints
        2.5.1. Hardware Connectivity (Bluetooth LE, USB-OTG if applicable)
        2.5.2. Performance (real-time signal generation)
        2.5.3. Battery Life
        2.5.4. Security and Privacy
    2.6. User Documentation

**3. Specific Requirements**

    **3.1. Functional Requirements**

        **3.1.1. E-stim Signal Generation & Control**
            *   Real-time waveform generation (sine, pulse, three-phase, etc.)
            *   Amplitude and frequency modulation.
            *   Waveform parameter adjustments (e.g., duty cycle, phase shift).
            *   Preset management for common stimulation patterns.

        **3.1.2. Device Connectivity & Management**
            *   Support for audio-based e-stim devices (e.g., via audio jack output, Bluetooth audio).
            *   Support for FOC-Stim (Bluetooth LE or USB-OTG via Protocol Buffers).
            *   Support for NeoDK (Bluetooth LE or USB-OTG).
            *   Device discovery and pairing.
            *   Connection status display.
            *   Firmware update capability (if feasible on mobile).

        **3.1.3. Funscript Integration**
            *   Loading and playback of funscripts.
            *   Real-time control of e-stim signals based on funscript data.
            *   (Optional) Basic funscript editing/creation tools.

        **3.1.4. Synchronization**
            *   Synchronization with video playback on the mobile device.
            *   (Future/Optional) Synchronization with external media sources (e.g., web-based content via WebSocket).

        **3.1.5. Calibration**
            *   Guided process for electrode configuration calibration.
            *   Saving and loading calibration profiles.

        **3.1.6. User Interface & Experience (UX)**
            *   Intuitive and responsive mobile-first UI design.
            *   Clear visualization of current waveform and device status.
            *   Easy access to main controls and settings.
            *   Device setup wizard (simplified for mobile).

        **3.1.7. Settings & Preferences**
            *   Manage general application settings.
            *   Device-specific settings.
            *   User profiles (if applicable).

        **3.1.8. Data Management**
            *   Saving and loading user-created presets and funscripts.
            *   (Optional) Cloud sync for settings/funscripts.

    **3.2. Non-Functional Requirements**

        **3.2.1. Performance**
            *   Low latency for real-time signal generation and device control.
            *   Efficient use of CPU and memory.

        **3.2.2. Security**
            *   Secure communication with devices.
            *   Protection of user data.

        **3.2.3. Usability**
            *   Easy to learn and use.
            *   Clear feedback and error handling.
            *   Accessibility considerations.

        **3.2.4. Reliability**
            *   Stable operation with minimal crashes.
            *   Graceful handling of disconnections.

        **3.2.5. Maintainability**
            *   Modular and well-documented codebase.

        **3.2.6. Portability**
            *   Cross-platform compatibility (iOS and Android).

**4. User Interface Requirements**
    4.1. Screen Layouts/Wireframes (to be designed later)
    4.2. Navigation Flow

**5. System Architecture (High-Level)**
    5.1. Mobile Application Framework (e.g., React Native, Flutter, Kotlin Multiplatform)
    5.2. Communication Layer (Bluetooth LE, USB-OTG, Audio API)
    5.3. Core Logic Integration (signal generation, math library)
    5.4. Data Persistence

**6. Future Enhancements (Optional)**
    6.1. Advanced Funscript Editing
    6.2. Cloud Integration
    6.3. User Community Features

## 3. FOC-Stim Communication Protocol Analysis

The FOC-Stim device uses a Protocol Buffer-based RPC protocol for communication. The protocol is defined in `.proto` files within the `FOC-Stim` repository.

### 3.1. Message Structure

*   **`RpcMessage`**: The top-level message that can be a `Request`, `Response`, or `Notification`.
*   **`Request`**: Contains a `uint32 id` and a `oneof params` for various request types.
*   **`Response`**: Mirrors the `Request` with a `uint32 id` and a `oneof result`, plus an `Error` field.
*   **`Notification`**: A `oneof` field for various notification types, with a `timestamp`.
*   **`Error`**: Contains an `Errors code` (enum).

### 3.2. Key Requests/Responses

*   **Firmware & Capabilities:**
    *   `RequestFirmwareVersion` / `ResponseFirmwareVersion`
    *   `RequestCapabilitiesGet` / `ResponseCapabilitiesGet` (crucial for feature detection)
*   **Signal Control:**
    *   `RequestSignalStart` / `ResponseSignalStart` (with `OutputMode`)
    *   `RequestSignalStop` / `ResponseSignalStop`
*   **Real-time Control:**
    *   `RequestAxisMoveTo` / `ResponseAxisMoveTo` (for individual e-stim axes)
*   **Time Synchronization:**
    *   `RequestTimestampSet` / `ResponseTimestampSet`
    *   `RequestTimestampGet` / `ResponseTimestampGet`
*   **Network (Wi-Fi):**
    *   `RequestWifiParametersSet` / `ResponseWifiParametersSet`
    *   `RequestWifiIPGet` / `ResponseWifiIPGet`
*   **Debug:**
    *   `RequestDebugStm32DeepSleep` / `ResponseDebugStm32DeepSleep`
    *   `RequestDebugEnterBootloader`

### 3.3. Key Notifications

*   **`NotificationBoot`**: Device has booted.
*   **`NotificationCurrents`**: Real-time current and power measurements.
*   **`NotificationSystemStats`**: Temperature, voltage, and other system statistics.
*   **`NotificationBattery`**: Battery voltage, charge rate, state of charge, etc.
*   **`NotificationLSM6DSOX`**: IMU (accelerometer and gyroscope) data.
*   **`NotificationPotentiometer`**: Potentiometer value.
*   **Debug Notifications**: Various debug messages.
