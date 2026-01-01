import { create } from 'zustand';
import { Alert } from 'react-native';
import { focStimApi } from '@/core/FocStimApiService';
import { commandLoop } from '@/core/CommandLoop';
import { syncedPlayback } from '@/core/SyncedPlayback';
import type { Notification } from '@/generated/protobuf/focstim_rpc_pb';
import type { DeviceError } from '@/core/DeviceNotificationLogger';
import { SettingsService } from '@/services/SettingsService';
import type { DeviceSettings, PulseSettings, FocStimSettings, MediaSyncSettings } from '@/types/settings';
import { DefaultSettings } from '@/types/settings';

export type ConnectionStatus = 'DISCONNECTED' | 'CONNECTING' | 'CONNECTED' | 'ERROR';
export type PlaybackSource = 'pattern' | 'mediaSync' | null;

export interface DeviceStatus {
  temperature?: number;
  batteryVoltage?: number;
  batterySoc?: number;
  wallPowerPresent?: boolean;
  pulseFrequency?: number;
  vDrive?: number;
  lastUpdate?: number;
}

interface DeviceState {
  // Connection state
  status: ConnectionStatus;
  ipAddress: string;
  error: string | null;
  loopRunning: boolean;
  deviceStatus: DeviceStatus;

  // Centralized playback state
  isPlaybackActive: boolean;
  playbackSource: PlaybackSource;

  // Pattern control
  patternSpeed: number; // rad/s, default 2.0

  // Settings state
  deviceSettings: DeviceSettings;
  pulseSettings: PulseSettings;
  focstimSettings: FocStimSettings;
  mediaSyncSettings: MediaSyncSettings;
  settingsLoaded: boolean;

  // Connection actions
  setIpAddress: (ip: string) => void;
  connect: () => Promise<void>;
  disconnect: () => Promise<void>;
  toggleLoop: () => Promise<void>;

  // Playback state actions
  setPlaybackActive: (source: PlaybackSource) => void;
  clearPlaybackActive: () => void;
  canStartPlayback: (requestedSource: PlaybackSource) => boolean;

  // Pattern actions
  setPatternSpeed: (speed: number) => void;

  // Settings actions
  loadSettings: () => Promise<void>;
  saveDeviceSettings: (settings: DeviceSettings) => Promise<void>;
  savePulseSettings: (settings: PulseSettings) => Promise<void>;
  saveFocStimSettings: (settings: FocStimSettings) => Promise<void>;
  saveMediaSyncSettings: (settings: MediaSyncSettings) => Promise<void>;
  resetToDefaults: () => Promise<void>;
}

