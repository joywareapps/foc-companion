# FOC-Stim Communication Protocol Specification

This document defines the communication protocol between the Restim application and the FOC-Stim device. The protocol is based on Protocol Buffers (Protobuf) and defines a set of RPC-like messages for device control and data streaming.

## 1. Top-Level Message

The root message for all communication is `RpcMessage`. It acts as a container for `Request`, `Response`, or `Notification` messages.

### RpcMessage
| Field | Type | Description |
|---|---|---|
| `request` | [Request](#2-requests-and-responses) | A request from the client to the device. |
| `response` | [Response](#2-requests-and-responses) | A response from the device to the client. |
| `notification` | [Notification](#3-notifications) | An asynchronous message from the device to the client. |

---

## 2. Requests and Responses

Requests are sent from the client to the device, and the device replies with a `Response`. Each `Request` has a unique `id` which is mirrored in the corresponding `Response`.

### Request
| Field | Type | Description |
|---|---|---|
| `id` | `uint32` | Unique identifier for the request. |
| `params`| `oneof` | The specific request being made. See request types below. |

### Response
| Field | Type | Description |
|---|---|---|
| `id` | `uint32` | The `id` of the `Request` this response corresponds to. |
| `result` | `oneof` | The result of the request. See response types below. |
| `error` | `Error` | An error message if the request failed. |

### Error
| Field | Type | Description |
|---|---|---|
| `code` | [Errors](#4-enumerations) | The error code. |

---

## 3. RPC Functions

The following RPC functions are defined:

| Request | Response | Description |
|---|---|---|
| `RequestFirmwareVersion` | `ResponseFirmwareVersion` | Get the firmware version of the device. |
| `RequestCapabilitiesGet` | `ResponseCapabilitiesGet` | Get the capabilities of the device. |
| `RequestSignalStart` | `ResponseSignalStart` | Start signal generation. |
| `RequestSignalStop` | `ResponseSignalStop` | Stop signal generation. |
| `RequestAxisMoveTo` | `ResponseAxisMoveTo` | Move a single axis to a new value over a specified interval. |
| `RequestTimestampSet` | `ResponseTimestampSet` | Set the device's internal clock to a specific Unix timestamp. Used for synchronization. |
| `RequestTimestampGet` | `ResponseTimestampGet` | Get the device's current internal and synchronized timestamps. |
| `RequestWifiParametersSet`| `ResponseWifiParametersSet` | Set the Wi-Fi SSID and password. |
| `RequestWifiIPGet` | `ResponseWifiIPGet` | Get the device's Wi-Fi IP address. |
| `RequestDebugStm32DeepSleep`| `ResponseDebugStm32DeepSleep` | (Debug) Put the STM32 into a deep sleep state. |
| `RequestDebugEnterBootloader`| (none) | (Debug) Cause the device to enter its bootloader. |

### Message Details

#### General Commands
*   **RequestFirmwareVersion**: Empty message.
*   **ResponseFirmwareVersion**:
    *   `board`: [BoardIdentifier](#4-enumerations)
    *   `stm32_firmware_version`: `string`

*   **RequestCapabilitiesGet**: Empty message.
*   **ResponseCapabilitiesGet**:
    *   `threephase`: `bool`
    *   `fourphase`: `bool`
    *   `battery`: `bool`
    *   `potentiometer`: `bool`
    *   `maximum_waveform_amplitude_amps`: `float`

*   **RequestSignalStart**:
    *   `mode`: [OutputMode](#4-enumerations)

*   **RequestSignalStop**: Empty message.

#### MoveTo Streaming API
*   **RequestAxisMoveTo**:
    *   `axis`: [AxisType](#4-enumerations)
    *   `value`: `float`
    *   `interval`: `uint32` (in ms)

#### Time Synchronization
*   **RequestTimestampSet**:
    *   `timestamp_ms`: `uint64` (Unix timestamp in ms)
*   **ResponseTimestampSet**:
    *   `offset_ms`: `int64` (New offset between epoch and local clock)
    *   `change_ms`: `sint64` (How much the offset changed)
    *   `error_ms`: `sint64` (The error between clocks)

*   **RequestTimestampGet**: Empty message.
*   **ResponseTimestampGet**:
    *   `timestamp_ms`: `fixed32` (Device's local clock)
    *   `unix_timestamp_ms`: `uint64` (Synchronized clock)

#### Network
*   **RequestWifiParametersSet**:
    * `ssid`: `bytes`
    * `password`: `bytes`
* **ResponseWifiIPGet**:
    * `ip`: `uint32`

---

## 3. Notifications

Notifications are sent asynchronously from the device to the client.

### Notification
| Field | Type | Description |
|---|---|---|
| `notification` | `oneof` | The specific notification. See notification types below. |
| `timestamp` | `uint64` | Device timestamp of the notification. |

### Notification Types
*   **NotificationBoot**: Sent when the device boots up.
*   **NotificationPotentiometer**: Reports the current value of the potentiometer.
    *   `value`: `float`
*   **NotificationCurrents**: Reports real-time current and power measurements.
    *   `rms_a`, `rms_b`, `rms_c`, `rms_d`: `float` (RMS body current in Amps)
    *   `peak_a`, `peak_b`, `peak_c`, `peak_d`: `float` (Peak body current in Amps)
    *   `output_power`: `float` (Output stage power in Watts)
    *   `output_power_skin`: `float` (Power delivered to the skin in Watts)
    *   `peak_cmd`: `float`
*   **NotificationModelEstimation**: Reports the estimated electrical properties of the load.
    *   `resistance_a`...`d`: `float`
    *   `reluctance_a`...`d`: `float`
    *   `constant`: `float`
*   **NotificationSystemStats**: Reports system statistics like temperature and voltage.
    * `esc1`: `SystemStatsESC1`
    * `focstimv3`: `SystemStatsFocstimV3`
*   **NotificationSignalStats**: Reports statistics about the generated signal.
    * `actual_pulse_frequency`: `float`
    * `v_drive`: `float`
*   **NotificationBattery**: Reports battery status.
    *   `battery_voltage`: `float`
    *   `battery_charge_rate_watt`: `float`
    *   `battery_soc`: `float` (State of Charge)
    *   `wall_power_present`: `bool`
    *   `chip_temperature`: `float`
*   **NotificationLSM6DSOX**: Reports IMU (accelerometer and gyroscope) data.
    * `acc_x`, `acc_y`, `acc_z`: `int32` (mG)
    * `gyr_x`, `gyr_y`, `gyr_z`: `int32` (mDPS)
*   **NotificationDebugString**: A debug string from the device.
    * `message`: `string`

---

## 4. Enumerations

### AxisType
Defines the different axes that can be controlled.
| Name | Value | Description |
|---|---|---|
| `AXIS_UNKNOWN` | 0 | |
| `AXIS_POSITION_ALPHA` | 1 | Position parameter |
| `AXIS_POSITION_BETA` | 2 | Position parameter |
| `AXIS_POSITION_GAMMA` | 3 | Position parameter |
| `AXIS_WAVEFORM_AMPLITUDE_AMPS`| 11 | |
| `AXIS_CARRIER_FREQUENCY_HZ` | 20 | General pulse parameter |
| `AXIS_PULSE_WIDTH_IN_CYCLES` | 21 | General pulse parameter |
| `AXIS_PULSE_RISE_TIME_CYCLES` | 22 | General pulse parameter |
| `AXIS_PULSE_FREQUENCY_HZ` | 23 | General pulse parameter |
| `AXIS_PULSE_INTERVAL_RANDOM_PERCENT`| 24 | General pulse parameter |
| `AXIS_CALIBRATION_3_CENTER` | 30 | |
| `AXIS_CALIBRATION_3_UP` | 31 | |
| `AXIS_CALIBRATION_3_LEFT` | 32 | |
| `AXIS_CALIBRATION_4_CENTER` | 40 | |
| `AXIS_CALIBRATION_4_A` | 41 | |
| `AXIS_CALIBRATION_4_B` | 42 | |
| `AXIS_CALIBRATION_4_C` | 43 | |
| `AXIS_CALIBRATION_4_D` | 44 | |

### BoardIdentifier
| Name | Value | Description |
|---|---|---|
| `BOARD_UNKNOWN` | 0 | |
| `BOARD_B_G431B_ESC1` | 1 | AKA 'V1' or 'V2' |
| `BOARD_FOCSTIM_V4` | 2 | also V3 |

### OutputMode
| Name | Value |
|---|---|
| `OUTPUT_UNKNOWN` | 0 |
| `OUTPUT_THREEPHASE`| 2 |
| `OUTPUT_FOURPHASE` | 3 |

### StreamingMode
| Name | Value |
|---|---|
| `STREAMING_UNKNOWN`| 0 |
| `STREAMING_MOVETO` | 1 |
| `STREAMING_BUFFERED`| 2 |

### Errors
| Name | Value |
|---|---|
| `ERROR_UNKNOWN` | 0 |
| `ERROR_OUTPUT_NOT_SUPPORTED` | 1 |
| `ERROR_UNKNOWN_REQUEST` | 2 |
| `ERROR_POWER_NOT_PRESENT` | 3 |
| `ERROR_ALREADY_PLAYING` | 4 |