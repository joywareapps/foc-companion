// Device notification logger for tracking all device messages and debugging timeout issues
// Based on restim-desktop's notification logging implementation

import type { Notification } from '../generated/protobuf/focstim_rpc_pb';

/**
 * Logger for all device notifications and events
 * Helps track down timeout issues and device communication problems
 */
export class DeviceNotificationLogger {
  private notificationCount = 0;
  private bootNotificationCount = 0;
  private debugStringCount = 0;
  private logEnabled = true; // Enable by default for debugging

  /**
   * Enable or disable notification logging
   */
  setLoggingEnabled(enabled: boolean) {
    this.logEnabled = enabled;
    console.log(`[DeviceLogger] Logging ${enabled ? 'enabled' : 'disabled'}`);
  }

  /**
   * Log a received notification with timestamp and type
   */
  logNotification(notification: Notification) {
    if (!this.logEnabled) return;

    this.notificationCount++;
    const timestamp = new Date().toISOString();
    const notifType = notification.notification.case;

    // Log notification type and count
    console.log(`[DeviceLogger] [${timestamp}] Notification #${this.notificationCount}: ${notifType}`);

    // Handle specific notification types
    switch (notification.notification.case) {
      case 'notificationBoot':
        this.logBootNotification();
        break;

      case 'notificationDebugString':
        this.logDebugString(notification.notification.value.message);
        break;

      case 'notificationCurrents':
        this.logCurrents(notification.notification.value);
        break;

      case 'notificationSystemStats':
        this.logSystemStats(notification.notification.value);
        break;

      case 'notificationBattery':
        this.logBattery(notification.notification.value);
        break;

      case 'notificationSignalStats':
        this.logSignalStats(notification.notification.value);
        break;

      case 'notificationModelEstimation':
        this.logModelEstimation(notification.notification.value);
        break;

      case 'notificationPotentiometer':
        console.log(`[DeviceLogger]   Potentiometer value: ${notification.notification.value.value}`);
        break;

      case 'notificationLsm6dsox':
        this.logAccelerometer(notification.notification.value);
        break;

      case 'notificationDebugAs5311':
        console.log(`[DeviceLogger]   AS5311 - raw: ${notification.notification.value.raw}, tracked: ${notification.notification.value.tracked}`);
        break;

      case 'notificationDebugEdging':
        this.logDebugEdging(notification.notification.value);
        break;

      case undefined:
        console.warn(`[DeviceLogger] ⚠️ Received notification with undefined type`);
        break;

      default:
        console.log(`[DeviceLogger]   Unhandled notification type: ${notifType}`);
    }
  }

  /**
   * Log boot notification - indicates device has reset/rebooted
   * This is a critical error condition that requires investigation
   */
  private logBootNotification() {
    this.bootNotificationCount++;
    console.error(`[DeviceLogger] 🚨 BOOT NOTIFICATION RECEIVED (#${this.bootNotificationCount})`);
    console.error(`[DeviceLogger]    Device has rebooted unexpectedly!`);
    console.error(`[DeviceLogger]    This indicates a critical device error or reset`);
  }

  /**
   * Log debug string from device
   */
  private logDebugString(message: string) {
    this.debugStringCount++;
    console.warn(`[DeviceLogger] 💬 Debug String (#${this.debugStringCount}): ${message}`);
  }

  /**
   * Log current measurements
   */
  private logCurrents(currents: any) {
    console.log(`[DeviceLogger]   Currents - RMS: A=${currents.rmsA.toFixed(3)}A B=${currents.rmsB.toFixed(3)}A C=${currents.rmsC.toFixed(3)}A D=${currents.rmsD.toFixed(3)}A`);
    console.log(`[DeviceLogger]   Power: ${currents.outputPower.toFixed(2)}W (skin: ${currents.outputPowerSkin.toFixed(2)}W)`);
  }

