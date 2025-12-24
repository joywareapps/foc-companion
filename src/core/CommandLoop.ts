import { createWorkletRuntime, runOnRuntime, runOnJS } from 'react-native-worklets';
import { CirclePattern } from './patterns';
import { focStimApi } from './FocStimApiService';
import { AxisType } from '../generated/protobuf/constants_pb';

export class CommandLoop {
  private pattern = new CirclePattern(0.5, 2.0); // Default amplitude and velocity
  private isRunning = false;
  private lastTimestamp = 0;
  
  // Create a worklet runtime for high-priority background execution
  private runtime = createWorkletRuntime({ name: 'StimulationLoop' });

  public start() {
    if (this.isRunning) return;
    this.isRunning = true;
    this.lastTimestamp = Date.now();
    
    // Start the recursive loop on the background runtime
    this.scheduleNextTick();
  }

  public stop() {
    this.isRunning = false;
  }

  private scheduleNextTick() {
    if (!this.isRunning) return;

    runOnRuntime(this.runtime, () => {
      'worklet';
      
      const now = Date.now();
      // Note: we need to handle state carefully in worklets. 
      // For now, keeping it simple.
      
      // In a real implementation, we'd pass pattern state or use shared values
      // For this MVP, we'll trigger the JS update but aim for future worklet-only logic
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
