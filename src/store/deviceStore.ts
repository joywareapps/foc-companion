import { create } from 'zustand';
import { focStimApi } from '@/core/FocStimApiService';
import { commandLoop } from '@/core/CommandLoop';
import type { Notification } from '@/generated/protobuf/focstim_rpc_pb';

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
  status: ConnectionStatus;
  ipAddress: string;
  error: string | null;
  loopRunning: boolean;
  deviceStatus: DeviceStatus;
  setIpAddress: (ip: string) => void;
  connect: () => Promise<void>;
  disconnect: () => Promise<void>;
  toggleLoop: () => Promise<void>;
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
    status: 'DISCONNECTED',
    ipAddress: '192.168.1.1',
    error: null,
    loopRunning: false,
    deviceStatus: {},
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
  };
});
