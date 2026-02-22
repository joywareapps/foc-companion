# Quick Start Guide

## Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- Android Studio or VS Code with Flutter extension
- An Android device or emulator

## Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/joywareapps/restim-mobile.git
   cd restim-mobile
   ```

2. **Navigate to the Flutter project:**
   ```bash
   cd restim-flutter
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Generate Protobuf files:**
   ```bash
   # On Linux/macOS
   ./generate_protos.sh
   
   # On Windows
   generate_protos.bat
   ```

5. **Run the application:**
   ```bash
   flutter run
   ```

## Connecting to FOC-Stim

1. Power on your FOC-Stim device.
2. Ensure your phone and the device are on the same WiFi network.
3. Open the app and go to the **Settings** tab.
4. Enter the **IP Address** of your FOC-Stim device (default is usually `192.168.1.1` if in AP mode).
5. Click **Save Settings**.
6. Go to the **Control** tab and click **Connect**.

## Troubleshooting

- **Connection failed:** Verify the IP address is correct and both devices are on the same network.
- **Protobuf errors:** Ensure you have the `protoc` compiler installed and run the generation script.
- **Build errors:** Run `flutter clean` and then `flutter pub get`.

For detailed network troubleshooting, see [NETWORK_TROUBLESHOOTING.md](documents/features-parked/NETWORK_TROUBLESHOOTING.md).
