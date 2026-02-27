// This is a generated file - do not edit.
//
// Generated from messages.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use firmwareVersionDescriptor instead')
const FirmwareVersion$json = {
  '1': 'FirmwareVersion',
  '2': [
    {'1': 'major', '3': 1, '4': 1, '5': 13, '10': 'major'},
    {'1': 'minor', '3': 2, '4': 1, '5': 13, '10': 'minor'},
    {'1': 'revision', '3': 3, '4': 1, '5': 13, '10': 'revision'},
    {'1': 'branch', '3': 4, '4': 1, '5': 9, '10': 'branch'},
    {'1': 'comment', '3': 5, '4': 1, '5': 9, '10': 'comment'},
  ],
};

/// Descriptor for `FirmwareVersion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List firmwareVersionDescriptor = $convert.base64Decode(
    'Cg9GaXJtd2FyZVZlcnNpb24SFAoFbWFqb3IYASABKA1SBW1ham9yEhQKBW1pbm9yGAIgASgNUg'
    'VtaW5vchIaCghyZXZpc2lvbhgDIAEoDVIIcmV2aXNpb24SFgoGYnJhbmNoGAQgASgJUgZicmFu'
    'Y2gSGAoHY29tbWVudBgFIAEoCVIHY29tbWVudA==');

@$core.Deprecated('Use requestFirmwareVersionDescriptor instead')
const RequestFirmwareVersion$json = {
  '1': 'RequestFirmwareVersion',
};

/// Descriptor for `RequestFirmwareVersion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestFirmwareVersionDescriptor =
    $convert.base64Decode('ChZSZXF1ZXN0RmlybXdhcmVWZXJzaW9u');

@$core.Deprecated('Use responseFirmwareVersionDescriptor instead')
const ResponseFirmwareVersion$json = {
  '1': 'ResponseFirmwareVersion',
  '2': [
    {
      '1': 'board',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.focstim_rpc.BoardIdentifier',
      '10': 'board'
    },
    {
      '1': 'stm32_firmware_version_2',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.FirmwareVersion',
      '10': 'stm32FirmwareVersion2'
    },
  ],
};

/// Descriptor for `ResponseFirmwareVersion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseFirmwareVersionDescriptor = $convert.base64Decode(
    'ChdSZXNwb25zZUZpcm13YXJlVmVyc2lvbhIyCgVib2FyZBgBIAEoDjIcLmZvY3N0aW1fcnBjLk'
    'JvYXJkSWRlbnRpZmllclIFYm9hcmQSVQoYc3RtMzJfZmlybXdhcmVfdmVyc2lvbl8yGAMgASgL'
    'MhwuZm9jc3RpbV9ycGMuRmlybXdhcmVWZXJzaW9uUhVzdG0zMkZpcm13YXJlVmVyc2lvbjI=');

@$core.Deprecated('Use requestCapabilitiesGetDescriptor instead')
const RequestCapabilitiesGet$json = {
  '1': 'RequestCapabilitiesGet',
};

/// Descriptor for `RequestCapabilitiesGet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestCapabilitiesGetDescriptor =
    $convert.base64Decode('ChZSZXF1ZXN0Q2FwYWJpbGl0aWVzR2V0');

@$core.Deprecated('Use responseCapabilitiesGetDescriptor instead')
const ResponseCapabilitiesGet$json = {
  '1': 'ResponseCapabilitiesGet',
  '2': [
    {'1': 'threephase', '3': 1, '4': 1, '5': 8, '10': 'threephase'},
    {'1': 'fourphase', '3': 2, '4': 1, '5': 8, '10': 'fourphase'},
    {'1': 'battery', '3': 3, '4': 1, '5': 8, '10': 'battery'},
    {'1': 'potentiometer', '3': 4, '4': 1, '5': 8, '10': 'potentiometer'},
    {
      '1': 'maximum_waveform_amplitude_amps',
      '3': 5,
      '4': 1,
      '5': 2,
      '10': 'maximumWaveformAmplitudeAmps'
    },
    {'1': 'lsm6dsox', '3': 6, '4': 1, '5': 8, '10': 'lsm6dsox'},
  ],
};

