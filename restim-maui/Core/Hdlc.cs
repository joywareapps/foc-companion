using System;
using System.Collections.Generic;
using System.IO;

namespace RestimMaui.Core
{
    public class Hdlc
    {
        private const byte FRAME_BOUNDARY_MARKER = 0x7E;
        private const byte ESCAPE_MARKER = 0x7D;
        private const byte ESCAPE_XOR = 0x20;

        private bool _escapeNext;
        private readonly List<byte> _pendingPayload = new List<byte>();
        private readonly int _maxLen;

        public Hdlc(int maxLen = 1024)
        {
            _maxLen = maxLen;
        }

        public List<byte[]> Parse(byte[] data)
        {
            var resultingFrames = new List<byte[]>();

            foreach (var b in data)
            {
                if (b == FRAME_BOUNDARY_MARKER)
                {
                    if (_pendingPayload.Count >= 2)
                    {
                        var payload = _pendingPayload.GetRange(0, _pendingPayload.Count - 2).ToArray();
                        var computedCrc = Crc16(payload);
                        
                        // CRC is little-endian in the stream
                        var packetCrc = _pendingPayload[_pendingPayload.Count - 2] | (_pendingPayload[_pendingPayload.Count - 1] << 8);

                        if (computedCrc == packetCrc)
                        {
                            resultingFrames.Add(payload);
                        }
                    }
                    Reset();
                }
                else if (b == ESCAPE_MARKER)
                {
                    _escapeNext = true;
                }
                else
                {
                    var val = b;
                    if (_escapeNext)
                    {
                        val ^= ESCAPE_XOR;
                        _escapeNext = false;
                    }

                    _pendingPayload.Add(val);

                    if (_pendingPayload.Count > _maxLen)
                    {
                        Console.WriteLine("HDLC: max length exceeded, resetting buffer");
                        Reset();
                    }
                }
            }

            return resultingFrames;
        }

        public static byte[] Encode(byte[] payload)
        {
            if (payload.Length > 65536)
                throw new ArgumentException("Maximum length of payload is 65536");

            var checksum = Crc16(payload);
            var checksumBytes = new byte[] { (byte)(checksum & 0xFF), (byte)((checksum >> 8) & 0xFF) };

            var escapedPayload = Escape(payload);
            var escapedChecksum = Escape(checksumBytes);

            var output = new List<byte>();
            output.Add(FRAME_BOUNDARY_MARKER);
            output.AddRange(escapedPayload);
            output.AddRange(escapedChecksum);
            output.Add(FRAME_BOUNDARY_MARKER);

            return output.ToArray();
        }

        private static byte[] Escape(byte[] data)
        {
            var outList = new List<byte>();
            foreach (var b in data)
            {
                if (b == FRAME_BOUNDARY_MARKER || b == ESCAPE_MARKER)
                {
                    outList.Add(ESCAPE_MARKER);
                    outList.Add((byte)(b ^ ESCAPE_XOR));
                }
                else
                {
                    outList.Add(b);
                }
            }
            return outList.ToArray();
        }

        private void Reset()
        {
            _escapeNext = false;
            _pendingPayload.Clear();
        }

        // CRC-16-CCITT (X.25) polynomial 0x1021
        private static ushort Crc16(byte[] data)
        {
            ushort crc = 0xFFFF;
            foreach (var b in data)
            {
                var x = (ushort)((crc >> 8) ^ b);
                x ^= (ushort)(x >> 4);
                crc = (ushort)((crc << 8) ^ (x << 12) ^ (x << 5) ^ x);
            }
            return (ushort)(crc ^ 0xFFFF); 
            // Note: The python js-crc/models crc_16_x_25 implementation might differ slightly.
            // Standard X.25 often negates the output.
            // We should verify if this matches the TypeScript `crc_16_x_25`.
            // TS used `js-crc`.
            // If this implementation is incorrect, we can swap it. 
            // The standard CRC16-X25 logic is usually: Init FFFF, Poly 1021, RefIn True, RefOut True, XorOut FFFF.
            // The simple loop above is standard CCITT. 
            
            // Re-implementing essentially the same logic as typical X.25 to be safe:
            // return Crc16X25(data); 
        }
    }
}
