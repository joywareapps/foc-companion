import { CirclePattern } from './patterns';
import { focStimApi } from './FocStimApiService';
import { AxisType } from '../generated/protobuf/constants_pb';
import { useDeviceStore } from '../store/deviceStore';
import { validateAppSettings } from '../services/SettingsValidator';

export class CommandLoop {
  private pattern = new CirclePattern(1.0, 2.0); // Amplitude=1.0 (full range), velocity=2.0 rad/s
  private isRunning = false;
  private lastTimestamp = 0;
  private intervalId: ReturnType<typeof setInterval> | null = null;

  // Device coordinate system: normalized float values (typically -1.0 to +1.0 or 0.0 to 1.0)
  // Pattern outputs absolute positions in this range
  // Note: Desktop app uses accumulating deltas; we use absolute positions scaled to device range

  public async start() {
    if (this.isRunning) return;

    // Validate settings before starting
    const { deviceSettings, pulseSettings, focstimSettings } = useDeviceStore.getState();
    const validation = validateAppSettings({ device: deviceSettings, pulse: pulseSettings, focstim: focstimSettings });

    if (!validation.valid) {
      const errorMessage = `Invalid settings: ${validation.errors.join(', ')}`;
      console.error('[CommandLoop] Validation failed:', errorMessage);
      throw new Error(errorMessage);
    }

    console.log('[CommandLoop] Starting circle pattern with settings:', {
      amplitude: deviceSettings.waveformAmplitude,
      carrierFreq: pulseSettings.carrierFrequency,
      pulseFreq: pulseSettings.pulseFrequency
    });

    try {
      // Initialize signal parameters before starting
      console.log('[CommandLoop] Setting up signal parameters...');
      await this.setupSignalParameters();

      // Start signal output on device
      console.log('[CommandLoop] Starting signal output...');
      await focStimApi.startSignal();

      this.isRunning = true;
      this.lastTimestamp = Date.now();

      // Start the loop using setInterval (60Hz = ~16ms)
      this.intervalId = setInterval(() => this.tick(), 16);
      console.log('[CommandLoop] Pattern loop started');
    } catch (err) {
      console.error('[CommandLoop] Failed to start signal:', err);
      throw err;
    }
  }

  private async setupSignalParameters() {
    // Set up signal parameters as shown in protocol-example.txt (lines 26-86)
    // These must be configured before starting the signal

    // Get current settings from store
    const { deviceSettings, pulseSettings } = useDeviceStore.getState();

    // Initialize position axes to 0
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_POSITION_ALPHA, value: 0, interval: 0 } as any
    });

    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_POSITION_BETA, value: 0, interval: 0 } as any
    });

    // Set carrier frequency from pulse settings
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_CARRIER_FREQUENCY_HZ, value: pulseSettings.carrierFrequency, interval: 0 } as any
    });

    // Set pulse frequency from pulse settings
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_PULSE_FREQUENCY_HZ, value: pulseSettings.pulseFrequency, interval: 0 } as any
    });

    // Set pulse width from pulse settings
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, value: pulseSettings.pulseWidth, interval: 0 } as any
    });

    // Set pulse rise time from pulse settings
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_PULSE_RISE_TIME_CYCLES, value: pulseSettings.pulseRiseTime, interval: 0 } as any
    });

    // Set pulse interval randomization from pulse settings
    // Protocol uses 0.0-1.0 range, UI uses 0-100% range
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_PULSE_INTERVAL_RANDOM_PERCENT, value: pulseSettings.pulseIntervalRandom / 100, interval: 0 } as any
    });

    console.log('[CommandLoop] Signal parameters configured:', {
      carrierFrequency: pulseSettings.carrierFrequency,
      pulseFrequency: pulseSettings.pulseFrequency,
      pulseWidth: pulseSettings.pulseWidth,
      pulseRiseTime: pulseSettings.pulseRiseTime,
      pulseIntervalRandom: pulseSettings.pulseIntervalRandom / 100,
      amplitude: deviceSettings.waveformAmplitude
    });
  }

  public async stop() {
    console.log('[CommandLoop] Stopping...');
    this.isRunning = false;

    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }

    // Only attempt to stop signal if connected
    if (!focStimApi.connected) {
      console.log('[CommandLoop] Device not connected, skipping stop signal command');
      return;
    }

    try {
      // Stop signal output on device
      await focStimApi.stopSignal();
    } catch (err) {
      console.error('[CommandLoop] Failed to stop signal:', err);
      // Don't throw - we still want to clean up even if stop signal fails
    }
  }

  private tick = () => {
    if (!this.isRunning) return;

    const now = Date.now();
    const dt = (now - this.lastTimestamp) / 1000;
    this.lastTimestamp = now;

    // Update pattern
    const pos = this.pattern.update(dt);

    // Send commands to device (interval in ms for device to interpolate to this value)
    const interval = 50;

    // Get current amplitude from settings
    const { deviceSettings } = useDeviceStore.getState();

    // Send position updates (as per threephase_algorithm.py)
    this.sendUpdate(AxisType.AXIS_POSITION_ALPHA, pos.x, interval);
    this.sendUpdate(AxisType.AXIS_POSITION_BETA, pos.y, interval);

    // Send amplitude update (required for threephase mode)
    // Use amplitude from device settings (default: 0.120 amps / 120 mA)
    this.sendUpdate(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, deviceSettings.waveformAmplitude, interval);
  }

  private async sendUpdate(axis: AxisType, value: number, interval: number) {
    try {
      await focStimApi.sendRequest({
        case: 'requestAxisMoveTo',
        value: {
          axis,
          value,
          interval
        } as any
      });
    } catch (err) {
      // Silently catch loop errors
    }
  }
}

export const commandLoop = new CommandLoop();
