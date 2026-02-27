// This is a generated file - do not edit.
//
// Generated from notifications.proto.

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

@$core.Deprecated('Use buttonStateDescriptor instead')
const ButtonState$json = {
  '1': 'ButtonState',
  '2': [
    {'1': 'BUTTON_UP', '2': 0},
    {'1': 'BUTTON_DOWN', '2': 1},
  ],
};

/// Descriptor for `ButtonState`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List buttonStateDescriptor = $convert.base64Decode(
    'CgtCdXR0b25TdGF0ZRINCglCVVRUT05fVVAQABIPCgtCVVRUT05fRE9XThAB');

@$core.Deprecated('Use notificationBootDescriptor instead')
const NotificationBoot$json = {
  '1': 'NotificationBoot',
};

/// Descriptor for `NotificationBoot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationBootDescriptor =
    $convert.base64Decode('ChBOb3RpZmljYXRpb25Cb290');

@$core.Deprecated('Use notificationPotentiometerDescriptor instead')
const NotificationPotentiometer$json = {
  '1': 'NotificationPotentiometer',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 2, '10': 'value'},
  ],
};

/// Descriptor for `NotificationPotentiometer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationPotentiometerDescriptor =
    $convert.base64Decode(
        'ChlOb3RpZmljYXRpb25Qb3RlbnRpb21ldGVyEhQKBXZhbHVlGAEgASgCUgV2YWx1ZQ==');

@$core.Deprecated('Use notificationButtonPressDescriptor instead')
const NotificationButtonPress$json = {
  '1': 'NotificationButtonPress',
  '2': [
    {
      '1': 'state',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.focstim_rpc.ButtonState',
      '10': 'state'
    },
    {'1': 'timestamp_ms', '3': 2, '4': 1, '5': 13, '10': 'timestampMs'},
  ],
};

/// Descriptor for `NotificationButtonPress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationButtonPressDescriptor = $convert.base64Decode(
    'ChdOb3RpZmljYXRpb25CdXR0b25QcmVzcxIuCgVzdGF0ZRgBIAEoDjIYLmZvY3N0aW1fcnBjLk'
    'J1dHRvblN0YXRlUgVzdGF0ZRIhCgx0aW1lc3RhbXBfbXMYAiABKA1SC3RpbWVzdGFtcE1z');

@$core.Deprecated('Use notificationDeviceStateDescriptor instead')
const NotificationDeviceState$json = {
  '1': 'NotificationDeviceState',
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

/// Descriptor for `NotificationDeviceState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDeviceStateDescriptor =
    $convert.base64Decode(
        'ChdOb3RpZmljYXRpb25EZXZpY2VTdGF0ZRIuCgVzdGF0ZRgBIAEoCzIYLmZvY3N0aW1fcnBjLk'
        'RldmljZVN0YXRlUgVzdGF0ZQ==');

@$core.Deprecated('Use notificationCurrentsDescriptor instead')
const NotificationCurrents$json = {
  '1': 'NotificationCurrents',
  '2': [
    {'1': 'rms_a', '3': 1, '4': 1, '5': 2, '10': 'rmsA'},
    {'1': 'rms_b', '3': 2, '4': 1, '5': 2, '10': 'rmsB'},
    {'1': 'rms_c', '3': 3, '4': 1, '5': 2, '10': 'rmsC'},
    {'1': 'rms_d', '3': 4, '4': 1, '5': 2, '10': 'rmsD'},
    {'1': 'peak_a', '3': 5, '4': 1, '5': 2, '10': 'peakA'},
    {'1': 'peak_b', '3': 6, '4': 1, '5': 2, '10': 'peakB'},
    {'1': 'peak_c', '3': 7, '4': 1, '5': 2, '10': 'peakC'},
    {'1': 'peak_d', '3': 8, '4': 1, '5': 2, '10': 'peakD'},
    {'1': 'output_power', '3': 9, '4': 1, '5': 2, '10': 'outputPower'},
    {
      '1': 'output_power_skin',
      '3': 10,
      '4': 1,
      '5': 2,
      '10': 'outputPowerSkin'
    },
    {'1': 'peak_cmd', '3': 11, '4': 1, '5': 2, '10': 'peakCmd'},
  ],
};

/// Descriptor for `NotificationCurrents`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationCurrentsDescriptor = $convert.base64Decode(
    'ChROb3RpZmljYXRpb25DdXJyZW50cxITCgVybXNfYRgBIAEoAlIEcm1zQRITCgVybXNfYhgCIA'
    'EoAlIEcm1zQhITCgVybXNfYxgDIAEoAlIEcm1zQxITCgVybXNfZBgEIAEoAlIEcm1zRBIVCgZw'
    'ZWFrX2EYBSABKAJSBXBlYWtBEhUKBnBlYWtfYhgGIAEoAlIFcGVha0ISFQoGcGVha19jGAcgAS'
    'gCUgVwZWFrQxIVCgZwZWFrX2QYCCABKAJSBXBlYWtEEiEKDG91dHB1dF9wb3dlchgJIAEoAlIL'
    'b3V0cHV0UG93ZXISKgoRb3V0cHV0X3Bvd2VyX3NraW4YCiABKAJSD291dHB1dFBvd2VyU2tpbh'
    'IZCghwZWFrX2NtZBgLIAEoAlIHcGVha0NtZA==');