export const useDeviceStore = create<DeviceState>((set, get) => {
  // Setup API listeners
  focStimApi.onConnectionError = async (error) => {
    console.error('[DeviceStore] Connection error, clearing playback state:', error);
    set({ status: 'ERROR', error });
    await commandLoop.stop();
    set({ loopRunning: false, isPlaybackActive: false, playbackSource: null });
  };

  focStimApi.onDisconnect = async () => {
    console.log('[DeviceStore] Disconnected, clearing playback state');
    set({ status: 'DISCONNECTED', error: null, deviceStatus: {} });
    await commandLoop.stop();
    set({ loopRunning: false, isPlaybackActive: false, playbackSource: null });
  };

  // Handle device errors (current limit, boot, timeout, etc.)
  focStimApi.onDeviceError = async (error: DeviceError) => {
    console.error('[DeviceStore] Device error detected, stopping playback:', error);

    // Stop all playback immediately
    const { playbackSource } = get();
    if (playbackSource === 'pattern') {
      await commandLoop.stop();
    } else if (playbackSource === 'mediaSync') {
      await syncedPlayback.stop();
    }

    // Clear playback state
    set({ loopRunning: false, isPlaybackActive: false, playbackSource: null });

    // Format error message for user
    let errorMessage = error.message;
    let errorTitle = 'Device Error';

    switch (error.type) {
      case 'current_limit':
        errorTitle = 'Current Limit Exceeded';
        errorMessage = 'The device stopped playback due to excessive current.\n\n';
        if (error.details) {
          errorMessage += `Details: ${error.details}\n\n`;
        }
        errorMessage += 'This is a safety feature. Please check your settings and try again with lower amplitude.';
        break;

      case 'boot':
        errorTitle = 'Device Reset';
        errorMessage = 'The device has rebooted unexpectedly.\n\n';
        errorMessage += 'This may indicate a firmware crash or power issue. Playback has been stopped.';
        break;

      case 'timeout':
        errorTitle = 'Communication Timeout';
        errorMessage = 'Lost communication with device.\n\n';
        if (error.details) {
          errorMessage += `${error.details}\n\n`;
        }
        errorMessage += 'Playback has been stopped.';
        break;

      default:
        if (error.details) {
          errorMessage += `\n\n${error.details}`;
        }
        break;
    }

    errorMessage += `\n\nTime: ${error.timestamp.toLocaleTimeString()}`;

    // Show alert to user
    Alert.alert(errorTitle, errorMessage, [
      { text: 'OK', style: 'default' }
    ]);

    // Set error state
    set({ error: error.message });
  };

  // Handle device notifications
  focStimApi.onNotification = (notification: Notification) => {
    const updates: Partial<DeviceStatus> = { lastUpdate: Date.now() };

    // Extract system stats (temperature, voltages)
    if (notification.notification.case === 'notificationSystemStats') {
      const systemStats = notification.notification.value;
      if (systemStats.system.case === 'focstimv3') {
        updates.temperature = systemStats.system.value.tempStm32;
      }
    }

    // Extract battery stats
    if (notification.notification.case === 'notificationBattery') {
      const battery = notification.notification.value;
      updates.batteryVoltage = battery.batteryVoltage;
      updates.batterySoc = battery.batterySoc;
      updates.wallPowerPresent = battery.wallPowerPresent;
    }

    // Extract signal stats
    if (notification.notification.case === 'notificationSignalStats') {
      const signalStats = notification.notification.value;
      updates.pulseFrequency = signalStats.actualPulseFrequency;
      updates.vDrive = signalStats.vDrive;
    }

    // Update state with new values
    if (Object.keys(updates).length > 1) { // More than just lastUpdate
      set((state) => ({
        deviceStatus: { ...state.deviceStatus, ...updates }
      }));
    }
  };

  return {
    // Initial connection state
    status: 'DISCONNECTED',
    ipAddress: '192.168.1.1',
    error: null,
    loopRunning: false,
    deviceStatus: {},

    // Initial playback state
    isPlaybackActive: false,
    playbackSource: null,

    // Initial pattern control
    patternSpeed: 2.0, // rad/s

    // Initial settings state (will be loaded from storage)
    deviceSettings: DefaultSettings.device,
    pulseSettings: DefaultSettings.pulse,
    focstimSettings: DefaultSettings.focstim,
    mediaSyncSettings: DefaultSettings.mediaSync,
    settingsLoaded: false,

    // Connection actions
    setIpAddress: (ip) => {
      set({ ipAddress: ip });
    },
    connect: async () => {
      const { ipAddress } = get();

      if (!ipAddress) {
        set({ status: 'ERROR', error: 'No IP address provided.' });
        return;
      }

      set({ status: 'CONNECTING', error: null });

      try {
        await focStimApi.connectTcp(ipAddress);
        set({ status: 'CONNECTED' });
      } catch (err: any) {
        set({ status: 'ERROR', error: err.message });
      }
    },
    disconnect: async () => {
      await commandLoop.stop();
      focStimApi.disconnect();
      set({ status: 'DISCONNECTED', loopRunning: false, isPlaybackActive: false, playbackSource: null });
    },
    toggleLoop: async () => {
      const { loopRunning, status } = get();
      if (status !== 'CONNECTED') return;

      if (loopRunning) {
        await commandLoop.stop();
        set({ loopRunning: false });
        get().clearPlaybackActive();
      } else {
        // Check if another playback source is active
        if (!get().canStartPlayback('pattern')) {
          const { playbackSource } = get();
          set({ error: `Cannot start pattern: ${playbackSource} is currently playing` });
          console.warn(`[DeviceStore] Cannot start pattern while ${playbackSource} is active`);
          return;
        }

        try {
          get().setPlaybackActive('pattern');
          await commandLoop.start();
          set({ loopRunning: true });
        } catch (err: any) {
          console.error('[DeviceStore] Failed to start pattern:', err);
          set({ error: `Failed to start pattern: ${err.message}` });
          get().clearPlaybackActive();
        }
      }
    },

    // Playback state actions
    setPlaybackActive: (source: PlaybackSource) => {
      console.log(`[DeviceStore] Setting playback active: ${source}`);
      set({ isPlaybackActive: true, playbackSource: source });
    },

    clearPlaybackActive: () => {
      console.log('[DeviceStore] Clearing playback active');
      set({ isPlaybackActive: false, playbackSource: null });
    },

    canStartPlayback: (requestedSource: PlaybackSource) => {
      const { isPlaybackActive, playbackSource } = get();
      if (!isPlaybackActive) return true;
      if (playbackSource === requestedSource) return true; // Same source can restart
      console.warn(`[DeviceStore] Cannot start ${requestedSource}: ${playbackSource} is already active`);
      return false;
    },

    // Pattern actions
    setPatternSpeed: (speed: number) => {
      set({ patternSpeed: speed });
      commandLoop.setPatternSpeed(speed);
    },

    // Settings actions
    loadSettings: async () => {
      try {
        console.log('[DeviceStore] Loading settings from storage...');

        // Migrate WiFi IP from old storage if needed
        await SettingsService.migrateWifiIpFromOldStorage();

        // Load all settings
        const settings = await SettingsService.loadAllSettings();

        set({
          deviceSettings: settings.device,
          pulseSettings: settings.pulse,
          focstimSettings: settings.focstim,
          mediaSyncSettings: settings.mediaSync,
          settingsLoaded: true,
        });

        // Update IP address from focstim settings if available
        if (settings.focstim.wifiIp) {
          set({ ipAddress: settings.focstim.wifiIp });
        }

        console.log('[DeviceStore] Settings loaded successfully');
      } catch (error) {
        console.error('[DeviceStore] Error loading settings:', error);
        // Keep defaults on error
        set({ settingsLoaded: true });
      }
    },

    saveDeviceSettings: async (settings: DeviceSettings) => {
      try {
        await SettingsService.saveDeviceSettings(settings);
        set({ deviceSettings: settings });
        console.log('[DeviceStore] Device settings saved');
      } catch (error) {
        console.error('[DeviceStore] Error saving device settings:', error);
        throw error;
      }
    },

    savePulseSettings: async (settings: PulseSettings) => {
      try {
        await SettingsService.savePulseSettings(settings);
        set({ pulseSettings: settings });
        console.log('[DeviceStore] Pulse settings saved');
      } catch (error) {
        console.error('[DeviceStore] Error saving pulse settings:', error);
        throw error;
      }
    },

    saveFocStimSettings: async (settings: FocStimSettings) => {
      try {
        await SettingsService.saveFocStimSettings(settings);
        set({ focstimSettings: settings });

        // Update IP address if changed
        if (settings.wifiIp) {
          set({ ipAddress: settings.wifiIp });
        }

        console.log('[DeviceStore] FOC-Stim settings saved');
      } catch (error) {
        console.error('[DeviceStore] Error saving FOC-Stim settings:', error);
        throw error;
      }
    },

    saveMediaSyncSettings: async (settings: MediaSyncSettings) => {
      try {
        await SettingsService.saveMediaSyncSettings(settings);
        set({ mediaSyncSettings: settings });
        console.log('[DeviceStore] Media Sync settings saved');
      } catch (error) {
        console.error('[DeviceStore] Error saving Media Sync settings:', error);
        throw error;
      }
    },

    resetToDefaults: async () => {
      try {
        await SettingsService.resetToDefaults();
        set({
          deviceSettings: DefaultSettings.device,
          pulseSettings: DefaultSettings.pulse,
          focstimSettings: DefaultSettings.focstim,
          mediaSyncSettings: DefaultSettings.mediaSync,
        });
        console.log('[DeviceStore] Settings reset to defaults');
      } catch (error) {
        console.error('[DeviceStore] Error resetting settings:', error);
        throw error;
      }
    },
  };
});
