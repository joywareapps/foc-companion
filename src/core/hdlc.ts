const { crc_16_x_25 } = require('js-crc');

export class HDLC {
  private static readonly FRAME_BOUNDARY_MARKER = 0x7E;
  private static readonly ESCAPE_MARKER = 0x7D;

  private escapeNext = false;
  private pendingPayload: number[] = [];
  private maxLen: number;

  constructor(maxLen: number = 1024) {
    this.maxLen = maxLen;
  }

  /**
   * Parse a chunk of incoming bytes and return any completed frames.
   */
  public parse(data: Uint8Array): Uint8Array[] {
    const resultingFrames: Uint8Array[] = [];

    for (let i = 0; i < data.length; i++) {
      const c = data[i];

      if (c === HDLC.FRAME_BOUNDARY_MARKER) {
        // End of frame, check CRC
        if (this.pendingPayload.length >= 2) {
          const payload = new Uint8Array(this.pendingPayload.slice(0, -2));
          const computedCrc = this.crcFrame(payload);
          
          // CRC is stored little-endian
          const packetCrc = this.pendingPayload[this.pendingPayload.length - 2] | 
                           (this.pendingPayload[this.pendingPayload.length - 1] << 8);

          if (computedCrc === packetCrc) {
            resultingFrames.push(payload);
          }
        }
        this.reset();
      } else if (c === HDLC.ESCAPE_MARKER) {
        this.escapeNext = true;
      } else {
        let byte = c;
        if (this.escapeNext) {
          byte ^= (1 << 5);
          this.escapeNext = false;
        }

        this.pendingPayload.push(byte);

        if (this.pendingPayload.length > this.maxLen) {
          console.warn('HDLC: max length exceeded, resetting buffer');
          this.reset();
        }
      }
    }

    return resultingFrames;
  }

  /**
   * Wrap a payload into an HDLC frame with CRC and markers.
   */
  public static encode(payload: Uint8Array): Uint8Array {
    if (payload.length > 65536) {
      throw new Error("Maximum length of payload is 65536");
    }

    const checksum = this.staticCrcFrame(payload);
    const checksumBytes = new Uint8Array(2);
    checksumBytes[0] = checksum & 0xFF;
    checksumBytes[1] = (checksum >> 8) & 0xFF;

    const escapedPayload = this.escape(payload);
    const escapedChecksum = this.escape(checksumBytes);

    const output = new Uint8Array(
      1 + escapedPayload.length + escapedChecksum.length + 1
    );

    output[0] = HDLC.FRAME_BOUNDARY_MARKER;
    output.set(escapedPayload, 1);
    output.set(escapedChecksum, 1 + escapedPayload.length);
    output[output.length - 1] = HDLC.FRAME_BOUNDARY_MARKER;

    return output;
  }

  private static escape(data: Uint8Array): Uint8Array {
    const out: number[] = [];
    for (let i = 0; i < data.length; i++) {
      const c = data[i];
      if (c === HDLC.FRAME_BOUNDARY_MARKER || c === HDLC.ESCAPE_MARKER) {
        out.push(HDLC.ESCAPE_MARKER);
        out.push(c ^ 0x20);
      } else {
        out.push(c);
      }
    }
    return new Uint8Array(out);
  }

  private reset(): void {
    this.escapeNext = false;
    this.pendingPayload = [];
  }

  private crcFrame(payload: Uint8Array): number {
    return parseInt(crc_16_x_25(payload), 16);
  }

  private static staticCrcFrame(payload: Uint8Array): number {
    return parseInt(crc_16_x_25(payload), 16);
  }
}
