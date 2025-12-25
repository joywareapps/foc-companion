import { create } from 'zustand';
import { focStimApi } from '@/core/FocStimApiService';
import { commandLoop } from '@/core/CommandLoop';
import type { Notification } from '@/generated/protobuf/focstim_rpc_pb';
import { SettingsService } from '@/services/SettingsService';
import type { DeviceSettings, PulseSettings, FocStimSettings } from '@/types/settings';
import { DefaultSettings } from '@/types/settings';

export type ConnectionStatus = 'DISCONNECTED' | 'CONNECTING' | 'CONNECTED' | 'ERROR';

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

  // Settings state
  deviceSettings: DeviceSettings;
  pulseSettings: PulseSettings;
  focstimSettings: FocStimSettings;
  settingsLoaded: boolean;

  // Connection actions
  setIpAddress: (ip: string) => void;
  connect: () => Promise<void>;
  disconnect: () => Promise<void>;
  toggleLoop: () => Promise<void>;

  // Settings actions
  loadSettings: () => Promise<void>;
  saveDeviceSettings: (settings: DeviceSettings) => Promise<void>;
  savePulseSettings: (settings: PulseSettings) => Promise<void>;
  saveFocStimSettings: (settings: FocStimSettings) => Promise<void>;
  resetToDefaults: () => Promise<void>;
}

export const useDeviceStore = create<DeviceState>((set, get) => {
  // Setup API listeners
  focStimApi.onConnectionError = async (error) => {
    set({ status: 'ERROR', error });
    await commandLoop.stop();
    set({ loopRunning: false });
  };

  focStimApi.onDisconnect = async () => {
    set({ status: 'DISCONNECTED', error: null, deviceStatus: {} });
    await commandLoop.stop();
    set({ loopRunning: false });
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

    // Initial settings state (will be loaded from storage)
    deviceSettings: DefaultSettings.device,
    pulseSettings: DefaultSettings.pulse,
    focstimSettings: DefaultSettings.focstim,
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
      set({ status: 'DISCONNECTED', loopRunning: false });
    },
    toggleLoop: async () => {
      const { loopRunning, status } = get();
      if (status !== 'CONNECTED') return;

      if (loopRunning) {
        await commandLoop.stop();
        set({ loopRunning: false });
      } else {
        try {
          await commandLoop.start();
          set({ loopRunning: true });
        } catch (err: any) {
          console.error('[DeviceStore] Failed to start pattern:', err);
          set({ error: `Failed to start pattern: ${err.message}` });
        }
      }
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

    resetToDefaults: async () => {
      try {
        await SettingsService.resetToDefaults();
        set({
          deviceSettings: DefaultSettings.device,
          pulseSettings: DefaultSettings.pulse,
          focstimSettings: DefaultSettings.focstim,
        });
        console.log('[DeviceStore] Settings reset to defaults');
      } catch (error) {
        console.error('[DeviceStore] Error resetting settings:', error);
        throw error;
      }
    },
  };
});
