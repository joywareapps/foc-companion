import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:foc_companion/core/hdlc.dart';
import 'package:foc_companion/generated/protobuf/focstim_rpc.pb.dart';
import 'package:foc_companion/generated/protobuf/messages.pb.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/generated/protobuf/constants.pbenum.dart';
import 'package:libserialport/libserialport.dart';

final _log = AppLogger.instance;

const int _kVersionMajor = 1;
const int _kVersionMinorMin = 1;
const String _kVersionBranch = 'main';

class FocStimApiService {
  // TCP transport
  Socket? _socket;

  // Serial transport (desktop only)
  SerialPort? _serialPort;
  SerialPortReader? _serialReader;

  final Hdlc _hdlc = Hdlc();
  final Map<int, Completer<Response>> _pendingRequests = {};
  int _requestIdCounter = 1;

  // Events
  Function(Notification)? onNotification;
  Function(String)? onError;
  Function()? onDisconnect;

  bool get isConnected => _socket != null || _serialPort != null;

  /// Number of requests currently awaiting a response.
  int get pendingCount => _pendingRequests.length;

  // ─── TCP ────────────────────────────────────────────────────────────────────

  Future<void> connectTcp(String ip, int port) async {
    try {
      _socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      _socket!.setOption(SocketOption.tcpNoDelay, true);
      _socket!.listen(
        _onData,
        onError: (e) {
          onError?.call("Socket error: $e");
          disconnect();
        },
        onDone: disconnect,
      );
    } catch (e) {
      throw Exception("Failed to connect: $e");
    }
  }

  // ─── Serial ─────────────────────────────────────────────────────────────────

  /// Open a serial port (COM/tty) at [baudRate] baud.
  /// Only callable on desktop (Windows / macOS / Linux).
  Future<void> connectSerial(String portName, [int baudRate = 115200]) async {
    final sp = SerialPort(portName);
    if (!sp.openReadWrite()) {
      throw Exception(
          "Failed to open serial port '$portName': ${SerialPort.lastError}");
    }

    final cfg = sp.config;
    cfg.baudRate = baudRate;
    cfg.bits = 8;
    cfg.stopBits = 1;
    cfg.parity = SerialPortParity.none;
    sp.config = cfg;

    _serialPort = sp;
    _serialReader = SerialPortReader(sp);
    _serialReader!.stream.listen(
      _onData,
      onError: (e) {
        onError?.call("Serial error: $e");
        disconnect();
      },
      onDone: disconnect,
    );
  }

  /// List available serial ports with human-readable labels.
  /// Returns an empty list on Android / iOS where libserialport isn't available.
  /// Each entry has [name] (for connecting) and [label] (for display).
  static List<({String name, String label})> listSerialPorts() {
    if (Platform.isAndroid || Platform.isIOS) return [];
    try {
      return SerialPort.availablePorts.map((name) {
        final port = SerialPort(name);
        final desc = port.description;
        final mfr = port.manufacturer;
        port.dispose();
        String label = name;
        if (desc != null && desc.isNotEmpty) {
          label = '$name — $desc';
          if (mfr != null && mfr.isNotEmpty && !desc.contains(mfr)) {
            label = '$label ($mfr)';
          }
        }
        return (name: name, label: label);
      }).toList();
    } catch (e) {
      _log.e("listSerialPorts failed", error: e);
      return [];
    }
  }

  // ─── Shared ─────────────────────────────────────────────────────────────────

  void disconnect() {
    if (!isConnected) return;
    _socket?.close();
    _socket = null;
    _serialReader?.close();
    _serialReader = null;
    _serialPort?.close();
    _serialPort = null;
    onDisconnect?.call();
    _pendingRequests.clear();
  }

  void _send(Uint8List data) {
    if (_socket != null) {
      _socket!.add(data);
    } else {
      _serialPort?.write(data);
    }
  }

  void _onData(Uint8List data) {
    final frames = _hdlc.parse(data);
    for (final frame in frames) {
      try {
        final message = RpcMessage.fromBuffer(frame);
        if (message.hasResponse()) {
          _handleResponse(message.response);
        } else if (message.hasNotification()) {
          onNotification?.call(message.notification);
        }
      } catch (e) {
        _log.e("Proto parse error", error: e);
      }
    }
  }

  void _handleResponse(Response response) {
    final completer = _pendingRequests.remove(response.id);
    if (completer == null) return;
    if (response.hasError() && response.error.code != Errors.ERROR_UNKNOWN) {
      completer.completeError("Device Error: ${response.error.code}");
    } else {
      completer.complete(response);
    }
  }

  /// Send a request and wait for the response.
  ///
  /// [timeout] defaults to 5 s for setup/control requests.
  /// Pass a shorter value (e.g. 2 s) for high-frequency tick requests.
  Future<Response> sendRequest(
    Request request, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (!isConnected) throw Exception("Not connected");

    request.id = _requestIdCounter++;
    final rpcMessage = RpcMessage()..request = request;
    final data = rpcMessage.writeToBuffer();
    final framed = Hdlc.encode(Uint8List.fromList(data));

    final completer = Completer<Response>();
    _pendingRequests[request.id] = completer;

    _send(framed);

    return completer.future.timeout(timeout, onTimeout: () {
      _pendingRequests.remove(request.id);
      throw TimeoutException("Request ${request.id} timed out");
    });
  }

  Future<ResponseFirmwareVersion> requestFirmwareVersion() async {
    final req = Request()..requestFirmwareVersion = RequestFirmwareVersion();
    final response = await sendRequest(req);
    return response.responseFirmwareVersion;
  }

  void validateFirmwareVersion(ResponseFirmwareVersion resp) {
    final v = resp.stm32FirmwareVersion2;
    if (v.branch != _kVersionBranch) {
      throw Exception(
          'Incompatible firmware branch: "${v.branch}" (expected "$_kVersionBranch")');
    }
    if (v.major != _kVersionMajor || v.minor < _kVersionMinorMin) {
      throw Exception(
          'Incompatible firmware version: ${v.major}.${v.minor}.${v.revision} '
          '(needs >= $_kVersionMajor.$_kVersionMinorMin.0)');
    }
  }

  Future<void> startSignal(
      {OutputMode mode = OutputMode.OUTPUT_THREEPHASE}) async {
    final req = Request()
      ..requestSignalStart = (RequestSignalStart()..mode = mode);
    await sendRequest(req);
  }

  Future<void> stopSignal() async {
    final req = Request()..requestSignalStop = RequestSignalStop();
    await sendRequest(req);
  }

  Future<void> lockDeviceVolume(bool lock) async {
    final req = Request()
      ..requestLockDeviceVolume = (RequestLockDeviceVolume()..lock = lock);
    await sendRequest(req);
  }
}