/// Descriptor for `ResponseCapabilitiesGet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseCapabilitiesGetDescriptor = $convert.base64Decode(
    'ChdSZXNwb25zZUNhcGFiaWxpdGllc0dldBIeCgp0aHJlZXBoYXNlGAEgASgIUgp0aHJlZXBoYX'
    'NlEhwKCWZvdXJwaGFzZRgCIAEoCFIJZm91cnBoYXNlEhgKB2JhdHRlcnkYAyABKAhSB2JhdHRl'
    'cnkSJAoNcG90ZW50aW9tZXRlchgEIAEoCFINcG90ZW50aW9tZXRlchJFCh9tYXhpbXVtX3dhdm'
    'Vmb3JtX2FtcGxpdHVkZV9hbXBzGAUgASgCUhxtYXhpbXVtV2F2ZWZvcm1BbXBsaXR1ZGVBbXBz'
    'EhoKCGxzbTZkc294GAYgASgIUghsc202ZHNveA==');

@$core.Deprecated('Use requestSignalStartDescriptor instead')
const RequestSignalStart$json = {
  '1': 'RequestSignalStart',
  '2': [
    {
      '1': 'mode',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.focstim_rpc.OutputMode',
      '10': 'mode'
    },
  ],
};

/// Descriptor for `RequestSignalStart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestSignalStartDescriptor = $convert.base64Decode(
    'ChJSZXF1ZXN0U2lnbmFsU3RhcnQSKwoEbW9kZRgBIAEoDjIXLmZvY3N0aW1fcnBjLk91dHB1dE'
    '1vZGVSBG1vZGU=');

@$core.Deprecated('Use responseSignalStartDescriptor instead')
const ResponseSignalStart$json = {
  '1': 'ResponseSignalStart',
};

/// Descriptor for `ResponseSignalStart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseSignalStartDescriptor =
    $convert.base64Decode('ChNSZXNwb25zZVNpZ25hbFN0YXJ0');

@$core.Deprecated('Use requestSignalStopDescriptor instead')
const RequestSignalStop$json = {
  '1': 'RequestSignalStop',
};

/// Descriptor for `RequestSignalStop`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestSignalStopDescriptor =
    $convert.base64Decode('ChFSZXF1ZXN0U2lnbmFsU3RvcA==');

@$core.Deprecated('Use responseSignalStopDescriptor instead')
const ResponseSignalStop$json = {
  '1': 'ResponseSignalStop',
};

/// Descriptor for `ResponseSignalStop`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseSignalStopDescriptor =
    $convert.base64Decode('ChJSZXNwb25zZVNpZ25hbFN0b3A=');

@$core.Deprecated('Use requestModeSetDescriptor instead')
const RequestModeSet$json = {
  '1': 'RequestModeSet',
};

/// Descriptor for `RequestModeSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestModeSetDescriptor =
    $convert.base64Decode('Cg5SZXF1ZXN0TW9kZVNldA==');

@$core.Deprecated('Use responseModeSetDescriptor instead')
const ResponseModeSet$json = {
  '1': 'ResponseModeSet',
};

/// Descriptor for `ResponseModeSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseModeSetDescriptor =
    $convert.base64Decode('Cg9SZXNwb25zZU1vZGVTZXQ=');

@$core.Deprecated('Use requestAxisMoveToDescriptor instead')
const RequestAxisMoveTo$json = {
  '1': 'RequestAxisMoveTo',
  '2': [
    {
      '1': 'axis',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.focstim_rpc.AxisType',
      '10': 'axis'
    },
    {'1': 'value', '3': 3, '4': 1, '5': 2, '10': 'value'},
    {'1': 'interval', '3': 4, '4': 1, '5': 13, '10': 'interval'},
  ],
};

/// Descriptor for `RequestAxisMoveTo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestAxisMoveToDescriptor = $convert.base64Decode(
    'ChFSZXF1ZXN0QXhpc01vdmVUbxIpCgRheGlzGAEgASgOMhUuZm9jc3RpbV9ycGMuQXhpc1R5cG'
    'VSBGF4aXMSFAoFdmFsdWUYAyABKAJSBXZhbHVlEhoKCGludGVydmFsGAQgASgNUghpbnRlcnZh'
    'bA==');

