import 'dart:typed_data';
import 'package:foc_companion/services/app_logger.dart';

final _log = AppLogger.instance;

class Hdlc {
  static const int frameBoundaryMarker = 0x7E;
  static const int escapeMarker = 0x7D;
  static const int escapeXor = 0x20;

  bool _escapeNext = false;
  List<int> _pendingPayload = [];
  final int _maxLen;

  Hdlc({int maxLen = 1024}) : _maxLen = maxLen;

  List<Uint8List> parse(Uint8List data) {
    List<Uint8List> resultingFrames = [];

    for (int b in data) {
      if (b == frameBoundaryMarker) {
        if (_pendingPayload.length >= 2) {
          // Check CRC
          // CRC is little-endian in packet
          int packetCrc = _pendingPayload[_pendingPayload.length - 2] |
              (_pendingPayload[_pendingPayload.length - 1] << 8);

          Uint8List payload = Uint8List.fromList(
              _pendingPayload.sublist(0, _pendingPayload.length - 2));
          
          int computedCrc = _crc16(payload);

          if (computedCrc == packetCrc) {
            resultingFrames.add(payload);
          } else {
            _log.w("HDLC: CRC Mismatch! Computed: 0x${computedCrc.toRadixString(16)}, Packet: 0x${packetCrc.toRadixString(16)}");
          }
        }
        _reset();
      } else if (b == escapeMarker) {
        _escapeNext = true;
      } else {
        int val = b;
        if (_escapeNext) {
          val ^= escapeXor;
          _escapeNext = false;
        }

        _pendingPayload.add(val);

        if (_pendingPayload.length > _maxLen) {
          _log.w('HDLC: max length exceeded, resetting buffer');
          _reset();
        }
      }
    }

    return resultingFrames;
  }

  static Uint8List encode(Uint8List payload) {
    if (payload.length > 65536) {
      throw Exception("Maximum length of payload is 65536");
    }

    int checksum = _crc16(payload);
    Uint8List checksumBytes = Uint8List(2);
    checksumBytes[0] = checksum & 0xFF;
    checksumBytes[1] = (checksum >> 8) & 0xFF;

    List<int> escapedPayload = _escape(payload);
    List<int> escapedChecksum = _escape(checksumBytes);

    List<int> output = [];
    output.add(frameBoundaryMarker);
    output.addAll(escapedPayload);
    output.addAll(escapedChecksum);
    output.add(frameBoundaryMarker);

    return Uint8List.fromList(output);
  }

  static List<int> _escape(Uint8List data) {
    List<int> out = [];
    for (int b in data) {
      if (b == frameBoundaryMarker || b == escapeMarker) {
        out.add(escapeMarker);
        out.add(b ^ escapeXor);
      } else {
        out.add(b);
      }
    }
    return out;
  }

  void _reset() {
    _escapeNext = false;
    _pendingPayload.clear();
  }

  // CRC-16/X-25 (Poly 0x1021, Init 0xFFFF, RefIn/RefOut, XorOut 0xFFFF)
  // Implemented using reversed poly 0x8408 for LSB-first processing
  static int _crc16(Uint8List data) {
    int crc = 0xFFFF;
    for (int b in data) {
      crc ^= b;
      for (int i = 0; i < 8; i++) {
        if ((crc & 1) != 0) {
          crc = (crc >> 1) ^ 0x8408;
        } else {
          crc >>= 1;
        }
      }
    }
    return crc ^ 0xFFFF;
  }
}
