import { CirclePattern } from './patterns';
import { focStimApi } from './FocStimApiService';
import { AxisType } from '../generated/protobuf/constants_pb';

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

    console.log('[CommandLoop] Starting circle pattern with amplitude=1.0, velocity=2.0rad/s');

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

    // Initialize position axes to 0
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_POSITION_ALPHA, value: 0, interval: 0 } as any
    });

    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_POSITION_BETA, value: 0, interval: 0 } as any
    });

    // Set carrier frequency (700 Hz is default in desktop app)
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_CARRIER_FREQUENCY_HZ, value: 700, interval: 0 } as any
    });

    // Set pulse frequency (50 Hz)
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_PULSE_FREQUENCY_HZ, value: 50, interval: 0 } as any
    });

    // Set pulse width (5 cycles)
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, value: 5, interval: 0 } as any
    });

    // Set pulse rise time (10 cycles)
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_PULSE_RISE_TIME_CYCLES, value: 10, interval: 0 } as any
    });

    console.log('[CommandLoop] Signal parameters configured');
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

    // Send position updates (as per threephase_algorithm.py)
    this.sendUpdate(AxisType.AXIS_POSITION_ALPHA, pos.x, interval);
    this.sendUpdate(AxisType.AXIS_POSITION_BETA, pos.y, interval);

    // Send amplitude update (required for threephase mode)
    // Default amplitude: 0.01 amps (conservative safe value)
    this.sendUpdate(AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, 0.01, interval);
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