@$core.Deprecated('Use responseAxisMoveToDescriptor instead')
const ResponseAxisMoveTo$json = {
  '1': 'ResponseAxisMoveTo',
};

/// Descriptor for `ResponseAxisMoveTo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseAxisMoveToDescriptor =
    $convert.base64Decode('ChJSZXNwb25zZUF4aXNNb3ZlVG8=');

@$core.Deprecated('Use requestAxisSetDescriptor instead')
const RequestAxisSet$json = {
  '1': 'RequestAxisSet',
  '2': [
    {
      '1': 'axis',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.focstim_rpc.AxisType',
      '10': 'axis'
    },
    {'1': 'timestamp_ms', '3': 2, '4': 1, '5': 7, '10': 'timestampMs'},
    {'1': 'value', '3': 3, '4': 1, '5': 2, '10': 'value'},
    {'1': 'clear', '3': 4, '4': 1, '5': 8, '10': 'clear'},
  ],
};

/// Descriptor for `RequestAxisSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestAxisSetDescriptor = $convert.base64Decode(
    'Cg5SZXF1ZXN0QXhpc1NldBIpCgRheGlzGAEgASgOMhUuZm9jc3RpbV9ycGMuQXhpc1R5cGVSBG'
    'F4aXMSIQoMdGltZXN0YW1wX21zGAIgASgHUgt0aW1lc3RhbXBNcxIUCgV2YWx1ZRgDIAEoAlIF'
    'dmFsdWUSFAoFY2xlYXIYBCABKAhSBWNsZWFy');

@$core.Deprecated('Use responseAxisSetDescriptor instead')
const ResponseAxisSet$json = {
  '1': 'ResponseAxisSet',
};

/// Descriptor for `ResponseAxisSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseAxisSetDescriptor =
    $convert.base64Decode('Cg9SZXNwb25zZUF4aXNTZXQ=');

@$core.Deprecated('Use requestTimestampSetDescriptor instead')
const RequestTimestampSet$json = {
  '1': 'RequestTimestampSet',
  '2': [
    {'1': 'timestamp_ms', '3': 1, '4': 1, '5': 4, '10': 'timestampMs'},
  ],
};

/// Descriptor for `RequestTimestampSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestTimestampSetDescriptor = $convert.base64Decode(
    'ChNSZXF1ZXN0VGltZXN0YW1wU2V0EiEKDHRpbWVzdGFtcF9tcxgBIAEoBFILdGltZXN0YW1wTX'
    'M=');

@$core.Deprecated('Use responseTimestampSetDescriptor instead')
const ResponseTimestampSet$json = {
  '1': 'ResponseTimestampSet',
  '2': [
    {'1': 'offset_ms', '3': 1, '4': 1, '5': 3, '10': 'offsetMs'},
    {'1': 'change_ms', '3': 2, '4': 1, '5': 18, '10': 'changeMs'},
    {'1': 'error_ms', '3': 3, '4': 1, '5': 18, '10': 'errorMs'},
  ],
};

/// Descriptor for `ResponseTimestampSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseTimestampSetDescriptor = $convert.base64Decode(
    'ChRSZXNwb25zZVRpbWVzdGFtcFNldBIbCglvZmZzZXRfbXMYASABKANSCG9mZnNldE1zEhsKCW'
    'NoYW5nZV9tcxgCIAEoElIIY2hhbmdlTXMSGQoIZXJyb3JfbXMYAyABKBJSB2Vycm9yTXM=');

@$core.Deprecated('Use requestTimestampGetDescriptor instead')
const RequestTimestampGet$json = {
  '1': 'RequestTimestampGet',
};

/// Descriptor for `RequestTimestampGet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestTimestampGetDescriptor =
    $convert.base64Decode('ChNSZXF1ZXN0VGltZXN0YW1wR2V0');

@$core.Deprecated('Use responseTimestampGetDescriptor instead')
const ResponseTimestampGet$json = {
  '1': 'ResponseTimestampGet',
  '2': [
    {'1': 'timestamp_ms', '3': 1, '4': 1, '5': 7, '10': 'timestampMs'},
    {'1': 'unix_timestamp_ms', '3': 2, '4': 1, '5': 4, '10': 'unixTimestampMs'},
  ],
};

