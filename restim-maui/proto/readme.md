# Protocol Buffer Files

The proto files in this directory come from https://github.com/diglet48/FOC-Stim/tree/master/proto/focstim

## Regenerating C# Code

When proto files are updated, regenerate the C# code using:

### Windows (PowerShell/CMD):
```powershell
cd restim-maui
$protoc = "$env:USERPROFILE\.nuget\packages\grpc.tools\2.68.1\tools\windows_x64\protoc.exe"
& $protoc --proto_path=proto --csharp_out=Generated proto/*.proto
```

### Linux/macOS:
```bash
cd restim-maui
protoc=~/.nuget/packages/grpc.tools/2.68.1/tools/linux_x64/protoc
$protoc --proto_path=proto --csharp_out=Generated proto/*.proto
```

The generated files will be placed in the `Generated/` folder and are committed to source control.