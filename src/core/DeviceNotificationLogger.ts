// Device notification logger for tracking all device messages and debugging timeout issues
// Based on restim-desktop's notification logging implementation

import type { Notification } from '../generated/protobuf/focstim_rpc_pb';

/**
 * Device error information
 */
export interface DeviceError {
  type: 'current_limit' | 'boot' | 'timeout' | 'unknown';
  message: string;
  details?: string;
  timestamp: Date;
}

/**
 * Logger for all device notifications and events
 * Helps track down timeout issues and device communication problems
 */
export class DeviceNotificationLogger {
  private notificationCount = 0;
  private bootNotificationCount = 0;
  private debugStringCount = 0;
  private logEnabled = true; // Enable by default for debugging

  // Error callback
  public onDeviceError: ((error: DeviceError) => void) | null = null;

  // Track recent current limit error to capture follow-up current values
  private lastCurrentLimitError: DeviceError | null = null;
  private lastCurrentLimitTimestamp: number = 0;

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

    // Trigger error callback
    if (this.onDeviceError) {
      this.onDeviceError({
        type: 'boot',
        message: 'Device rebooted unexpectedly',
        details: `Boot notification #${this.bootNotificationCount} received`,
        timestamp: new Date(),
      });
    }
  }

  /**
   * Log debug string from device
   * Detects error patterns and triggers error callback
   */
  private logDebugString(message: string) {
    this.debugStringCount++;
    console.warn(`[DeviceLogger] 💬 Debug String (#${this.debugStringCount}): ${message}`);

    // Detect error patterns
    const lowerMessage = message.toLowerCase();

    // Check if this is current values following a recent current limit error
    if (lowerMessage.includes('currents were:') && this.lastCurrentLimitError) {
      const timeSinceError = Date.now() - this.lastCurrentLimitTimestamp;

      // If within 2 seconds of the current limit error, parse and update
      if (timeSinceError < 2000) {
        console.log('[DeviceLogger] Capturing current values for current limit error');

        // Parse current values from message like "currents were: 0.003083 -0.001749 -0.297658"
        const currentsMatch = message.match(/currents were:\s*([\d\.\-\s]+)/i);
        if (currentsMatch) {
          const currentsStr = currentsMatch[1].trim();
          const currents = currentsStr.split(/\s+/).map(parseFloat);

          // Update the error details with formatted current values
          const enhancedDetails = `${this.lastCurrentLimitError.details}\n\nMeasured currents:\n` +
            `  Channel A: ${currents[0]?.toFixed(3) || 'N/A'} A\n` +
            `  Channel B: ${currents[1]?.toFixed(3) || 'N/A'} A\n` +
            `  Channel C: ${currents[2]?.toFixed(3) || 'N/A'} A\n` +
            (currents[3] !== undefined ? `  Channel D: ${currents[3].toFixed(3)} A` : '');

          // Trigger updated error callback
          if (this.onDeviceError) {
            this.onDeviceError({
              ...this.lastCurrentLimitError,
              details: enhancedDetails,
            });
          }
        }

        // Clear the tracked error
        this.lastCurrentLimitError = null;
        this.lastCurrentLimitTimestamp = 0;
        return; // Don't process as a new error
      }
    }

    // Current limit exceeded error
    if (lowerMessage.includes('current limit exceeded')) {
      console.error('[DeviceLogger] 🚨 CRITICAL ERROR: Current limit exceeded');

      const error: DeviceError = {
        type: 'current_limit',
        message: 'Current limit exceeded',
        details: message,
        timestamp: new Date(),
      };

      // Store for potential follow-up current values
      this.lastCurrentLimitError = error;
      this.lastCurrentLimitTimestamp = Date.now();

      if (this.onDeviceError) {
        this.onDeviceError(error);
      }
    }

    // Other potential error patterns
    if (lowerMessage.includes('error') || lowerMessage.includes('fault') || lowerMessage.includes('failed')) {
      console.error('[DeviceLogger] 🚨 Device error detected:', message);
      if (this.onDeviceError) {
        this.onDeviceError({
          type: 'unknown',
          message: 'Device error',
          details: message,
          timestamp: new Date(),
        });
      }
    }
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

    // Trigger error callback
    if (this.onDeviceError) {
      this.onDeviceError({
        type: 'timeout',
        message: 'Request timeout',
        details: `Request ${requestId} timed out. ${pendingRequestIds.length} pending requests.`,
        timestamp: new Date(),
      });
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
    this.lastCurrentLimitError = null;
    this.lastCurrentLimitTimestamp = 0;
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
