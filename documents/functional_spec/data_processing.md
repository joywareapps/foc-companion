# Data Processing and Visualization

This document outlines how the Restim application handles and processes incoming data from the connected hardware devices.

## 1. FOC-Stim Data Processing

The FOC-Stim device provides rich, real-time telemetry back to the application via Protobuf `Notification` messages.

-   **Transport and Protocol**: Notifications are received over the active transport (Serial or TCP), framed using HDLC, and decoded by the `FOCStimProtoAPI`.
-   **Signal/Slot Mechanism**: The `FOCStimProtoAPI` class uses Qt's signal/slot mechanism to handle incoming notifications. It emits specific signals for each notification type (e.g., `on_notification_currents`).
-   **Primary Data Consumer**: In the current implementation (`device/focstim/proto_device.py`), the slots connected to these signals primarily forward the data to a `Teleplot` instance.
    - **Teleplot**: This is a local UDP-based plotting tool. The application sends metrics like RMS currents, peak currents, model estimations (resistance/reluctance), and system stats (temperatures, voltages) to a Teleplot server running on `127.0.0.1:47269`.
-   **Logging**: Debug messages (`NotificationDebugString`) from the device are logged directly to the application's log file.

**Key Insight for Mobile Migration**:
The live data streamed from the FOC-Stim is currently used for **debugging and advanced analysis** via Teleplot, not for driving the primary user interface visualizations. The main phase diagrams in the UI are rendered based on the application's internally generated position data (`alpha`, `beta`, `gamma`) *before* it is sent to the device.

For the mobile app, this means:
- A direct port of the Teleplot integration is likely out of scope for an initial version. It's a developer-centric feature.
- To create a more interactive experience, the mobile app *could* be designed to process and display this incoming telemetry (e.g., showing real-time power output or skin resistance). This would be a **new feature** compared to the desktop UI's core functionality.

## 2. NeoStim Data Processing

The NeoStim device has a more limited, request-response based communication model.

-   **Mechanism**: The `NeoStim` class processes incoming serial data in the `new_serial_data` method, which assembles frames. The `handle_incoming_datagram` method is called for complete data frames.
-   **Data Types**: It handles `ReportData` messages containing specific attributes (`FirmwareVersion`, `Voltages`, `IntensityPercent`, `BoxName`, etc.).
-   **Handling**: The data is primarily logged to the console/log file for informational purposes. There is no real-time data streaming for visualization in the same way as FOC-Stim.

## 3. Audio-Based Device Data Processing

Audio-based devices (e.g., Stereostim, MK-312) are **write-only**. The application sends a generated audio signal to the device, but there is no return data channel. All visualization is based on the state of the internal signal generation algorithms.