@$core.Deprecated('Use notificationModelEstimationDescriptor instead')
const NotificationModelEstimation$json = {
  '1': 'NotificationModelEstimation',
  '2': [
    {'1': 'resistance_a', '3': 1, '4': 1, '5': 2, '10': 'resistanceA'},
    {'1': 'reluctance_a', '3': 2, '4': 1, '5': 2, '10': 'reluctanceA'},
    {'1': 'resistance_b', '3': 3, '4': 1, '5': 2, '10': 'resistanceB'},
    {'1': 'reluctance_b', '3': 4, '4': 1, '5': 2, '10': 'reluctanceB'},
    {'1': 'resistance_c', '3': 5, '4': 1, '5': 2, '10': 'resistanceC'},
    {'1': 'reluctance_c', '3': 6, '4': 1, '5': 2, '10': 'reluctanceC'},
    {'1': 'resistance_d', '3': 7, '4': 1, '5': 2, '10': 'resistanceD'},
    {'1': 'reluctance_d', '3': 8, '4': 1, '5': 2, '10': 'reluctanceD'},
    {'1': 'constant', '3': 20, '4': 1, '5': 2, '10': 'constant'},
  ],
};

/// Descriptor for `NotificationModelEstimation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationModelEstimationDescriptor = $convert.base64Decode(
    'ChtOb3RpZmljYXRpb25Nb2RlbEVzdGltYXRpb24SIQoMcmVzaXN0YW5jZV9hGAEgASgCUgtyZX'
    'Npc3RhbmNlQRIhCgxyZWx1Y3RhbmNlX2EYAiABKAJSC3JlbHVjdGFuY2VBEiEKDHJlc2lzdGFu'
    'Y2VfYhgDIAEoAlILcmVzaXN0YW5jZUISIQoMcmVsdWN0YW5jZV9iGAQgASgCUgtyZWx1Y3Rhbm'
    'NlQhIhCgxyZXNpc3RhbmNlX2MYBSABKAJSC3Jlc2lzdGFuY2VDEiEKDHJlbHVjdGFuY2VfYxgG'
    'IAEoAlILcmVsdWN0YW5jZUMSIQoMcmVzaXN0YW5jZV9kGAcgASgCUgtyZXNpc3RhbmNlRBIhCg'
    'xyZWx1Y3RhbmNlX2QYCCABKAJSC3JlbHVjdGFuY2VEEhoKCGNvbnN0YW50GBQgASgCUghjb25z'
    'dGFudA==');

