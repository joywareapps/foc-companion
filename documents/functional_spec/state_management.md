# State Management in Restim

This document describes how the Restim desktop application manages its internal state, focusing on device connection, active waveforms, and error handling.

## 1. Device Connection State

The application's awareness of a connected device is primarily managed within the main `Window` class in `qt_ui/mainwindow.py`.

-   **Central Attribute**: The `self.output_device` attribute holds the instance of the currently active device object (e.g., `FOCStimProtoDevice`, `AudioStimDevice`) or is `None` if no device is active.
-   **State Check**: The connection status is checked by calling `self.output_device.is_connected_and_running()`.
-   **Lifecycle Management**:
    -   **Connection**: The `signal_start()` method is responsible for instantiating the appropriate device class and establishing a connection (e.g., opening a serial port or connecting a TCP socket). If successful, the instance is assigned to `self.output_device`.
    -   **Disconnection**: The `signal_stop()` method calls `self.output_device.stop()`, which closes the connection, and then sets `self.output_device` to `None`.
-   **UI Feedback**: The UI reflects the connection state primarily through the `IconWithConnectionStatus` class, which adds a status indicator (e.g., red/green dot) to the toolbar icons. Network error messages are logged, which may be the only feedback for a failed connection attempt.

## 2. Active Waveform State

The state of signal generation (i.e., whether the device is actively outputting a signal) is managed explicitly.

-   **State Enum**: A `PlayState` enum (`STOPPED`, `PLAYING`, `WAITING_ON_LOAD`) is defined in `mainwindow.py`. The current state is stored in the `self.playstate` attribute.
-   **State Transitions**:
    -   The `signal_start_stop()` method toggles the state between `PLAYING` and `STOPPED`.
    -   When funscripts are reloaded during playback, the state is temporarily changed to `WAITING_ON_LOAD` via `signal_stop(PlayState.WAITING_ON_LOAD)`. Once the new scripts are processed, `signal_start()` is called automatically.
-   **UI Feedback**: The main "Start/Stop" button's icon and text are updated by `refresh_play_button_icon()` to reflect the current `playstate`.

## 3. Error State Management

The application's error handling is somewhat decentralized and primarily relies on logging and stopping the output stream.

-   **Device-Level Errors**:
    -   **FOC-Stim**: The `FOCStimProtoDevice` class handles connection errors (`on_connection_error`) and request timeouts (`generic_timeout`). The response to these errors is to log the issue and call `stop()`, effectively disconnecting the device. Protobuf `Response` messages can contain an `Error` field, but the client-side logic mostly just logs this and stops.
    -   **Firmware-Level Errors (E-Stop)**: The C++ firmware for the FOC-Stim has an `estop_triggered` function. This function is passed as a callback to the `ThreephaseModel` and `FourphaseModel`. It is called for critical, unrecoverable errors like `OUTPUT_OVER_CURRENT` or `BOOST_OVER_VOLTAGE`. This indicates that the primary safety-critical error handling is implemented on the device itself. The desktop app is simply informed (or disconnected) when this happens.
-   **UI Feedback for Errors**:
    -   For most runtime errors (e.g., connection timeout, invalid funscript), the primary user feedback is a message logged to the console or log file.
    -   There is no persistent, centralized error state displayed in the main UI. The primary indicator of a problem is that the device stops working and the connection icon changes.
    -   Specific dialogs, like the **Firmware Updater**, have their own `QTextBrowser` to display progress and error messages specific to that task.

## Mobile Migration Considerations

-   **State Container**: For React Native, a more centralized state management solution is highly recommended. Libraries like **Redux Toolkit**, **Zustand**, or even React's built-in Context API should be used to create a global state store.
-   **State Shape**: The global state should contain slices for:
    -   `deviceConnection`: `{ status: 'DISCONNECTED' | 'CONNECTING' | 'CONNECTED', deviceName: string, error: string | null }`
    -   `playback`: `{ status: 'STOPPED' | 'PLAYING' | 'PAUSED' }`
    -   `error`: `{ message: string | null, isCritical: bool }`
-   **Error Handling**: A global error handling mechanism should be implemented. For example, a React Context could provide a function to dispatch error notifications, which could be displayed in a non-intrusive way (e.g., a toast or snackbar) or, for critical errors, a modal dialog. This would be an improvement over the desktop app's reliance on logs.
-   **Asynchronous Operations**: Redux Toolkit Query (RTK Query) or `react-query` could be used to manage the lifecycle of asynchronous operations like connecting to a device or sending a command, providing loading, success, and error states out of the box.