/// Descriptor for `ResponseTimestampGet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseTimestampGetDescriptor = $convert.base64Decode(
    'ChRSZXNwb25zZVRpbWVzdGFtcEdldBIhCgx0aW1lc3RhbXBfbXMYASABKAdSC3RpbWVzdGFtcE'
    '1zEioKEXVuaXhfdGltZXN0YW1wX21zGAIgASgEUg91bml4VGltZXN0YW1wTXM=');

@$core.Deprecated('Use requestWifiParametersSetDescriptor instead')
const RequestWifiParametersSet$json = {
  '1': 'RequestWifiParametersSet',
  '2': [
    {'1': 'ssid', '3': 1, '4': 1, '5': 12, '10': 'ssid'},
    {'1': 'password', '3': 2, '4': 1, '5': 12, '10': 'password'},
  ],
};

/// Descriptor for `RequestWifiParametersSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestWifiParametersSetDescriptor =
    $convert.base64Decode(
        'ChhSZXF1ZXN0V2lmaVBhcmFtZXRlcnNTZXQSEgoEc3NpZBgBIAEoDFIEc3NpZBIaCghwYXNzd2'
        '9yZBgCIAEoDFIIcGFzc3dvcmQ=');

@$core.Deprecated('Use responseWifiParametersSetDescriptor instead')
const ResponseWifiParametersSet$json = {
  '1': 'ResponseWifiParametersSet',
};

/// Descriptor for `ResponseWifiParametersSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseWifiParametersSetDescriptor =
    $convert.base64Decode('ChlSZXNwb25zZVdpZmlQYXJhbWV0ZXJzU2V0');

@$core.Deprecated('Use requestWifiIPGetDescriptor instead')
const RequestWifiIPGet$json = {
  '1': 'RequestWifiIPGet',
};

/// Descriptor for `RequestWifiIPGet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestWifiIPGetDescriptor =
    $convert.base64Decode('ChBSZXF1ZXN0V2lmaUlQR2V0');

@$core.Deprecated('Use responseWifiIPGetDescriptor instead')
const ResponseWifiIPGet$json = {
  '1': 'ResponseWifiIPGet',
  '2': [
    {'1': 'ip', '3': 1, '4': 1, '5': 13, '10': 'ip'},
  ],
};

/// Descriptor for `ResponseWifiIPGet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseWifiIPGetDescriptor =
    $convert.base64Decode('ChFSZXNwb25zZVdpZmlJUEdldBIOCgJpcBgBIAEoDVICaXA=');

@$core.Deprecated('Use requestLSM6DSOXStartDescriptor instead')
const RequestLSM6DSOXStart$json = {
  '1': 'RequestLSM6DSOXStart',
  '2': [
    {'1': 'imu_samplerate', '3': 1, '4': 1, '5': 2, '10': 'imuSamplerate'},
    {'1': 'acc_fullscale', '3': 2, '4': 1, '5': 2, '10': 'accFullscale'},
    {'1': 'gyr_fullscale', '3': 3, '4': 1, '5': 2, '10': 'gyrFullscale'},
  ],
};

/// Descriptor for `RequestLSM6DSOXStart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestLSM6DSOXStartDescriptor = $convert.base64Decode(
    'ChRSZXF1ZXN0TFNNNkRTT1hTdGFydBIlCg5pbXVfc2FtcGxlcmF0ZRgBIAEoAlINaW11U2FtcG'
    'xlcmF0ZRIjCg1hY2NfZnVsbHNjYWxlGAIgASgCUgxhY2NGdWxsc2NhbGUSIwoNZ3lyX2Z1bGxz'
    'Y2FsZRgDIAEoAlIMZ3lyRnVsbHNjYWxl');

@$core.Deprecated('Use responseLSM6DSOXStartDescriptor instead')
const ResponseLSM6DSOXStart$json = {
  '1': 'ResponseLSM6DSOXStart',
  '2': [
    {'1': 'acc_sensitivity', '3': 1, '4': 1, '5': 2, '10': 'accSensitivity'},
    {'1': 'gyr_sensitivity', '3': 2, '4': 1, '5': 2, '10': 'gyrSensitivity'},
  ],
};

