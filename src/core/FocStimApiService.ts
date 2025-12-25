import TcpSocket from 'react-native-tcp-socket';
import { HDLC } from './hdlc';
import {
  RpcMessageSchema,
  RequestSchema,
  type Request,
  type Response,
  type Notification
} from '../generated/protobuf/focstim_rpc_pb';
import { OutputMode } from '../generated/protobuf/constants_pb';
import { create, toBinary, fromBinary } from '@bufbuild/protobuf';

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
    return new Promise((resolve, reject) => {
      try {
        this.tcpSocket = TcpSocket.createConnection({ host, port }, () => {
          this.isConnected = true;
          resolve();
        });

        this.tcpSocket.on('data', (data: Uint8Array) => {
          this.handleIncomingData(data);
        });

        this.tcpSocket.on('error', (error: any) => {
          if (this.onConnectionError) this.onConnectionError(error.message);
          reject(error);
        });

        this.tcpSocket.on('close', () => {
          this.cleanup();
          if (this.onDisconnect) this.onDisconnect();
        });
      } catch (err: any) {
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
          if (this.onNotification) {
            this.onNotification(rpcMessage.message.value);
          }
        }
      } catch (err) {
        console.error('Failed to decode Protobuf frame:', err);
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
        this.pendingRequests.delete(id);
        reject(new Error('Request timeout'));
      }, 5000);

      this.pendingRequests.set(id, (response) => {
        clearTimeout(timeout);
        if (response.error) {
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
      value: { mode }
    });
  }

  public async stopSignal(): Promise<void> {
    console.log('[FocStimApi] Stopping signal output');
    await this.sendRequest({
      case: 'requestSignalStop',
      value: {}
    });
  }
}

// Singleton instance
export const focStimApi = new FocStimApiService();
