# Task 06: Android Background Execution (Foreground Service)

## Priority
**MEDIUM** - Essential for usable mobile experience (app shouldn't stop when screen turns off)

## Overview
Implement an Android Foreground Service to allow FOC Companion to continue sending signals to the device even when the app is minimized or the screen is locked.

---

## Requirements

### Primary Goals
- **Keep connection alive** - Maintain TCP connection to FOC-Stim when app is in background.
- **Maintain 60Hz Loop** - Ensure the pattern generation loop continues without interruption.
- **Persistent Notification** - Show a notification while stimulation is active (Android requirement).
- **WakeLock / WiFi Lock** - Prevent the CPU and WiFi radio from entering low-power sleep modes.

### Secondary Goals
- **Dynamic Notification Content** - Update notification with current pattern and device status (e.g., battery).
- **Control from Notification** - Add a "Stop" button to the notification.
- **Battery Optimization Awareness** - Guide users to disable battery optimization for the app.

---

## Research: Recommended Library

### flutter_foreground_task
**Package:** https://pub.dev/packages/flutter_foreground_task

**Why this library?**
- Specifically designed for intense tasks like ours (as opposed to periodic sync).
- Excellent handling of Android 14+ requirements (Service Types).
- Built-in support for WakeLocks and WiFi locks.
- Provides a clean "TaskHandler" abstraction that runs in a dedicated Isolate.

---

## Part 1: Android Configuration

### 1.1 Permissions (AndroidManifest.xml)
Need to add the following to `foc-companion/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" /> <!-- Android 13+ -->
```

### 1.2 Service Declaration
Register the service inside the `<application>` tag:

```xml
<service 
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:foregroundServiceType="connectedDevice"
    android:exported="false" />
```

---

## Part 2: Implementation Plan

### Phase 1: Infrastructure
- [ ] Add `flutter_foreground_task` to `pubspec.yaml`.
- [ ] Create `lib/services/background_service.dart` to manage the service lifecycle.
- [ ] Implement a `TaskHandler` that initializes the `FocStimApiService` and `CommandLoop` in the background isolate.

### Phase 2: State Synchronization
Since the background service runs in a separate Isolate, state is not shared with the UI automatically.
- [ ] Use `FlutterForegroundTask.sendDataToMain` to send device status (temp, battery) to the UI.
- [ ] Use `FlutterForegroundTask.receiveDataFromMain` to handle commands from the UI (start/stop, change pattern).

### Phase 3: CommandLoop Refactoring
- [ ] Ensure `CommandLoop` and `FocStimApiService` are "thread-safe" for initialization inside a non-UI isolate.
- [ ] Implement logic to automatically stop the service when the pattern is stopped or the device is disconnected.

---

## Part 3: Notification Design

### Layout
- **Title:** FOC Companion Active
- **Content:** Running: [Pattern Name] | Device: [Battery]%
- **Actions:** [STOP] button to immediately terminate stimulation.

---

## Part 4: Safety & Battery

### 4.1 Battery Optimization
Android might still throttle the 60Hz loop if battery optimization is enabled.
- [ ] Add a check/dialog to ask the user to ignore battery optimizations for the app.
- [ ] Provide a link to the Android Settings page for the app.

### 4.2 Auto-Stop
- [ ] Implement a "Safety Timeout": If the app loses connection to the UI for too long, stop the stimulation.
- [ ] Ensure `stopSignal()` is called reliably when the service is destroyed.

---

## Acceptance Criteria
- [ ] App continues sending signals for >5 minutes when screen is off.
- [ ] A persistent notification is visible while signals are being sent.
- [ ] App does not crash when moving between foreground and background.
- [ ] Notification "Stop" button works.
- [ ] Status updates (temp/battery) still appear in the UI while in background.