@$core.Deprecated('Use systemStatsESC1Descriptor instead')
const SystemStatsESC1$json = {
  '1': 'SystemStatsESC1',
  '2': [
    {'1': 'temp_stm32', '3': 1, '4': 1, '5': 2, '10': 'tempStm32'},
    {'1': 'temp_board', '3': 2, '4': 1, '5': 2, '10': 'tempBoard'},
    {'1': 'v_bus', '3': 3, '4': 1, '5': 2, '10': 'vBus'},
    {'1': 'v_ref', '3': 4, '4': 1, '5': 2, '10': 'vRef'},
  ],
};

/// Descriptor for `SystemStatsESC1`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemStatsESC1Descriptor = $convert.base64Decode(
    'Cg9TeXN0ZW1TdGF0c0VTQzESHQoKdGVtcF9zdG0zMhgBIAEoAlIJdGVtcFN0bTMyEh0KCnRlbX'
    'BfYm9hcmQYAiABKAJSCXRlbXBCb2FyZBITCgV2X2J1cxgDIAEoAlIEdkJ1cxITCgV2X3JlZhgE'
    'IAEoAlIEdlJlZg==');

@$core.Deprecated('Use systemStatsFocstimV3Descriptor instead')
const SystemStatsFocstimV3$json = {
  '1': 'SystemStatsFocstimV3',
  '2': [
    {'1': 'temp_stm32', '3': 1, '4': 1, '5': 2, '10': 'tempStm32'},
    {'1': 'v_sys_min', '3': 2, '4': 1, '5': 2, '10': 'vSysMin'},
    {'1': 'v_sys_max', '3': 6, '4': 1, '5': 2, '10': 'vSysMax'},
    {'1': 'v_ref', '3': 3, '4': 1, '5': 2, '10': 'vRef'},
    {'1': 'v_boost_min', '3': 4, '4': 1, '5': 2, '10': 'vBoostMin'},
    {'1': 'v_boost_max', '3': 7, '4': 1, '5': 2, '10': 'vBoostMax'},
    {'1': 'boost_duty_cycle', '3': 5, '4': 1, '5': 2, '10': 'boostDutyCycle'},
  ],
};

/// Descriptor for `SystemStatsFocstimV3`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemStatsFocstimV3Descriptor = $convert.base64Decode(
    'ChRTeXN0ZW1TdGF0c0ZvY3N0aW1WMxIdCgp0ZW1wX3N0bTMyGAEgASgCUgl0ZW1wU3RtMzISGg'
    'oJdl9zeXNfbWluGAIgASgCUgd2U3lzTWluEhoKCXZfc3lzX21heBgGIAEoAlIHdlN5c01heBIT'
    'CgV2X3JlZhgDIAEoAlIEdlJlZhIeCgt2X2Jvb3N0X21pbhgEIAEoAlIJdkJvb3N0TWluEh4KC3'
    'ZfYm9vc3RfbWF4GAcgASgCUgl2Qm9vc3RNYXgSKAoQYm9vc3RfZHV0eV9jeWNsZRgFIAEoAlIO'
    'Ym9vc3REdXR5Q3ljbGU=');

@$core.Deprecated('Use notificationSystemStatsDescriptor instead')
const NotificationSystemStats$json = {
  '1': 'NotificationSystemStats',
  '2': [
    {
      '1': 'esc1',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.SystemStatsESC1',
      '9': 0,
      '10': 'esc1'
    },
    {
      '1': 'focstimv3',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.SystemStatsFocstimV3',
      '9': 0,
      '10': 'focstimv3'
    },
  ],
  '8': [
    {'1': 'system'},
  ],
};

/// Descriptor for `NotificationSystemStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationSystemStatsDescriptor = $convert.base64Decode(
    'ChdOb3RpZmljYXRpb25TeXN0ZW1TdGF0cxIyCgRlc2MxGAEgASgLMhwuZm9jc3RpbV9ycGMuU3'
    'lzdGVtU3RhdHNFU0MxSABSBGVzYzESQQoJZm9jc3RpbXYzGAIgASgLMiEuZm9jc3RpbV9ycGMu'
    'U3lzdGVtU3RhdHNGb2NzdGltVjNIAFIJZm9jc3RpbXYzQggKBnN5c3RlbQ==');

