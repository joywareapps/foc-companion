import TcpSocket from 'react-native-tcp-socket';
import { HDLC } from './hdlc';
import {
  RpcMessageSchema,
  RequestSchema,
  type Request,
  type Response,
  type Notification
} from '../generated/protobuf/focstim_rpc_pb';
import {
  RequestSignalStartSchema,
  RequestSignalStopSchema
} from '../generated/protobuf/messages_pb';
import { OutputMode } from '../generated/protobuf/constants_pb';
import { create, toBinary, fromBinary } from '@bufbuild/protobuf';
import { deviceLogger } from './DeviceNotificationLogger';

export class FocStimApiService {
  private hdlc = new HDLC();
  private tcpSocket: any = null;
  private isConnected = false;
  private requestIdCounter = 1;
  private pendingRequests = new Map<number, (response: Response) => void>();
  
  public onNotification: ((notification: Notification) => void) | null = null;
  public onConnectionError: ((error: string) => void) | null = null;
  public onDisconnect: (() => void) | null = null;

  public get connected(): boolean {
    return this.isConnected;
  }

  public async connectTcp(host: string, port: number = 55533): Promise<void> {
    deviceLogger.logSessionStart(host, port);

    return new Promise((resolve, reject) => {
      try {
        this.tcpSocket = TcpSocket.createConnection({ host, port }, () => {
          this.isConnected = true;
          console.log(`[FocStimApi] Connected to ${host}:${port}`);
          resolve();
        });

        this.tcpSocket.on('data', (data: Uint8Array) => {
          this.handleIncomingData(data);
        });

        this.tcpSocket.on('error', (error: any) => {
          deviceLogger.logConnectionError(error.message);
          if (this.onConnectionError) this.onConnectionError(error.message);
          reject(error);
        });

        this.tcpSocket.on('close', () => {
          deviceLogger.logDisconnect();
          this.cleanup();
          if (this.onDisconnect) this.onDisconnect();
        });
      } catch (err: any) {
        deviceLogger.logConnectionError(err.message);
        reject(err);
      }
    });
  }

  public disconnect() {
    if (this.tcpSocket) {
      this.tcpSocket.destroy();
    }
    this.cleanup();
  }

  private cleanup() {
    this.tcpSocket = null;
    this.isConnected = false;
    this.pendingRequests.clear();
  }

  private handleIncomingData(data: Uint8Array) {
    const frames = this.hdlc.parse(data);
    for (const frame of frames) {
      try {
        const rpcMessage = fromBinary(RpcMessageSchema, frame);

        if (rpcMessage.message.case === 'response') {
          const response = rpcMessage.message.value;
          const callback = this.pendingRequests.get(response.id);
          if (callback) {
            callback(response);
            this.pendingRequests.delete(response.id);
          }
        } else if (rpcMessage.message.case === 'notification') {
          const notification = rpcMessage.message.value;

          // Log all notifications for debugging
          deviceLogger.logNotification(notification);

          // Check for boot notification - indicates device reset (critical error)
          if (notification.notification.case === 'notificationBoot') {
            console.error('[FocStimApi] 🚨 Boot notification received - device has reset!');
            // Optionally trigger disconnect or error handling
            if (this.onConnectionError) {
              this.onConnectionError('Device reset unexpectedly (boot notification received)');
            }
          }

          // Forward notification to callback
          if (this.onNotification) {
            this.onNotification(notification);
          }
        }
      } catch (err) {
        console.error('[FocStimApi] Failed to decode Protobuf frame:', err);
      }
    }
  }

  public async sendRequest(params: Request['params']): Promise<Response> {
    if (!this.isConnected) {
      throw new Error('Not connected');
    }

    const id = this.requestIdCounter++;
    const request = create(RequestSchema, { id, params });
    const rpcMessage = create(RpcMessageSchema, {
      message: {
        case: 'request',
        value: request
      }
    });

    const binaryPayload = toBinary(RpcMessageSchema, rpcMessage);
    const framedData = HDLC.encode(binaryPayload);

    return new Promise((resolve, reject) => {
      // Set timeout for request
      const timeout = setTimeout(() => {
        // Log timeout with pending request information
        const pendingIds = Array.from(this.pendingRequests.keys());
        deviceLogger.logTimeout(id, pendingIds);

        this.pendingRequests.delete(id);
        reject(new Error(`Request timeout (ID: ${id})`));
      }, 5000);

      this.pendingRequests.set(id, (response) => {
        clearTimeout(timeout);
        if (response.error) {
          console.error(`[FocStimApi] Device error code: ${response.error.code}`);
          reject(new Error(`Device error code: ${response.error.code}`));
        } else {
          resolve(response);
        }
      });

      this.tcpSocket.write(framedData);
    });
  }

  public async startSignal(mode: OutputMode = OutputMode.OUTPUT_THREEPHASE): Promise<void> {
    console.log(`[FocStimApi] Starting signal output with mode=${mode}`);
    await this.sendRequest({
      case: 'requestSignalStart',
      value: create(RequestSignalStartSchema, { mode })
    });
  }

  public async stopSignal(): Promise<void> {
    console.log('[FocStimApi] Stopping signal output');
    await this.sendRequest({
      case: 'requestSignalStop',
      value: create(RequestSignalStopSchema, {})
    });
  }

  /**
   * Enable or disable device notification logging
   * Useful for debugging timeout issues and device communication problems
   */
  public setNotificationLogging(enabled: boolean): void {
    deviceLogger.setLoggingEnabled(enabled);
  }

  /**
   * Get notification logging statistics
   */
  public getNotificationStats() {
    return deviceLogger.getStats();
  }
}

// Singleton instance
export const focStimApi = new FocStimApiService();
