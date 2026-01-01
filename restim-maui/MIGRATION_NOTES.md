# Migration Notes & Implementation Status

## Skipped / Simplified Items
1. **Protobuf Generation**: 
   - The `.csproj` is configured to use `Grpc.Tools`.
   - **Action Required**: You must copy the `proto/` folder from the React Native project to `restim-maui/Proto`.
   - The C# code assumes generated classes exist in the namespace `FocstimRpc`.

2. **Hardware Abstraction Layer**:
   - `ISerialService` interface created.
   - Windows uses `System.IO.Ports`.
   - Android requires a specific library (e.g., `UsbSerialForAndroid`). Current implementation throws `NotImplementedException` for USB on Android (WiFi works).

3. **SMB/WebDAV**:
   - `SMBLibrary` referenced. `WebDAVService` logic ported to generic `IFileSourceService`.

4. **Styling**:
   - Standard MAUI controls used. Colors approximated.

## To Run
1. Copy `proto/` folder from `restim-mobile` to `restim-maui/Proto`.
2. Run `dotnet build`.
3. Run on Android Emulator (net9.0-android) or Windows Machine (net9.0-windows).
