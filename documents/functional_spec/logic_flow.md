# Logic Flow and Waveform Generation

This document outlines the main "command loops" responsible for generating and sending waveform data to the different supported devices. The application is event-driven, built on the Qt framework, and does not have a single, monolithic main loop. Instead, waveform generation is handled by different mechanisms depending on the device type.

## Core Concepts

- **AlgorithmFactory**: This class is responsible for creating the correct signal generation `algorithm` based on the user's device and waveform configuration.
- **Algorithms**: Subclasses of `AudioGenerationAlgorithm` (for audio devices) or `RemoteGenerationAlgorithm` (for FOC-Stim/NeoStim) contain the core logic. They pull data from various parameter sources (UI controls, funscripts, patterns) to generate the final output.
- **Axes (`AbstractAxis`)**: These objects represent time-varying parameters (e.g., alpha, beta, volume). They can be backed by user controls, funscript data, or programmatic patterns. The algorithms read from these axes to get parameter values at a given time.
- **MediaSync/TimestampMapper**: These are responsible for synchronizing the generated waveforms with external media (videos, games).

## 1. Audio-Based Device Command Loop

For devices like Stereostim, the command loop is a callback-driven audio stream.

1.  **Initialization**:
    - An `AudioStimDevice` instance is created in `mainwindow.py`.
    - An `AudioGenerationAlgorithm` (e.g., `DefaultThreePhasePulseBasedAlgorithm`) is created by the `AlgorithmFactory`.
    - A `sounddevice.OutputStream` is created, and its `callback` parameter is set to `AudioStimDevice.callback`.

2.  **The Loop (Audio Callback)**:
    - The `sounddevice` library calls `AudioStimDevice.callback` in a separate, high-priority thread whenever the audio buffer needs more samples.
    - Inside the callback, a `steady_clock` timeline is generated to ensure monotonic time, and this is synchronized with the system clock to create a `system_time_estimate`.
    - The callback invokes `self.algorithm.generate_audio(samplerate, steady_clock, system_time_estimate)`.

3.  **Waveform Generation (`generate_audio`)**:
    - **Parameter Gathering**: The algorithm gathers all necessary parameters (volume, frequencies, pulse settings, etc.) by calling `interpolate(system_time_estimate)` on its various axis objects.
    - **Position Calculation**: It gets the `alpha` and `beta` coordinates from its `ThreePhasePosition` helper object, which in turn gets them from the corresponding axes.
    - **Mathematical Transformation**: The core mathematical logic resides in `stim_math`. For example, `threephase.ThreePhaseSignalGenerator.generate()` is called with the carrier frequency (`theta_carrier`), alpha, and beta values.
    - **Calibration & Modulation**: Hardware calibration transforms and amplitude modulations (like vibration) are applied to the generated `L` and `R` channel data.
    - **Output**: The final `L` and `R` sample buffers are returned to the `AudioStimDevice.callback`, which places them in the `outdata` buffer for the soundcard.

This process ensures a continuous, real-time stream of audio data is generated and sent to the audio device without blocking the main UI thread.

## 2. FOC-Stim Device Command Loop

The FOC-Stim device uses a remote procedure call (RPC) model over a serial or TCP connection. The "loop" is a timer that periodically sends updates for any parameters that have changed.

1.  **Initialization**:
    - A `FOCStimProtoDevice` is created. It establishes a connection (serial or TCP).
    - An `FOCStimThreephaseAlgorithm` or `FOCStimFourphaseAlgorithm` is created.
    - A `QTimer` (`update_timer`) is created in `proto_device.py`. Its `timeout` signal is connected to `transmit_dirty_params`.

2.  **Starting the Loop**:
    - `signal_start()` is called, which sends a `RequestSignalStart` protobuf message to the device.
    - Upon successful response, the `update_timer` is started.

3.  **The Loop (`transmit_dirty_params`)**:
    - The timer fires at a regular interval (e.g., 60Hz).
    - It calls `self.algorithm.parameter_dict()` to get a dictionary of the current values for all controllable axes.
    - It compares this new dictionary with a cached `old_dict`.
    - For every parameter that has changed, it creates and sends a `RequestAxisMoveTo` protobuf message to the device.
    - The `old_dict` is updated with the new parameter values.

This approach minimizes communication overhead by only sending data for parameters that have actually changed, while still providing real-time control.

## 3. NeoStim Device Command Loop

The NeoStim device appears to use a similar model to the FOC-Stim, but with a different set of commands and a dedicated `NeoStimPTGenerator` algorithm.

1.  **Initialization**:
    - A `NeoStim` device object is created, which opens a serial port.
    - A `NeoStimAlgorithm` is created.
    - `device_connected_and_ready()` is called, which starts a `QTimer` (`params_update_timer`).

2.  **The Loop (`update_params`)**:
    - The `params_update_timer` fires periodically.
    - Inside `update_params`, it gathers all parameters from the UI and funscripts.
    - It uses a `PulsePlanner` (`device.neostim.threephase.ThreePhasePlanner`) to calculate the final power levels for each electrode configuration (`a_strength`, `b_strength`, etc.).
    - These values are packed into a `RestimPulseParameters` data structure.
    - The serialized `RestimPulseParameters` are sent to the device via `device.queue_restim_parameters()`.

## Isolation of Logic

- **Mathematical Logic**: The core waveform generation mathematics, coordinate transforms, and pulse shaping logic are well-isolated within the `stim_math` package. This code is pure Python and NumPy, making it highly portable.
- **Timing & Threading**: The "system logic" is handled by the respective device classes:
  - `AudioStimDevice`: Uses the `sounddevice` audio callback thread.
  - `FOCStimProtoDevice`: Uses a `QTimer` to drive updates in the main Qt event loop.
  - `NeoStim`: Uses a `QTimer` to drive updates.
- **State Management**: The state of UI controls and funscript-driven parameters is managed through `AbstractAxis` objects. These act as a clear interface between the UI/data sources and the signal generation algorithms.
- **Communication**: Device-specific communication (audio streaming, serial protobuf, etc.) is encapsulated in the `device` subpackages.

This separation is ideal for a mobile migration. The `stim_math` package can be reused with minimal changes, while the Qt-specific timing and I/O (`qt_ui` and `device` packages) will need to be replaced with React Native equivalents (e.g., native modules for serial/USB, and a JavaScript-based audio generation loop, possibly using worklets for performance).