import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:restim_flutter/core/hdlc.dart';
import 'package:restim_flutter/generated/protobuf/focstim_rpc.pb.dart'; // Will be generated
import 'package:restim_flutter/generated/protobuf/messages.pb.dart';
import 'package:restim_flutter/generated/protobuf/notifications.pb.dart';
import 'package:restim_flutter/generated/protobuf/constants.pbenum.dart';

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

  Future<void> connectTcp(String ip, int port) async {
    try {
      _socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
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
    List<Uint8List> frames = _hdlc.parse(data);
    for (var frame in frames) {
      try {
        var message = RpcMessage.fromBuffer(frame);
        if (message.hasResponse()) {
          _handleResponse(message.response);
        } else if (message.hasNotification()) {
          onNotification?.call(message.notification);
        }
      } catch (e) {
        print("Proto parse error: $e");
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

  Future<Response> sendRequest(Request request) async {
    if (_socket == null) throw Exception("Not connected");

    request.id = _requestIdCounter++;
    var rpcMessage = RpcMessage()..request = request;
    var data = rpcMessage.writeToBuffer();
    var framed = Hdlc.encode(Uint8List.fromList(data));

    var completer = Completer<Response>();
    _pendingRequests[request.id] = completer;

    _socket!.add(framed);

    // Timeout
    return completer.future.timeout(const Duration(seconds: 5), onTimeout: () {
      _pendingRequests.remove(request.id);
      throw TimeoutException("Request ${request.id} timed out");
    });
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
