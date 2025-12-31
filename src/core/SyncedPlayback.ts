// Synced playback controller
// Integrates HereSphere video player with funscript haptic control
// Uses TCP socket connection to HereSphere player

import { focStimApi } from './FocStimApiService';
import { AxisType } from '../generated/protobuf/constants_pb';
import { hereSphereService } from '../services/HereSphereService';
import { FunscriptService } from '../services/FunscriptService';
import type { HereSphereStatus, ParsedFunscript, HereSphereConnectionState, FunscriptCollection } from '@/types/heresphere';
import type { FunscriptLocation } from '@/types/settings';
import { HereSphereConnectionState as ConnectionState } from '@/types/heresphere';
import { useDeviceStore } from '../store/deviceStore';

export class SyncedPlayback {
  private isRunning = false;
  private funscript: ParsedFunscript | null = null;
  private funscriptCollection: FunscriptCollection | null = null;
  private lastPosition: number = 0;
  private currentState: HereSphereConnectionState = ConnectionState.NOT_CONNECTED;
  private currentVideoIdentifier: string = '';
  private funscriptLocations: FunscriptLocation[] = [];
  private currentTimeMs: number = 0;
  private currentFunscriptPos: number = 0;
  private currentDevicePos: number = 0;

  /**
   * Start synced playback
   * @param hereSphereIp HereSphere player IP address
   * @param hereSpherePort HereSphere player port
   * @param funscriptLocations Array of funscript locations (WebDAV or local)
   */
  async start(hereSphereIp: string, hereSpherePort: number, funscriptLocations: FunscriptLocation[]) {
    if (this.isRunning) {
      console.warn('[SyncedPlayback] Already running');
      return;
    }

    console.log('[SyncedPlayback] Starting synced playback...');
    console.log(`[SyncedPlayback] Funscript locations: ${funscriptLocations.map(l => l.name).join(', ')}`);

    this.funscriptLocations = funscriptLocations;

    try {
      // Configure HereSphere connection
      hereSphereService.configure(hereSphereIp, hereSpherePort);

      // Initialize FOC-Stim signal parameters
      await this.setupSignalParameters();

      // Start signal output on device
      await focStimApi.startSignal();

      // Connect to HereSphere and start receiving status updates
      await hereSphereService.connect((status, state) => {
        this.onStatusUpdate(status, state);
      });

      this.isRunning = true;
      console.log('[SyncedPlayback] Synced playback started');
    } catch (error: any) {
      console.error('[SyncedPlayback] Failed to start:', error);
      await this.stop();
      throw error;
    }
  }

  /**
   * Stop synced playback
   */
  async stop() {
    if (!this.isRunning) return;

    console.log('[SyncedPlayback] Stopping synced playback...');

    try {
      // Disconnect from HereSphere
      hereSphereService.disconnect();

      // Ramp down amplitude
      await focStimApi.sendRequest({
        case: 'requestAxisMoveTo',
        value: { axis: AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, value: 0, interval: 500 } as any
      });

      // Wait for ramp down
      await new Promise(resolve => setTimeout(resolve, 600));

      // Stop signal
      await focStimApi.stopSignal();

      this.isRunning = false;
      this.lastPosition = 0;
      this.currentState = ConnectionState.NOT_CONNECTED;

      console.log('[SyncedPlayback] Synced playback stopped');
    } catch (error) {
      console.error('[SyncedPlayback] Error during stop:', error);
      this.isRunning = false;
    }
  }