@$core.Deprecated('Use notificationSignalStatsDescriptor instead')
const NotificationSignalStats$json = {
  '1': 'NotificationSignalStats',
  '2': [
    {
      '1': 'actual_pulse_frequency',
      '3': 1,
      '4': 1,
      '5': 2,
      '10': 'actualPulseFrequency'
    },
    {'1': 'v_drive', '3': 2, '4': 1, '5': 2, '10': 'vDrive'},
  ],
};

/// Descriptor for `NotificationSignalStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationSignalStatsDescriptor =
    $convert.base64Decode(
        'ChdOb3RpZmljYXRpb25TaWduYWxTdGF0cxI0ChZhY3R1YWxfcHVsc2VfZnJlcXVlbmN5GAEgAS'
        'gCUhRhY3R1YWxQdWxzZUZyZXF1ZW5jeRIXCgd2X2RyaXZlGAIgASgCUgZ2RHJpdmU=');

@$core.Deprecated('Use notificationBatteryDescriptor instead')
const NotificationBattery$json = {
  '1': 'NotificationBattery',
  '2': [
    {'1': 'battery_voltage', '3': 1, '4': 1, '5': 2, '10': 'batteryVoltage'},
    {
      '1': 'battery_charge_rate_watt',
      '3': 2,
      '4': 1,
      '5': 2,
      '10': 'batteryChargeRateWatt'
    },
    {'1': 'battery_soc', '3': 3, '4': 1, '5': 2, '10': 'batterySoc'},
    {
      '1': 'wall_power_present',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'wallPowerPresent'
    },
    {'1': 'chip_temperature', '3': 5, '4': 1, '5': 2, '10': 'chipTemperature'},
  ],
};

/// Descriptor for `NotificationBattery`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationBatteryDescriptor = $convert.base64Decode(
    'ChNOb3RpZmljYXRpb25CYXR0ZXJ5EicKD2JhdHRlcnlfdm9sdGFnZRgBIAEoAlIOYmF0dGVyeV'
    'ZvbHRhZ2USNwoYYmF0dGVyeV9jaGFyZ2VfcmF0ZV93YXR0GAIgASgCUhViYXR0ZXJ5Q2hhcmdl'
    'UmF0ZVdhdHQSHwoLYmF0dGVyeV9zb2MYAyABKAJSCmJhdHRlcnlTb2MSLAoSd2FsbF9wb3dlcl'
    '9wcmVzZW50GAQgASgIUhB3YWxsUG93ZXJQcmVzZW50EikKEGNoaXBfdGVtcGVyYXR1cmUYBSAB'
    'KAJSD2NoaXBUZW1wZXJhdHVyZQ==');

@$core.Deprecated('Use notificationLSM6DSOXDescriptor instead')
const NotificationLSM6DSOX$json = {
  '1': 'NotificationLSM6DSOX',
  '2': [
    {'1': 'acc_x', '3': 1, '4': 1, '5': 17, '10': 'accX'},
    {'1': 'acc_y', '3': 2, '4': 1, '5': 17, '10': 'accY'},
    {'1': 'acc_z', '3': 3, '4': 1, '5': 17, '10': 'accZ'},
    {'1': 'gyr_x', '3': 4, '4': 1, '5': 17, '10': 'gyrX'},
    {'1': 'gyr_y', '3': 5, '4': 1, '5': 17, '10': 'gyrY'},
    {'1': 'gyr_z', '3': 6, '4': 1, '5': 17, '10': 'gyrZ'},
  ],
};

/// Descriptor for `NotificationLSM6DSOX`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationLSM6DSOXDescriptor = $convert.base64Decode(
    'ChROb3RpZmljYXRpb25MU002RFNPWBITCgVhY2NfeBgBIAEoEVIEYWNjWBITCgVhY2NfeRgCIA'
    'EoEVIEYWNjWRITCgVhY2NfehgDIAEoEVIEYWNjWhITCgVneXJfeBgEIAEoEVIEZ3lyWBITCgVn'
    'eXJfeRgFIAEoEVIEZ3lyWRITCgVneXJfehgGIAEoEVIEZ3lyWg==');

