# Communication Layers Specification

This document details the various communication layers used in the Restim desktop application to interface with hardware devices and other services.

## 1. FOC-Stim Device Communication

The `FOCStimProtoDevice` class handles communication with the FOC-Stim hardware. It supports two transport methods: Serial and TCP. The application-level protocol, which consists of HDLC-framed Protobuf messages, is identical across both transports.

### 1.1. Serial (QSerialPort)

-   **Implementation**: `device/focstim/proto_device.py` -> `FOCStimProtoDevice.start_serial()`
-   **Library**: `PySide6.QtSerialPort.QSerialPort`
-   **Configuration**:
    -   Baud Rate: 115200
    -   The specific COM port is user-configurable via the settings.
-   **Protocol Stack**: `Protobuf` -> `HDLC` -> `QSerialPort`

The `FOCStimProtoAPI` class receives the initialized `QSerialPort` object and handles reading and writing data. It uses an `HDLC` class (`device/focstim/hdlc.py`) to encode and decode data frames.

### 1.2. TCP (QTcpSocket)

-   **Implementation**: `device/focstim/proto_device.py` -> `FOCStimProtoDevice.start_tcp()`
-   **Library**: `PySide6.QtNetwork.QTcpSocket`
-   **Configuration**:
    -   The host address and port are user-configurable. Default appears to be port 55533.
-   **Protocol Stack**: `Protobuf` -> `HDLC` -> `QTcpSocket`

Similar to the serial implementation, the `FOCStimProtoAPI` class uses the `QTcpSocket` object for communication, with the same HDLC framing and Protobuf message structure.

### 1.3. Protocol Identity

The application protocol for FOC-Stim is **identical** for both Serial and TCP transports. The `FOCStimProtoAPI` abstracts the transport layer, ensuring that the same stream of bytes (HDLC-framed Protobuf messages) is sent regardless of the underlying medium.

## 2. NeoStim Device Communication

The `NeoStim` class (`device/neostim/neostim_device.py`) handles communication with the NeoStim hardware.

-   **Implementation**: `device/neostim/neostim_device.py` -> `NeoStim.start()`
-   **Library**: `PySide6.QtSerialPort.QSerialPort`
-   **Configuration**:
    -   Baud Rate: 115200
-   **Protocol Stack**: It uses a custom binary protocol, not Protobuf. The protocol is defined by `Frame` and `AttributeAction` data classes within the same file. It includes a custom CRC8 and CRC16 for integrity.

## 3. Other Network Layers

The application includes several other networking components, primarily for interacting with external software and services rather than the primary e-stim hardware.

### 3.1. T-Code Servers (TCP/UDP)

-   **Implementation**: `net/tcpudpserver.py`
-   **Libraries**: `PySide6.QtNetwork.QTcpServer`, `PySide6.QtNetwork.QUdpSocket`
-   **Purpose**: Listens for incoming T-Code commands over TCP and UDP sockets. These are user-configurable and are typically used for integration with other applications.

### 3.2. WebSocket Server

-   **Implementation**: `net/websocketserver.py`
-   **Library**: `PySide6.QtWebSockets.QWebSocketServer`
-   **Purpose**: Listens for incoming T-Code commands over a WebSocket connection, allowing for web-based integrations.

### 3.3. Buttplug.io WSDM Client

-   **Implementation**: `net/buttplug_wsdm_client.py`
-   **Library**: `PySide6.QtWebSockets.QWebSocket`
-   **Purpose**: Connects to a Buttplug.io WebSocket server to receive T-Code commands, often used for synchronization with toys.

### 3.4. Media Player Integrations

-   **Implementation**: `net/media_source/`
-   **Libraries**: `QNetworkAccessManager` (for HTTP), `QWebSocket`
-   **Purpose**: These classes (`MPC`, `HereSphere`, `VLC`, `Kodi`) connect to various media players over the network to synchronize funscript playback with video playback. They use the specific API of each media player, typically involving HTTP or WebSockets.

## 4. Mobile Migration Considerations

-   **Serial/USB**: For the React Native app, `PySide6.QtSerialPort` will need to be replaced with a native module for USB-Serial communication. The `react-native-serialport` or a similar library would be a suitable replacement, as suggested in `guidelines.md`. The HDLC framing and Protobuf serialization logic can be ported directly to JavaScript/TypeScript.
-   **TCP/IP & WebSockets**: Standard networking libraries in React Native (e.g., `react-native-tcp-socket`, built-in `WebSocket` API) can replace the Qt networking components for FOC-Stim TCP communication and other network integrations.
-   **NeoStim Protocol**: The custom binary protocol for NeoStim will need to be re-implemented in JavaScript/TypeScript, along with its CRC calculations. The communication will also go through a USB-Serial native module.
-   **Protocol Unification**: Since the application-level protocol for FOC-Stim is the same across Serial and TCP, the mobile app can implement a single `FOCStimProtoAPI` class in TypeScript that works with either a Serial or TCP transport layer module, simplifying the architecture.