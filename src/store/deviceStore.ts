import { create } from 'zustand';
import { focStimApi } from '@/core/FocStimApiService';
import { commandLoop } from '@/core/CommandLoop';

export type ConnectionStatus = 'DISCONNECTED' | 'CONNECTING' | 'CONNECTED' | 'ERROR';

interface DeviceState {
  status: ConnectionStatus;
  ipAddress: string;
  error: string | null;
  loopRunning: boolean;
  setIpAddress: (ip: string) => void;
  connect: () => Promise<void>;
  disconnect: () => void;
  toggleLoop: () => void;
}

export const useDeviceStore = create<DeviceState>((set, get) => {
  // Setup API listeners
  focStimApi.onConnectionError = (error) => {
    set({ status: 'ERROR', error });
    commandLoop.stop();
    set({ loopRunning: false });
  };
  
  focStimApi.onDisconnect = () => {
    set({ status: 'DISCONNECTED', error: null });
    commandLoop.stop();
    set({ loopRunning: false });
  };

  return {
    status: 'DISCONNECTED',
    ipAddress: '192.168.1.1',
    error: null,
    loopRunning: false,
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
    disconnect: () => {
      commandLoop.stop();
      focStimApi.disconnect();
      set({ status: 'DISCONNECTED', loopRunning: false });
    },
    toggleLoop: () => {
      const { loopRunning, status } = get();
      if (status !== 'CONNECTED') return;

      if (loopRunning) {
        commandLoop.stop();
        set({ loopRunning: false });
      } else {
        commandLoop.start();
        set({ loopRunning: true });
      }
    },
  };
});