  /**
   * Log system statistics
   */
  private logSystemStats(stats: any) {
    if (stats.system.case === 'esc1') {
      const s = stats.system.value;
      console.log(`[DeviceLogger]   System Stats (ESC1) - Temp: STM32=${s.tempStm32.toFixed(1)}°C Board=${s.tempBoard.toFixed(1)}°C`);
      console.log(`[DeviceLogger]   Voltages: Bus=${s.vBus.toFixed(2)}V Ref=${s.vRef.toFixed(2)}V`);
    } else if (stats.system.case === 'focstimv3') {
      const s = stats.system.value;
      console.log(`[DeviceLogger]   System Stats (FocStimV3) - Temp: STM32=${s.tempStm32.toFixed(1)}°C`);
      console.log(`[DeviceLogger]   Sys Voltage: ${s.vSysMin.toFixed(2)}V - ${s.vSysMax.toFixed(2)}V`);
      console.log(`[DeviceLogger]   Boost Voltage: ${s.vBoostMin.toFixed(2)}V - ${s.vBoostMax.toFixed(2)}V (duty: ${(s.boostDutyCycle * 100).toFixed(1)}%)`);
    }
  }

  /**
   * Log battery status
   */
  private logBattery(battery: any) {
    console.log(`[DeviceLogger]   Battery - Voltage: ${battery.batteryVoltage.toFixed(2)}V SOC: ${battery.batterySoc.toFixed(0)}%`);
    console.log(`[DeviceLogger]   Charge Rate: ${battery.batteryChargeRateWatt.toFixed(1)}W Wall Power: ${battery.wallPowerPresent ? 'Yes' : 'No'}`);
  }

  /**
   * Log signal statistics
   */
  private logSignalStats(stats: any) {
    console.log(`[DeviceLogger]   Signal Stats - Frequency: ${stats.actualPulseFrequency.toFixed(1)}Hz Drive: ${stats.vDrive.toFixed(2)}V`);
  }

  /**
   * Log model estimation
   */
  private logModelEstimation(model: any) {
    console.log(`[DeviceLogger]   Model Estimation - Resistance: A=${model.resistanceA.toFixed(1)}Ω B=${model.resistanceB.toFixed(1)}Ω C=${model.resistanceC.toFixed(1)}Ω D=${model.resistanceD.toFixed(1)}Ω`);
  }

  /**
   * Log accelerometer data
   */
  private logAccelerometer(accel: any) {
    console.log(`[DeviceLogger]   Accelerometer - Acc: (${accel.accX},${accel.accY},${accel.accZ}) Gyro: (${accel.gyrX},${accel.gyrY},${accel.gyrZ})`);
  }

  /**
   * Log debug edging notification
   */
  private logDebugEdging(edging: any) {
    console.log(`[DeviceLogger]   Debug Edging - Full Power: ${edging.fullPowerThreshold.toFixed(2)} Reduced: ${edging.reducedPowerThreshold.toFixed(2)} Reduction: ${edging.reduction.toFixed(2)}`);
  }

  /**
   * Log request timeout with pending request information
   * Based on proto_device.py generic_timeout() implementation
   */
  logTimeout(requestId: number, pendingRequestIds: number[]) {
    console.error(`[DeviceLogger] ⏱️ REQUEST TIMEOUT`);
    console.error(`[DeviceLogger]    Request ID: ${requestId}`);
    console.error(`[DeviceLogger]    Pending requests: [${pendingRequestIds.join(', ')}]`);
    console.error(`[DeviceLogger]    Total pending: ${pendingRequestIds.length}`);

    if (pendingRequestIds.length > 20) {
      console.error(`[DeviceLogger]    ⚠️ WARNING: More than 20 pending requests!`);
      console.error(`[DeviceLogger]    Device may be overwhelmed or communication is failing`);
    }
  }

  /**
   * Log connection error
   */
  logConnectionError(error: string) {
    console.error(`[DeviceLogger] 🔌 CONNECTION ERROR: ${error}`);
  }

  /**
   * Log disconnect event
   */
  logDisconnect() {
    console.warn(`[DeviceLogger] 🔌 Device disconnected`);
    console.log(`[DeviceLogger]    Session stats: ${this.notificationCount} notifications, ${this.bootNotificationCount} boot events, ${this.debugStringCount} debug strings`);
  }

  /**
   * Log session start
   */
  logSessionStart(host: string, port: number) {
    console.log(`[DeviceLogger] 🔌 Connecting to device at ${host}:${port}`);
    this.resetStats();
  }

  /**
   * Reset statistics for new session
   */
  private resetStats() {
    this.notificationCount = 0;
    this.bootNotificationCount = 0;
    this.debugStringCount = 0;
  }

  /**
   * Get current statistics
   */
  getStats() {
    return {
      totalNotifications: this.notificationCount,
      bootNotifications: this.bootNotificationCount,
      debugStrings: this.debugStringCount,
    };
  }
}

// Singleton instance
export const deviceLogger = new DeviceNotificationLogger();
