# Fix: Background Service Stability and Throttling

## Objective
Stabilize the background service by preventing IPC floods and reducing platform channel overhead, which is currently causing socket timeouts and Android notification rate limiting during high-frequency telemetry (sensor/impedance).

## Key Files & Context
- `lib/services/background_service.dart`: The core background task handler.
- `lib/core/command_loop.dart`: The 30Hz simulation loops.

## Implementation Steps

### 1. background_service.dart
- **Throttling Variable:** Add `_lastGlobalNotificationUpdateTime` to `FocStimTaskHandler` to track the last time the foreground service notification was updated.
- **ActiveBoxState:** Utilize `lastNotificationUpdateTime` to throttle IPC messages sent to the main UI isolate.
- **_handleNotification:**
    - Update `box.lastTelemetry` as before to keep state fresh.
    - Wrap `FlutterForegroundTask.sendDataToMain` in a check: only send if > 100ms has elapsed since the last send for this box (10Hz UI refresh).
    - Wrap `_updateNotificationDetails` in a check: only update if > 1000ms has elapsed since the last global update (1Hz notification refresh).
- **_disconnect:** Remove redundant stimulation stop calls or ensure they are non-blocking and safe if connection is already gone.

### 2. command_loop.dart
- **Safety Check:** In `stop()`, check `_api.isConnected` before calling `_api.stopSignal()` to avoid throwing "Not connected" exceptions when the loop is being cleaned up after a socket failure.

## Verification & Testing
- Reproduce the scenario: Connect device, enable sensor/impedance notifications.
- Verify Android logs no longer show "rate limit exceeded" for `NotificationManager`.
- Verify the connection remains stable during high-frequency data streams.
- Verify UI still feels responsive with 10Hz updates.
