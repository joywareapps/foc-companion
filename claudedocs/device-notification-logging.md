# Device Notification Logging Implementation

## Overview

Implemented comprehensive device notification logging to track down timeout errors that occur during synced media playback. Based on the restim-desktop Python implementation's logging patterns.

## Implementation Date

2026-01-01

## Problem

After playing synced media for a while, the FOC-Stim device errors and starts receiving timeouts. We need to log all notifications/messages from the device to track down the root cause.

## Solution

Created a new `DeviceNotificationLogger` service that logs all device notifications, timeouts, and connection events with detailed information.

## Files Created

### src/core/DeviceNotificationLogger.ts

New logging service that handles:
- All notification types (boot, debug, currents, system stats, battery, etc.)
- Timeout events with pending request information
- Connection errors and disconnects
- Session statistics

## Files Modified

### src/core/FocStimApiService.ts

**Changes:**
1. Imported `DeviceNotificationLogger`
2. Added session logging on connect
3. Added notification logging in `handleIncomingData()`
4. Added boot notification detection (indicates device reset - critical error)
5. Added timeout logging with pending request IDs
6. Added connection error logging
7. Added disconnect logging
8. Added public methods: `setNotificationLogging()` and `getNotificationStats()`

## Features

### 1. Notification Logging

All notifications from the device are logged with:
- Timestamp
- Notification type
- Notification count
- Type-specific data

**Logged Notification Types:**
- **Boot** (🚨 critical): Device has rebooted unexpectedly
- **Debug String** (💬 warning): Debug messages from device
- **Currents**: RMS and peak currents, output power
- **System Stats**: Temperature, voltages (ESC1 and FocStimV3)
- **Battery**: Voltage, SOC, charge rate, wall power status
- **Signal Stats**: Pulse frequency, drive voltage
- **Model Estimation**: Resistance and reluctance measurements
- **Potentiometer**: Dial value
- **Accelerometer**: Acceleration and gyro data
- **Debug AS5311**: Position sensor data
- **Debug Edging**: Edging algorithm parameters

### 2. Timeout Logging

When a request times out, logs:
- Request ID that timed out
- List of all pending request IDs
- Total pending request count
- Warning if >20 pending requests (indicates device overload)

Example output:
```
[DeviceLogger] ⏱️ REQUEST TIMEOUT
[DeviceLogger]    Request ID: 42
[DeviceLogger]    Pending requests: [39, 40, 41, 42, 43]
[DeviceLogger]    Total pending: 5
```

### 3. Boot Notification Detection

Boot notifications indicate the device has reset unexpectedly. This is logged as a critical error:

```
[DeviceLogger] 🚨 BOOT NOTIFICATION RECEIVED (#1)
[DeviceLogger]    Device has rebooted unexpectedly!
[DeviceLogger]    This indicates a critical device error or reset
[FocStimApi] 🚨 Boot notification received - device has reset!
```

The API also triggers the `onConnectionError` callback when a boot notification is received.

### 4. Session Statistics

Tracks per-session statistics:
- Total notification count
- Boot notification count (device resets)
- Debug string count

Statistics are logged on disconnect:
```
[DeviceLogger] 🔌 Device disconnected
[DeviceLogger]    Session stats: 1247 notifications, 0 boot events, 3 debug strings
```

### 5. Runtime Control

Logging can be enabled/disabled at runtime:

```typescript
import { focStimApi } from '@/core/FocStimApiService';

// Enable logging (enabled by default)
focStimApi.setNotificationLogging(true);

// Disable logging
focStimApi.setNotificationLogging(false);

// Get statistics
const stats = focStimApi.getNotificationStats();
console.log(`Total: ${stats.totalNotifications}, Boot: ${stats.bootNotifications}`);
```

## Usage

The logging is **enabled by default** and automatically logs all device communication.

### Viewing Logs

Logs are output to the console with the following prefixes:
- `[DeviceLogger]` - Notification logger
- `[FocStimApi]` - API service

### Log Levels

- `console.log()` - Normal notifications and info
- `console.warn()` - Debug strings, disconnects
- `console.error()` - Boot notifications, timeouts, connection errors

## Debugging Timeout Issues

When timeout errors occur:

1. **Check for boot notifications**: If you see boot notifications, the device is resetting
2. **Check pending request count**: >20 pending requests indicates device overload
3. **Review notification patterns**: Look for notification patterns before timeout
4. **Check system stats**: Temperature or voltage issues may cause problems

### Key Indicators

**Device Reset:**
```
🚨 BOOT NOTIFICATION RECEIVED
```
Indicates firmware crash or power issue.

**Request Overload:**
```
⚠️ WARNING: More than 20 pending requests!
Device may be overwhelmed or communication is failing
```
Indicates too many commands being sent too quickly.

**Communication Failure:**
```
⏱️ REQUEST TIMEOUT
Request ID: X
Pending requests: [...]
```
Indicates device not responding to commands.

## Reference Implementation

Based on restim-desktop's logging implementation:
- `source-repos/restim-desktop/device/focstim/proto_device.py` (lines 45-46, 166-175, 272-276, 331-333, 410-411)
- `source-repos/restim-desktop/device/focstim/proto_api.py` (lines 104-130)

## Next Steps

1. Monitor logs during synced media playback to identify timeout patterns
2. Look for specific notification sequences that precede timeouts
3. Check for boot notifications (device resets)
4. Verify pending request counts don't exceed 20
5. Consider adding file-based logging if console logging is insufficient

## Testing

Test scenarios:
- [x] Normal device connection and playback
- [ ] Extended synced media playback (watch for timeouts)
- [ ] Monitor boot notification occurrences
- [ ] Check pending request count during heavy usage
- [ ] Verify all notification types are logged correctly

## Notes

- Logging is enabled by default for debugging
- Can be disabled via `setNotificationLogging(false)` if performance is a concern
- Boot notifications trigger connection error callback (device reset)
- Statistics are reset on each new connection
- Timeout threshold is 5000ms (5 seconds) per request
