import { createWorkletRuntime, runOnRuntime, runOnJS, type WorkletRuntime } from 'react-native-worklets';
import { CirclePattern } from './patterns';
import { focStimApi } from './FocStimApiService';
import { AxisType } from '../generated/protobuf/constants_pb';

export class CommandLoop {
  private pattern = new CirclePattern(0.5, 2.0); // Default amplitude and velocity
  private isRunning = false;
  private lastTimestamp = 0;
  private runtime: WorkletRuntime | null = null;

  public start() {
    if (this.isRunning) return;
    
    console.log('[CommandLoop] Starting...');
    
    if (!this.runtime) {
      console.log('[CommandLoop] Creating Worklet runtime...');
      this.runtime = createWorkletRuntime({ name: 'StimulationLoop' });
    }

    this.isRunning = true;
    this.lastTimestamp = Date.now();
    
    // Start the recursive loop on the background runtime
    this.scheduleNextTick();
  }

  public stop() {
    console.log('[CommandLoop] Stopping...');
    this.isRunning = false;
  }

  private scheduleNextTick() {
    if (!this.isRunning || !this.runtime) return;

    runOnRuntime(this.runtime, () => {
      'worklet';
      runOnJS(this.tick)();
    })();
  }

  private tick = () => {
    if (!this.isRunning) return;

    const now = Date.now();
    const dt = (now - this.lastTimestamp) / 1000;
    this.lastTimestamp = now;

    // Update pattern
    const pos = this.pattern.update(dt);

    // Send commands to device
    const interval = 50; 
    this.sendUpdate(AxisType.AXIS_POSITION_ALPHA, pos.x, interval);
    this.sendUpdate(AxisType.AXIS_POSITION_BETA, pos.y, interval);

    // Schedule next
    setTimeout(() => this.scheduleNextTick(), 16);
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