/// Descriptor for `ResponseLSM6DSOXStart`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseLSM6DSOXStartDescriptor = $convert.base64Decode(
    'ChVSZXNwb25zZUxTTTZEU09YU3RhcnQSJwoPYWNjX3NlbnNpdGl2aXR5GAEgASgCUg5hY2NTZW'
    '5zaXRpdml0eRInCg9neXJfc2Vuc2l0aXZpdHkYAiABKAJSDmd5clNlbnNpdGl2aXR5');

@$core.Deprecated('Use requestLSM6DSOXStopDescriptor instead')
const RequestLSM6DSOXStop$json = {
  '1': 'RequestLSM6DSOXStop',
};

/// Descriptor for `RequestLSM6DSOXStop`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestLSM6DSOXStopDescriptor =
    $convert.base64Decode('ChNSZXF1ZXN0TFNNNkRTT1hTdG9w');

@$core.Deprecated('Use responseLSM6DSOXStopDescriptor instead')
const ResponseLSM6DSOXStop$json = {
  '1': 'ResponseLSM6DSOXStop',
};

/// Descriptor for `ResponseLSM6DSOXStop`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseLSM6DSOXStopDescriptor =
    $convert.base64Decode('ChRSZXNwb25zZUxTTTZEU09YU3RvcA==');

@$core.Deprecated('Use deviceStateDescriptor instead')
const DeviceState$json = {
  '1': 'DeviceState',
  '2': [
    {'1': 'pot_locked', '3': 1, '4': 1, '5': 8, '10': 'potLocked'},
  ],
};

/// Descriptor for `DeviceState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceStateDescriptor = $convert.base64Decode(
    'CgtEZXZpY2VTdGF0ZRIdCgpwb3RfbG9ja2VkGAEgASgIUglwb3RMb2NrZWQ=');

@$core.Deprecated('Use requestSetDeviceStateDescriptor instead')
const RequestSetDeviceState$json = {
  '1': 'RequestSetDeviceState',
  '2': [
    {
      '1': 'state',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.DeviceState',
      '10': 'state'
    },
  ],
};

/// Descriptor for `RequestSetDeviceState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestSetDeviceStateDescriptor = $convert.base64Decode(
    'ChVSZXF1ZXN0U2V0RGV2aWNlU3RhdGUSLgoFc3RhdGUYASABKAsyGC5mb2NzdGltX3JwYy5EZX'
    'ZpY2VTdGF0ZVIFc3RhdGU=');

@$core.Deprecated('Use responseSetDeviceStateDescriptor instead')
const ResponseSetDeviceState$json = {
  '1': 'ResponseSetDeviceState',
};

/// Descriptor for `ResponseSetDeviceState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseSetDeviceStateDescriptor =
    $convert.base64Decode('ChZSZXNwb25zZVNldERldmljZVN0YXRl');

@$core.Deprecated('Use requestDebugStm32DeepSleepDescriptor instead')
const RequestDebugStm32DeepSleep$json = {
  '1': 'RequestDebugStm32DeepSleep',
};

/// Descriptor for `RequestDebugStm32DeepSleep`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestDebugStm32DeepSleepDescriptor =
    $convert.base64Decode('ChpSZXF1ZXN0RGVidWdTdG0zMkRlZXBTbGVlcA==');

@$core.Deprecated('Use responseDebugStm32DeepSleepDescriptor instead')
const ResponseDebugStm32DeepSleep$json = {
  '1': 'ResponseDebugStm32DeepSleep',
};

/// Descriptor for `ResponseDebugStm32DeepSleep`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseDebugStm32DeepSleepDescriptor =
    $convert.base64Decode('ChtSZXNwb25zZURlYnVnU3RtMzJEZWVwU2xlZXA=');

@$core.Deprecated('Use requestDebugEnterBootloaderDescriptor instead')
const RequestDebugEnterBootloader$json = {
  '1': 'RequestDebugEnterBootloader',
};

/// Descriptor for `RequestDebugEnterBootloader`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestDebugEnterBootloaderDescriptor =
    $convert.base64Decode('ChtSZXF1ZXN0RGVidWdFbnRlckJvb3Rsb2FkZXI=');
