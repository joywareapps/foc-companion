// HereSphere TCP socket integration service
// Based on restim-desktop implementation: source-repos/restim-desktop/net/media_source/heresphere.py
// Uses TCP socket with binary protocol (length-prefixed JSON messages)

import { Buffer } from 'buffer';
import TcpSocket from 'react-native-tcp-socket';
import type { HereSphereStatus, HereSphereConnectionState } from '@/types/heresphere';
import { HereSphereConnectionState as ConnectionState } from '@/types/heresphere';

type StatusCallback = (status: HereSphereStatus | null, state: HereSphereConnectionState) => void;

export class HereSphereService {
  private socket: any = null;
  private host: string = '';
  private port: number = 0;
  private statusCallback: StatusCallback | null = null;
  private keepAliveInterval: ReturnType<typeof setInterval> | null = null;
  private reconnectTimeout: ReturnType<typeof setTimeout> | null = null;
  private isEnabled: boolean = false;
  private buffer: Buffer = Buffer.alloc(0);

  /**
   * Configure HereSphere connection
   */
  configure(ip: string, port: number) {
    this.host = ip;
    this.port = port;
    console.log(`[HereSphere] Configured: ${this.host}:${this.port}`);
  }

  /**
   * Connect to HereSphere TCP server
   */
  connect(onStatus: StatusCallback): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.host || !this.port) {
        reject(new Error('HereSphere not configured. Set IP and port first.'));
        return;
      }

      this.statusCallback = onStatus;
      this.isEnabled = true;

      console.log(`[HereSphere] Connecting to ${this.host}:${this.port}...`);

      try {
        // Create TCP socket
        this.socket = TcpSocket.createConnection(
          {
            port: this.port,
            host: this.host,
          },
          () => {
            console.log('[HereSphere] Connected to TCP socket');
            this.startKeepAlive();
            this.notifyStatus(null, ConnectionState.CONNECTED_BUT_NO_FILE);
            resolve();
          }
        );

        // Set timeout manually
        setTimeout(() => {
          if (!this.socket || this.socket.readyState !== 'open') {
            const error = new Error('Connection timeout');
            this.socket?.destroy();
            reject(error);
          }
        }, 5000);

        // Handle incoming data
        this.socket.on('data', (data: Buffer) => {
          this.handleData(data);
        });

        // Handle errors
        this.socket.on('error', (error: Error) => {
          console.error('[HereSphere] Socket error:', error);
          this.notifyStatus(null, ConnectionState.NOT_CONNECTED);
          this.scheduleReconnect();
          reject(error);
        });

        // Handle connection close
        this.socket.on('close', () => {
          console.log('[HereSphere] Connection closed');
          this.notifyStatus(null, ConnectionState.NOT_CONNECTED);
          this.scheduleReconnect();
        });

      } catch (error) {
        console.error('[HereSphere] Failed to create socket:', error);
        reject(error);
      }
    });
  }

  /**
   * Disconnect from HereSphere
   */
  disconnect() {
    console.log('[HereSphere] Disconnecting...');
    this.isEnabled = false;

    this.stopKeepAlive();
    this.clearReconnect();

    if (this.socket) {
      this.socket.destroy();
      this.socket = null;
    }

    this.buffer = Buffer.alloc(0);
    this.notifyStatus(null, ConnectionState.NOT_CONNECTED);
  }

  /**
   * Handle incoming TCP data
   * Protocol: 4-byte length header (little-endian) + JSON payload
   */
  private handleData(data: Buffer) {
    // Append to buffer
    this.buffer = Buffer.concat([this.buffer, data]);

    // Process complete messages
    while (this.buffer.length >= 4) {
      // Read 4-byte length header (little-endian)
      const length = this.buffer.readUInt32LE(0);

      // Keep-alive message (4 null bytes)
      if (length === 0) {
        console.log('[HereSphere] Received keep-alive');
        this.buffer = this.buffer.slice(4);
        this.notifyStatus(null, ConnectionState.CONNECTED_BUT_NO_FILE);
        continue;
      }

      // Check if we have the complete message
      if (this.buffer.length < 4 + length) {
        // Wait for more data
        break;
      }

      // Extract JSON payload
      const jsonData = this.buffer.slice(4, 4 + length);
      this.buffer = this.buffer.slice(4 + length);

      try {
        const status: HereSphereStatus = JSON.parse(jsonData.toString('utf-8'));
        console.log('[HereSphere] Received status:', status);

        // Determine state from playerState
        const state = status.playerState === 0
          ? ConnectionState.CONNECTED_AND_PLAYING
          : ConnectionState.CONNECTED_AND_PAUSED;

        this.notifyStatus(status, state);
      } catch (error) {
        console.error('[HereSphere] Failed to parse JSON:', error);
        this.disconnect();
      }
    }
  }

  /**
   * Start keep-alive timer (sends 4 null bytes every 1 second)
   */
  private startKeepAlive() {
    this.stopKeepAlive();

    this.keepAliveInterval = setInterval(() => {
      if (this.socket && this.socket.writable) {
        // Send keep-alive: 4 null bytes
        const keepAlive = Buffer.from([0, 0, 0, 0]);
        this.socket.write(keepAlive);
        console.log('[HereSphere] Sent keep-alive');
      }
    }, 1000); // Every 1 second
  }

  /**
   * Stop keep-alive timer
   */
  private stopKeepAlive() {
    if (this.keepAliveInterval) {
      clearInterval(this.keepAliveInterval);
      this.keepAliveInterval = null;
    }
  }

  /**
   * Schedule reconnection attempt
   */
  private scheduleReconnect() {
    if (!this.isEnabled) return;

    this.clearReconnect();

    console.log('[HereSphere] Scheduling reconnect in 1 second...');
    this.reconnectTimeout = setTimeout(() => {
      if (this.isEnabled && this.statusCallback) {
        console.log('[HereSphere] Attempting reconnect...');
        this.connect(this.statusCallback).catch((error) => {
          console.error('[HereSphere] Reconnect failed:', error);
        });
      }
    }, 1000);
  }

  /**
   * Clear reconnection timeout
   */
  private clearReconnect() {
    if (this.reconnectTimeout) {
      clearTimeout(this.reconnectTimeout);
      this.reconnectTimeout = null;
    }
  }

  /**
   * Notify status callback
   */
  private notifyStatus(status: HereSphereStatus | null, state: HereSphereConnectionState) {
    if (this.statusCallback) {
      this.statusCallback(status, state);
    }
  }

  /**
   * Test connection to HereSphere
   */
  async testConnection(): Promise<boolean> {
    return new Promise((resolve) => {
      let resolved = false;

      const cleanup = () => {
        if (!resolved) {
          resolved = true;
          this.disconnect();
        }
      };

      // Set timeout
      const timeout = setTimeout(() => {
        cleanup();
        resolve(false);
      }, 5000);

      // Try to connect
      this.connect((status, state) => {
        if (state !== ConnectionState.NOT_CONNECTED && !resolved) {
          resolved = true;
          clearTimeout(timeout);
          this.disconnect();
          resolve(true);
        }
      }).catch(() => {
        cleanup();
        clearTimeout(timeout);
        resolve(false);
      });
    });
  }

  /**
   * Check if connected
   */
  isConnected(): boolean {
    return this.socket !== null && this.isEnabled;
  }

  /**
   * Cleanup resources
   */
  dispose() {
    this.disconnect();
  }
}

// Singleton instance
export const hereSphereService = new HereSphereService();