@$core.Deprecated('Use notificationPressureDescriptor instead')
const NotificationPressure$json = {
  '1': 'NotificationPressure',
  '2': [
    {'1': 'pressure', '3': 1, '4': 1, '5': 2, '10': 'pressure'},
  ],
};

/// Descriptor for `NotificationPressure`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationPressureDescriptor =
    $convert.base64Decode(
        'ChROb3RpZmljYXRpb25QcmVzc3VyZRIaCghwcmVzc3VyZRgBIAEoAlIIcHJlc3N1cmU=');

@$core.Deprecated('Use notificationDebugStringDescriptor instead')
const NotificationDebugString$json = {
  '1': 'NotificationDebugString',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `NotificationDebugString`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDebugStringDescriptor =
    $convert.base64Decode(
        'ChdOb3RpZmljYXRpb25EZWJ1Z1N0cmluZxIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use notificationDebugAS5311Descriptor instead')
const NotificationDebugAS5311$json = {
  '1': 'NotificationDebugAS5311',
  '2': [
    {'1': 'raw', '3': 1, '4': 1, '5': 5, '10': 'raw'},
    {'1': 'tracked', '3': 2, '4': 1, '5': 17, '10': 'tracked'},
    {'1': 'flags', '3': 3, '4': 1, '5': 5, '10': 'flags'},
  ],
};

/// Descriptor for `NotificationDebugAS5311`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDebugAS5311Descriptor =
    $convert.base64Decode(
        'ChdOb3RpZmljYXRpb25EZWJ1Z0FTNTMxMRIQCgNyYXcYASABKAVSA3JhdxIYCgd0cmFja2VkGA'
        'IgASgRUgd0cmFja2VkEhQKBWZsYWdzGAMgASgFUgVmbGFncw==');

@$core.Deprecated('Use notificationDebugEdgingDescriptor instead')
const NotificationDebugEdging$json = {
  '1': 'NotificationDebugEdging',
  '2': [
    {
      '1': 'full_power_threshold',
      '3': 1,
      '4': 1,
      '5': 2,
      '10': 'fullPowerThreshold'
    },
    {
      '1': 'reduced_power_threshold',
      '3': 2,
      '4': 1,
      '5': 2,
      '10': 'reducedPowerThreshold'
    },
    {'1': 'reduction', '3': 3, '4': 1, '5': 2, '10': 'reduction'},
  ],
};

/// Descriptor for `NotificationDebugEdging`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDebugEdgingDescriptor = $convert.base64Decode(
    'ChdOb3RpZmljYXRpb25EZWJ1Z0VkZ2luZxIwChRmdWxsX3Bvd2VyX3RocmVzaG9sZBgBIAEoAl'
    'ISZnVsbFBvd2VyVGhyZXNob2xkEjYKF3JlZHVjZWRfcG93ZXJfdGhyZXNob2xkGAIgASgCUhVy'
    'ZWR1Y2VkUG93ZXJUaHJlc2hvbGQSHAoJcmVkdWN0aW9uGAMgASgCUglyZWR1Y3Rpb24=');

@$core.Deprecated('Use notificationDebugTeleplotDescriptor instead')
const NotificationDebugTeleplot$json = {
  '1': 'NotificationDebugTeleplot',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'value', '3': 2, '4': 1, '5': 2, '10': 'value'},
  ],
};

/// Descriptor for `NotificationDebugTeleplot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDebugTeleplotDescriptor =
    $convert.base64Decode(
        'ChlOb3RpZmljYXRpb25EZWJ1Z1RlbGVwbG90Eg4KAmlkGAEgASgJUgJpZBIUCgV2YWx1ZRgCIA'
        'EoAlIFdmFsdWU=');