  /**
   * Handle HereSphere status updates
   */
  private async onStatusUpdate(status: HereSphereStatus | null, state: HereSphereConnectionState) {
    if (!this.isRunning) return;

    this.currentState = state;

    // Detect video file changes and auto-load funscripts (using identifier field)
    if (status && status.identifier && status.identifier !== this.currentVideoIdentifier) {
      console.log(`[SyncedPlayback] New video detected: ${status.identifier}`);
      this.currentVideoIdentifier = status.identifier;
      await this.loadFunscriptsForVideo(status.identifier);
    }

    // Only update position if we have a funscript and are playing
    if (!this.funscript || state !== ConnectionState.CONNECTED_AND_PLAYING || !status) {
      return;
    }

    // Get current playback time in milliseconds
    this.currentTimeMs = status.currentTime * 1000;

    // Get funscript position at current time
    this.currentFunscriptPos = FunscriptService.getPositionAt(this.funscript, this.currentTimeMs);

    // Convert to device position (-1 to 1)
    this.currentDevicePos = FunscriptService.funscriptToDevicePosition(this.currentFunscriptPos);

    // Only update if position changed significantly (>1% change)
    if (Math.abs(this.currentDevicePos - this.lastPosition) > 0.01) {
      try {
        // Update device position
        // For linear motion, we'll use AXIS_POSITION_ALPHA as the primary axis
        await focStimApi.sendRequest({
          case: 'requestAxisMoveTo',
          value: {
            axis: AxisType.AXIS_POSITION_ALPHA,
            value: this.currentDevicePos,
            interval: 16 // ~60Hz update interval
          } as any
        });

        this.lastPosition = this.currentDevicePos;
        // console.log(`[SyncedPlayback] Position: ${this.currentTimeMs}ms -> ${this.currentFunscriptPos} -> ${this.currentDevicePos.toFixed(3)}`);
      } catch (error) {
        console.error('[SyncedPlayback] Failed to update position:', error);
      }
    }
  }

  /**
   * Load funscripts for the currently playing video
   */
  private async loadFunscriptsForVideo(videoIdentifier: string) {
    try {
      console.log(`[SyncedPlayback] Loading funscripts for: ${videoIdentifier}`);

      if (this.funscriptLocations.length === 0) {
        console.warn('[SyncedPlayback] No funscript locations configured');
        this.funscript = null;
        return;
      }

      const collection = await FunscriptService.collectForVideo(
        this.funscriptLocations,
        videoIdentifier
      );

      if (collection && collection.primaryFunscript) {
        this.funscriptCollection = collection;
        this.funscript = collection.primaryFunscript;
        console.log(`[SyncedPlayback] Loaded funscript: ${collection.funscripts.length} files, ${collection.primaryFunscript.actions.length} actions`);
      } else {
        console.warn(`[SyncedPlayback] No funscripts found for ${videoIdentifier}`);
        this.funscriptCollection = null;
        this.funscript = null;
      }
    } catch (error) {
      console.error('[SyncedPlayback] Failed to load funscripts:', error);
      this.funscript = null;
    }
  }

  /**
   * Setup FOC-Stim signal parameters
   */
  private async setupSignalParameters() {
    const { deviceSettings, pulseSettings } = useDeviceStore.getState();

    console.log('[SyncedPlayback] Setting up signal parameters...');

    // Initialize position axes to 0
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_POSITION_ALPHA, value: 0, interval: 0 } as any
    });

    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_POSITION_BETA, value: 0, interval: 0 } as any
    });

    // Set amplitude
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS, value: deviceSettings.waveformAmplitude, interval: 500 } as any
    });

    // Set carrier frequency
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_CARRIER_FREQUENCY_HZ, value: pulseSettings.carrierFrequency, interval: 0 } as any
    });

    // Set pulse frequency
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_PULSE_FREQUENCY_HZ, value: pulseSettings.pulseFrequency, interval: 0 } as any
    });

    // Set pulse width
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: { axis: AxisType.AXIS_PULSE_WIDTH_IN_CYCLES, value: pulseSettings.pulseWidth, interval: 0 } as any
    });

    console.log('[SyncedPlayback] Signal parameters configured');
  }

  /**
   * Check if playback is running
   */
  get running(): boolean {
    return this.isRunning;
  }

  /**
   * Check if ready to start (has configured locations)
   */
  get isConfigured(): boolean {
    return this.funscriptLocations.length > 0;
  }

  /**
   * Get currently loaded video identifier
   */
  get currentVideo(): string {
    return this.currentVideoIdentifier;
  }

  /**
   * Get playback status information
   */
  get status() {
    return {
      isRunning: this.isRunning,
      state: this.currentState,
      videoIdentifier: this.currentVideoIdentifier,
      funscriptCollection: this.funscriptCollection,
      currentTimeMs: this.currentTimeMs,
      currentFunscriptPos: this.currentFunscriptPos,
      currentDevicePos: this.currentDevicePos,
      hasFunscript: this.funscript !== null,
      actionCount: this.funscript?.actions.length || 0,
    };
  }
}

// Singleton instance
export const syncedPlayback = new SyncedPlayback();
