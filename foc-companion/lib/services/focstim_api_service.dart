import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:foc_companion/core/hdlc.dart';
import 'package:foc_companion/generated/protobuf/focstim_rpc.pb.dart'; // Will be generated
import 'package:foc_companion/generated/protobuf/messages.pb.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/generated/protobuf/constants.pbenum.dart';

final _log = AppLogger.instance;

const int _kVersionMajor = 1;
const int _kVersionMinorMin = 1;
const String _kVersionBranch = 'main';

class FocStimApiService {
  Socket? _socket;
  final Hdlc _hdlc = Hdlc();
  final Map<int, Completer<Response>> _pendingRequests = {};
  int _requestIdCounter = 1;

  // Events
  Function(Notification)? onNotification;
  Function(String)? onError;
  Function()? onDisconnect;

  bool get isConnected => _socket != null;

  /// Number of requests currently awaiting a response.
  int get pendingCount => _pendingRequests.length;

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
        onDone: () {
          disconnect();
        },
      );
    } catch (e) {
      throw Exception("Failed to connect: $e");
    }
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
    onDisconnect?.call();
    _pendingRequests.clear();
  }

  void _onData(Uint8List data) {
    // print("RX: ${data.length} bytes");
    List<Uint8List> frames = _hdlc.parse(data);
    for (var frame in frames) {
      try {
        var message = RpcMessage.fromBuffer(frame);
        if (message.hasResponse()) {
          _handleResponse(message.response);
        } else if (message.hasNotification()) {
          // print("Notification: ${message.notification.whichNotification()}");
          onNotification?.call(message.notification);
        }
      } catch (e) {
        _log.e("Proto parse error", error: e);
      }
    }
  }

  void _handleResponse(Response response) {
    if (_pendingRequests.containsKey(response.id)) {
      var completer = _pendingRequests.remove(response.id)!;
      if (response.hasError() && response.error.code != Errors.ERROR_UNKNOWN) {
        completer.completeError("Device Error: ${response.error.code}");
      } else {
        completer.complete(response);
      }
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
    if (_socket == null) throw Exception("Not connected");

    request.id = _requestIdCounter++;
    var rpcMessage = RpcMessage()..request = request;
    var data = rpcMessage.writeToBuffer();
    var framed = Hdlc.encode(Uint8List.fromList(data));

    var completer = Completer<Response>();
    _pendingRequests[request.id] = completer;

    _socket!.add(framed);

    return completer.future.timeout(timeout, onTimeout: () {
      _pendingRequests.remove(request.id);
      throw TimeoutException("Request ${request.id} timed out");
    });
  }

  Future<ResponseFirmwareVersion> requestFirmwareVersion() async {
    var req = Request()..requestFirmwareVersion = RequestFirmwareVersion();
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

  Future<void> startSignal({OutputMode mode = OutputMode.OUTPUT_THREEPHASE}) async {
    var req = Request()
      ..requestSignalStart = (RequestSignalStart()..mode = mode);
    await sendRequest(req);
  }

  Future<void> stopSignal() async {
    var req = Request()..requestSignalStop = RequestSignalStop();
    await sendRequest(req);
  }
}
