# FOC Companion - FOC-Stim Mobile Application

## Overview

FOC Companion is the mobile counterpart to the [restim-desktop](https://github.com/diglet48/restim-desktop) application. It allows users to control and synchronize their **FOC-Stim** device directly from an Android or iOS device.

FOC-Stim is an open-hardware device designed for high-performance electromagnetic stimulation. This application connects to the device over TCP (WiFi) or Serial (USB) to manage pulse parameters, patterns, and media synchronization.

## Releases & Beta Testing

You can access the latest builds of FOC Companion through the following channels:

- **Latest Development Build:** Download the most recent APK from the [dev-latest release](https://github.com/joywareapps/foc-companion/releases/tag/dev-latest). This release is automatically updated with each stable development milestone.
- **Join Beta Testers (Firebase):** Register for our beta program via [Firebase App Distribution](https://appdistribution.firebase.dev/i/389a7e7fdd954a43). 

Participants in the Firebase Beta program will automatically receive a notification email whenever a new version is released, making it the easiest way to stay up-to-date with the latest features and fixes.

For feedback and support, please join the **#beta-testers** channel in our [JoyWare Discord](https://discord.gg/SbUj7R9fP5).

## Features

- **Real-time Device Control:** Connect to your FOC-Stim device and manage stimulation parameters on the fly.
- **Pattern Support:** Port of 17+ patterns from the desktop application with a "Driver Cockpit" UI for real-time control.
- **Multi-Phase Support:** Full support for both 3-phase and 4-phase output modes.
- **Device Status Monitoring:** Real-time feedback on temperature, battery, and pulse frequency.
- **Media Synchronization (Parked):** Synchronize with popular video players like **HereSphere** using TCP sockets. This feature is currently hidden to focus on stand-alone device control.
- **Automatic Funscript Loading (Parked):** Load `.funscript` files from local storage or network shares (WebDAV).

## Screenshots

| 01 - Not connected (3Phase) | 02 - Not connected (4Phase) | 03 - Pulse Settings | 04 - Device Settings |
|:---:|:---:|:---:|:---:|
| ![01](screenshots/flutter_01.png) | ![02](screenshots/flutter_02.png) | ![03](screenshots/flutter_03.png) | ![04](screenshots/flutter_04.png) |

| 05 - Connected | 06 - Calibration | 07 - Playing Pattern | 08 - Pulse Modulation (Off) |
|:---:|:---:|:---:|:---:|
| ![05](screenshots/flutter_05.png) | ![06](screenshots/flutter_06.png) | ![07](screenshots/flutter_07.png) | ![08](screenshots/flutter_08.png) |

| 09 - Pulse Modulation (Freq) | 10 - Pulse Modulation (Width) | 11 - Pulse Modulation (Both) |
|:---:|:---:|:---:|
| ![09](screenshots/flutter_09.png) | ![10](screenshots/flutter_10.png) | ![11](screenshots/flutter_11.png) |

## Project Structure

- `foc-companion/`: The primary mobile application built with Flutter.
- `documents/`: Comprehensive functional specifications and protocol documentation.
- `todo/`: Detailed task lists and research for ongoing development.

## Getting Started

To get started with the application, please see the [QUICK_START.md](QUICK_START.md) guide.

For detailed network setup and troubleshooting, refer to [NETWORK_TROUBLESHOOTING.md](documents/features-parked/NETWORK_TROUBLESHOOTING.md).

For information on the currently parked media synchronization features, see [MEDIA_SYNC_USAGE.md](documents/features-parked/MEDIA_SYNC_USAGE.md).

## Security

We take security seriously. Please refer to [SECURITY.md](SECURITY.md) for information on reporting vulnerabilities.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [restim-desktop](https://github.com/diglet48/restim-desktop) for the original implementation and patterns.
- [FOC-Stim](https://github.com/diglet48/FOC-Stim) for the open-hardware device and protocol.
- All contributors and beta testers in the community.
