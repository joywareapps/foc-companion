@echo off
echo Generating Dart Protobuf files...

:: Ensure output directory exists
if not exist "foc-companion\lib\generated\protobuf" mkdir "foc-companion\lib\generated\protobuf"

:: Define paths
set PROTO_SRC=proto\focstim
set OUTPUT_DIR=foc-companion\lib\generated\protobuf

:: Run protoc
:: Note: Assumes protoc-gen-dart is in PATH or configured. 
:: If not, users might need to run 'dart pub global activate protoc_plugin' first.

protoc --dart_out=%OUTPUT_DIR% -I=%PROTO_SRC% %PROTO_SRC%\constants.proto %PROTO_SRC%\messages.proto %PROTO_SRC%\notifications.proto %PROTO_SRC%\focstim_rpc.proto

if %ERRORLEVEL% NEQ 0 (
    echo Error generating files. Ensure 'protoc' is installed and 'protoc-gen-dart' is in your PATH.
    echo Try running: dart pub global activate protoc_plugin
    exit /b %ERRORLEVEL%
)

echo Done! Files generated in %OUTPUT_DIR%
