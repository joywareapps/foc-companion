# Restim Desktop Application - Feature Inventory

This document provides a comprehensive inventory of the features available in the Restim desktop application. This list is compiled from an analysis of the user interface components (`.ui` files) and the main application logic.

## 1. Core Signal Generation & Control

-   **Live Control Mode**: Main interface for real-time control of stimulation parameters.
    -   **Phase Visualization**:
        -   Displays a 2D representation of the current stimulation pattern (three-phase and four-phase).
        -   Visual feedback for the current `alpha`, `beta`, `gamma` position.
    -   **Master Volume Control**: A main volume slider and spin-box to control the overall intensity.
    -   **Pattern Generator**:
        -   Select from a list of built-in procedural patterns (e.g., Mouse, Circle, Orbit, Spiral).
        -   Control the velocity/speed of the selected pattern.

## 2. Device & Waveform Configuration

-   **Device Selection Wizard**: A step-by-step guide to configure the output device.
    -   Select device type (Audio-based, FOC-Stim, NeoStim).
    -   Select waveform generation algorithm (Continuous, Pulse-based, A/B Testing).
    -   Set safety limits (min/max frequency, max amplitude for FOC-Stim).
-   **Device-Specific Settings Tabs**:
    -   **3-Phase Settings**: Calibration for Neutral, Right, and Center power (in dB). Visual calibration widget.
    -   **4-Phase Settings**: Calibration for A, B, C, D, and Center power (in dB).
    -   **Carrier Settings**: For continuous mode, allows setting the carrier frequency.
    -   **Pulse Settings**: For pulse-based mode, allows configuration of:
        -   Carrier Frequency
        -   Pulse Frequency
        -   Pulse Width (in carrier cycles)
        -   Pulse Interval Randomness
        -   Pulse Rise Time (in carrier cycles)
        -   Displays a real-time plot of the resulting pulse shape.
    -   **NeoStim Settings**:
        -   Power: Voltage, Duty Cycle.
        -   Feel: Carrier and Pulse frequency.
        -   Debug/Advanced: Inversion time, triac switch time, randomization defeat.
    -   **A/B Testing**: Allows for real-time comparison between two different sets of pulse parameters.

## 3. Media Synchronization

-   **Media Sync Mode**: A dedicated UI panel for synchronizing stimulation with external media.
-   **Media Player Integration**:
    -   Supports connecting to various media players over the network:
        -   MPC-HC (Media Player Classic - Home Cinema)
        -   HereSphere
        -   VLC
        -   Kodi
-   **Funscript Loading**:
    -   Automatically detects and loads funscripts that match the name of the currently playing media file.
    -   Provides an interface to manually add funscript files.
    -   Configurable additional search paths for funscripts.
-   **Funscript to Axis Mapping**:
    -   A table view allows mapping different funscript files (e.g., `video.alpha.funscript`, `video.beta.funscript`) to different stimulation axes (`POSITION_ALPHA`, `VOLUME_API`, `PULSE_FREQUENCY`, etc.).
    -   Allows setting limits (min/max) for how the 0-100% funscript values map to the target axis range.

## 4. Volume Control & Modulation

-   **Volume Ramp**: Gradually ramps the volume up or down to a target value at a configurable rate.
-   **Inactivity Volume Reduction**: Automatically lowers the volume when the funscript/pattern has been inactive (i.e., no position changes) for a certain threshold.
-   **Slow Start**: Gently ramps up the volume from zero when stimulation starts.
-   **Volume-Frequency Adjustment (FOC-Stim only)**: Automatically adjusts amplitude based on carrier frequency to maintain perceived intensity, based on a configurable nerve time constant (Tau).
-   **Vibration Effects**: Two independent LFOs (Low-Frequency Oscillators) that can modulate the volume to create vibration or texture effects. Each LFO has configurable:
    -   Frequency
    -   Strength (depth)
    -   Left/Right Bias
    -   High/Low Bias
    -   Randomness

## 5. Tools & Utilities

-   **Funscript Conversion**: A tool to convert a 1D funscript into two separate 2D funscripts (alpha and beta) using a procedural algorithm.
-   **Simfile Conversion**: A tool to convert StepMania `.sm` chart files into funscripts.
-   **Funscript Decomposition**: A tool to convert between different multi-axis representations (e.g., Alpha/Beta to E1/E2/E3).
-   **FOC-Stim Firmware Updater**: A dedicated dialog to flash new firmware onto a FOC-Stim V4 device over serial.
-   **Preferences Dialog**: A centralized dialog to configure all application settings.

## 6. Network & Connectivity

-   **Websocket Server**: For receiving T-Code commands.
-   **TCP/UDP Server**: For receiving T-Code commands.
-   **Serial Proxy**: For receiving T-Code commands from a serial port.
-   **Buttplug (WSDM) Client**: For receiving T-Code commands from a Buttplug server.
-   **FOC-Stim Connectivity**: Supports both Serial (QSerialPort) and TCP (QTcpSocket) connections.
-   **NeoStim Connectivity**: Supports Serial (QSerialPort) connection.

## 7. User Interface & Experience

-   **Tabbed Interface**: Main controls are organized into logical tabs.
-   **Live Waveform Details**: A "Details" tab shows the real-time calculated values for amplitudes and phases.
-   **Persistent Settings**: Application settings (window size, device configurations, network ports, etc.) are saved to a `restim.ini` file.
-   **About Dialog**: Displays application version and a link to the homepage.
-   **File Dialogs with History**: File open/save dialogs remember the last used directory.