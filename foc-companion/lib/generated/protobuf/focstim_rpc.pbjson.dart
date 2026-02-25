// This is a generated file - do not edit.
//
// Generated from focstim_rpc.proto.

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

@$core.Deprecated('Use notificationDescriptor instead')
const Notification$json = {
  '1': 'Notification',
  '2': [
    {
      '1': 'notification_boot',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationBoot',
      '9': 0,
      '10': 'notificationBoot'
    },
    {
      '1': 'notification_potentiometer',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationPotentiometer',
      '9': 0,
      '10': 'notificationPotentiometer'
    },
    {
      '1': 'notification_currents',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationCurrents',
      '9': 0,
      '10': 'notificationCurrents'
    },
    {
      '1': 'notification_model_estimation',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationModelEstimation',
      '9': 0,
      '10': 'notificationModelEstimation'
    },
    {
      '1': 'notification_system_stats',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationSystemStats',
      '9': 0,
      '10': 'notificationSystemStats'
    },
    {
      '1': 'notification_signal_stats',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationSignalStats',
      '9': 0,
      '10': 'notificationSignalStats'
    },
    {
      '1': 'notification_battery',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationBattery',
      '9': 0,
      '10': 'notificationBattery'
    },
    {
      '1': 'notification_lsm6dsox',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationLSM6DSOX',
      '9': 0,
      '10': 'notificationLsm6dsox'
    },
    {
      '1': 'notification_pressure',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationPressure',
      '9': 0,
      '10': 'notificationPressure'
    },
    {
      '1': 'notification_button_press',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationButtonPress',
      '9': 0,
      '10': 'notificationButtonPress'
    },
    {
      '1': 'notification_debug_string',
      '3': 1000,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationDebugString',
      '9': 0,
      '10': 'notificationDebugString'
    },
    {
      '1': 'notification_debug_as5311',
      '3': 1001,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationDebugAS5311',
      '9': 0,
      '10': 'notificationDebugAs5311'
    },
    {
      '1': 'notification_debug_edging',
      '3': 1002,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.NotificationDebugEdging',
      '9': 0,
      '10': 'notificationDebugEdging'
    },
    {'1': 'timestamp', '3': 999, '4': 1, '5': 4, '10': 'timestamp'},
  ],
  '8': [
    {'1': 'notification'},
  ],
};

/// Descriptor for `Notification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDescriptor = $convert.base64Decode(
    'CgxOb3RpZmljYXRpb24STAoRbm90aWZpY2F0aW9uX2Jvb3QYASABKAsyHS5mb2NzdGltX3JwYy'
    '5Ob3RpZmljYXRpb25Cb290SABSEG5vdGlmaWNhdGlvbkJvb3QSZwoabm90aWZpY2F0aW9uX3Bv'
    'dGVudGlvbWV0ZXIYAiABKAsyJi5mb2NzdGltX3JwYy5Ob3RpZmljYXRpb25Qb3RlbnRpb21ldG'
    'VySABSGW5vdGlmaWNhdGlvblBvdGVudGlvbWV0ZXISWAoVbm90aWZpY2F0aW9uX2N1cnJlbnRz'
    'GAMgASgLMiEuZm9jc3RpbV9ycGMuTm90aWZpY2F0aW9uQ3VycmVudHNIAFIUbm90aWZpY2F0aW'
    '9uQ3VycmVudHMSbgodbm90aWZpY2F0aW9uX21vZGVsX2VzdGltYXRpb24YBCABKAsyKC5mb2Nz'
    'dGltX3JwYy5Ob3RpZmljYXRpb25Nb2RlbEVzdGltYXRpb25IAFIbbm90aWZpY2F0aW9uTW9kZW'
    'xFc3RpbWF0aW9uEmIKGW5vdGlmaWNhdGlvbl9zeXN0ZW1fc3RhdHMYBSABKAsyJC5mb2NzdGlt'
    'X3JwYy5Ob3RpZmljYXRpb25TeXN0ZW1TdGF0c0gAUhdub3RpZmljYXRpb25TeXN0ZW1TdGF0cx'
    'JiChlub3RpZmljYXRpb25fc2lnbmFsX3N0YXRzGAYgASgLMiQuZm9jc3RpbV9ycGMuTm90aWZp'
    'Y2F0aW9uU2lnbmFsU3RhdHNIAFIXbm90aWZpY2F0aW9uU2lnbmFsU3RhdHMSVQoUbm90aWZpY2'
    'F0aW9uX2JhdHRlcnkYByABKAsyIC5mb2NzdGltX3JwYy5Ob3RpZmljYXRpb25CYXR0ZXJ5SABS'
    'E25vdGlmaWNhdGlvbkJhdHRlcnkSWAoVbm90aWZpY2F0aW9uX2xzbTZkc294GAggASgLMiEuZm'
    '9jc3RpbV9ycGMuTm90aWZpY2F0aW9uTFNNNkRTT1hIAFIUbm90aWZpY2F0aW9uTHNtNmRzb3gS'
    'WAoVbm90aWZpY2F0aW9uX3ByZXNzdXJlGAkgASgLMiEuZm9jc3RpbV9ycGMuTm90aWZpY2F0aW'
    '9uUHJlc3N1cmVIAFIUbm90aWZpY2F0aW9uUHJlc3N1cmUSYgoZbm90aWZpY2F0aW9uX2J1dHRv'
    'bl9wcmVzcxgKIAEoCzIkLmZvY3N0aW1fcnBjLk5vdGlmaWNhdGlvbkJ1dHRvblByZXNzSABSF2'
    '5vdGlmaWNhdGlvbkJ1dHRvblByZXNzEmMKGW5vdGlmaWNhdGlvbl9kZWJ1Z19zdHJpbmcY6Acg'
    'ASgLMiQuZm9jc3RpbV9ycGMuTm90aWZpY2F0aW9uRGVidWdTdHJpbmdIAFIXbm90aWZpY2F0aW'
    '9uRGVidWdTdHJpbmcSYwoZbm90aWZpY2F0aW9uX2RlYnVnX2FzNTMxMRjpByABKAsyJC5mb2Nz'
    'dGltX3JwYy5Ob3RpZmljYXRpb25EZWJ1Z0FTNTMxMUgAUhdub3RpZmljYXRpb25EZWJ1Z0FzNT'
    'MxMRJjChlub3RpZmljYXRpb25fZGVidWdfZWRnaW5nGOoHIAEoCzIkLmZvY3N0aW1fcnBjLk5v'
    'dGlmaWNhdGlvbkRlYnVnRWRnaW5nSABSF25vdGlmaWNhdGlvbkRlYnVnRWRnaW5nEh0KCXRpbW'
    'VzdGFtcBjnByABKARSCXRpbWVzdGFtcEIOCgxub3RpZmljYXRpb24=');

@$core.Deprecated('Use requestDescriptor instead')
const Request$json = {
  '1': 'Request',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {
      '1': 'request_firmware_version',
      '3': 500,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestFirmwareVersion',
      '9': 0,
      '10': 'requestFirmwareVersion'
    },
    {
      '1': 'request_capabilities_get',
      '3': 501,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestCapabilitiesGet',
      '9': 0,
      '10': 'requestCapabilitiesGet'
    },
    {
      '1': 'request_signal_start',
      '3': 502,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestSignalStart',
      '9': 0,
      '10': 'requestSignalStart'
    },
    {
      '1': 'request_signal_stop',
      '3': 503,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestSignalStop',
      '9': 0,
      '10': 'requestSignalStop'
    },
    {
      '1': 'request_axis_move_to',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestAxisMoveTo',
      '9': 0,
      '10': 'requestAxisMoveTo'
    },
    {
      '1': 'request_timestamp_set',
      '3': 504,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestTimestampSet',
      '9': 0,
      '10': 'requestTimestampSet'
    },
    {
      '1': 'request_timestamp_get',
      '3': 505,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestTimestampGet',
      '9': 0,
      '10': 'requestTimestampGet'
    },
    {
      '1': 'request_wifi_parameters_set',
      '3': 507,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestWifiParametersSet',
      '9': 0,
      '10': 'requestWifiParametersSet'
    },
    {
      '1': 'request_wifi_ip_get',
      '3': 508,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestWifiIPGet',
      '9': 0,
      '10': 'requestWifiIpGet'
    },
    {
      '1': 'request_lsm6dsox_start',
      '3': 600,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestLSM6DSOXStart',
      '9': 0,
      '10': 'requestLsm6dsoxStart'
    },
    {
      '1': 'request_lsm6dsox_stop',
      '3': 601,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestLSM6DSOXStop',
      '9': 0,
      '10': 'requestLsm6dsoxStop'
    },
    {
      '1': 'request_debug_stm32_deep_sleep',
      '3': 1000,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestDebugStm32DeepSleep',
      '9': 0,
      '10': 'requestDebugStm32DeepSleep'
    },
    {
      '1': 'request_debug_enter_bootloader',
      '3': 1001,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.RequestDebugEnterBootloader',
      '9': 0,
      '10': 'requestDebugEnterBootloader'
    },
  ],
  '8': [
    {'1': 'params'},
  ],
};

/// Descriptor for `Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestDescriptor = $convert.base64Decode(
    'CgdSZXF1ZXN0Eg4KAmlkGAEgASgNUgJpZBJgChhyZXF1ZXN0X2Zpcm13YXJlX3ZlcnNpb24Y9A'
    'MgASgLMiMuZm9jc3RpbV9ycGMuUmVxdWVzdEZpcm13YXJlVmVyc2lvbkgAUhZyZXF1ZXN0Rmly'
    'bXdhcmVWZXJzaW9uEmAKGHJlcXVlc3RfY2FwYWJpbGl0aWVzX2dldBj1AyABKAsyIy5mb2NzdG'
    'ltX3JwYy5SZXF1ZXN0Q2FwYWJpbGl0aWVzR2V0SABSFnJlcXVlc3RDYXBhYmlsaXRpZXNHZXQS'
    'VAoUcmVxdWVzdF9zaWduYWxfc3RhcnQY9gMgASgLMh8uZm9jc3RpbV9ycGMuUmVxdWVzdFNpZ2'
    '5hbFN0YXJ0SABSEnJlcXVlc3RTaWduYWxTdGFydBJRChNyZXF1ZXN0X3NpZ25hbF9zdG9wGPcD'
    'IAEoCzIeLmZvY3N0aW1fcnBjLlJlcXVlc3RTaWduYWxTdG9wSABSEXJlcXVlc3RTaWduYWxTdG'
    '9wElEKFHJlcXVlc3RfYXhpc19tb3ZlX3RvGAUgASgLMh4uZm9jc3RpbV9ycGMuUmVxdWVzdEF4'
    'aXNNb3ZlVG9IAFIRcmVxdWVzdEF4aXNNb3ZlVG8SVwoVcmVxdWVzdF90aW1lc3RhbXBfc2V0GP'
    'gDIAEoCzIgLmZvY3N0aW1fcnBjLlJlcXVlc3RUaW1lc3RhbXBTZXRIAFITcmVxdWVzdFRpbWVz'
    'dGFtcFNldBJXChVyZXF1ZXN0X3RpbWVzdGFtcF9nZXQY+QMgASgLMiAuZm9jc3RpbV9ycGMuUm'
    'VxdWVzdFRpbWVzdGFtcEdldEgAUhNyZXF1ZXN0VGltZXN0YW1wR2V0EmcKG3JlcXVlc3Rfd2lm'
    'aV9wYXJhbWV0ZXJzX3NldBj7AyABKAsyJS5mb2NzdGltX3JwYy5SZXF1ZXN0V2lmaVBhcmFtZX'
    'RlcnNTZXRIAFIYcmVxdWVzdFdpZmlQYXJhbWV0ZXJzU2V0Ek8KE3JlcXVlc3Rfd2lmaV9pcF9n'
    'ZXQY/AMgASgLMh0uZm9jc3RpbV9ycGMuUmVxdWVzdFdpZmlJUEdldEgAUhByZXF1ZXN0V2lmaU'
    'lwR2V0EloKFnJlcXVlc3RfbHNtNmRzb3hfc3RhcnQY2AQgASgLMiEuZm9jc3RpbV9ycGMuUmVx'
    'dWVzdExTTTZEU09YU3RhcnRIAFIUcmVxdWVzdExzbTZkc294U3RhcnQSVwoVcmVxdWVzdF9sc2'
    '02ZHNveF9zdG9wGNkEIAEoCzIgLmZvY3N0aW1fcnBjLlJlcXVlc3RMU002RFNPWFN0b3BIAFIT'
    'cmVxdWVzdExzbTZkc294U3RvcBJuCh5yZXF1ZXN0X2RlYnVnX3N0bTMyX2RlZXBfc2xlZXAY6A'
    'cgASgLMicuZm9jc3RpbV9ycGMuUmVxdWVzdERlYnVnU3RtMzJEZWVwU2xlZXBIAFIacmVxdWVz'
    'dERlYnVnU3RtMzJEZWVwU2xlZXAScAoecmVxdWVzdF9kZWJ1Z19lbnRlcl9ib290bG9hZGVyGO'
    'kHIAEoCzIoLmZvY3N0aW1fcnBjLlJlcXVlc3REZWJ1Z0VudGVyQm9vdGxvYWRlckgAUhtyZXF1'
    'ZXN0RGVidWdFbnRlckJvb3Rsb2FkZXJCCAoGcGFyYW1z');

@$core.Deprecated('Use responseDescriptor instead')
const Response$json = {
  '1': 'Response',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {
      '1': 'response_firmware_version',
      '3': 500,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseFirmwareVersion',
      '9': 0,
      '10': 'responseFirmwareVersion'
    },
    {
      '1': 'response_capabilities_get',
      '3': 501,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseCapabilitiesGet',
      '9': 0,
      '10': 'responseCapabilitiesGet'
    },
    {
      '1': 'response_signal_start',
      '3': 502,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseSignalStart',
      '9': 0,
      '10': 'responseSignalStart'
    },
    {
      '1': 'response_signal_stop',
      '3': 503,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseSignalStop',
      '9': 0,
      '10': 'responseSignalStop'
    },
    {
      '1': 'response_axis_move_to',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseAxisMoveTo',
      '9': 0,
      '10': 'responseAxisMoveTo'
    },
    {
      '1': 'response_timestamp_set',
      '3': 504,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseTimestampSet',
      '9': 0,
      '10': 'responseTimestampSet'
    },
    {
      '1': 'response_timestamp_get',
      '3': 505,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseTimestampGet',
      '9': 0,
      '10': 'responseTimestampGet'
    },
    {
      '1': 'response_wifi_parameters_set',
      '3': 507,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseWifiParametersSet',
      '9': 0,
      '10': 'responseWifiParametersSet'
    },
    {
      '1': 'response_wifi_ip_get',
      '3': 508,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseWifiIPGet',
      '9': 0,
      '10': 'responseWifiIpGet'
    },
    {
      '1': 'response_lsm6dsox_start',
      '3': 600,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseLSM6DSOXStart',
      '9': 0,
      '10': 'responseLsm6dsoxStart'
    },
    {
      '1': 'response_lsm6dsox_stop',
      '3': 601,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseLSM6DSOXStop',
      '9': 0,
      '10': 'responseLsm6dsoxStop'
    },
    {
      '1': 'response_debug_stm32_deep_sleep',
      '3': 1000,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.ResponseDebugStm32DeepSleep',
      '9': 0,
      '10': 'responseDebugStm32DeepSleep'
    },
    {
      '1': 'error',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.Error',
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseDescriptor = $convert.base64Decode(
    'CghSZXNwb25zZRIOCgJpZBgBIAEoDVICaWQSYwoZcmVzcG9uc2VfZmlybXdhcmVfdmVyc2lvbh'
    'j0AyABKAsyJC5mb2NzdGltX3JwYy5SZXNwb25zZUZpcm13YXJlVmVyc2lvbkgAUhdyZXNwb25z'
    'ZUZpcm13YXJlVmVyc2lvbhJjChlyZXNwb25zZV9jYXBhYmlsaXRpZXNfZ2V0GPUDIAEoCzIkLm'
    'ZvY3N0aW1fcnBjLlJlc3BvbnNlQ2FwYWJpbGl0aWVzR2V0SABSF3Jlc3BvbnNlQ2FwYWJpbGl0'
    'aWVzR2V0ElcKFXJlc3BvbnNlX3NpZ25hbF9zdGFydBj2AyABKAsyIC5mb2NzdGltX3JwYy5SZX'
    'Nwb25zZVNpZ25hbFN0YXJ0SABSE3Jlc3BvbnNlU2lnbmFsU3RhcnQSVAoUcmVzcG9uc2Vfc2ln'
    'bmFsX3N0b3AY9wMgASgLMh8uZm9jc3RpbV9ycGMuUmVzcG9uc2VTaWduYWxTdG9wSABSEnJlc3'
    'BvbnNlU2lnbmFsU3RvcBJUChVyZXNwb25zZV9heGlzX21vdmVfdG8YBSABKAsyHy5mb2NzdGlt'
    'X3JwYy5SZXNwb25zZUF4aXNNb3ZlVG9IAFIScmVzcG9uc2VBeGlzTW92ZVRvEloKFnJlc3Bvbn'
    'NlX3RpbWVzdGFtcF9zZXQY+AMgASgLMiEuZm9jc3RpbV9ycGMuUmVzcG9uc2VUaW1lc3RhbXBT'
    'ZXRIAFIUcmVzcG9uc2VUaW1lc3RhbXBTZXQSWgoWcmVzcG9uc2VfdGltZXN0YW1wX2dldBj5Ay'
    'ABKAsyIS5mb2NzdGltX3JwYy5SZXNwb25zZVRpbWVzdGFtcEdldEgAUhRyZXNwb25zZVRpbWVz'
    'dGFtcEdldBJqChxyZXNwb25zZV93aWZpX3BhcmFtZXRlcnNfc2V0GPsDIAEoCzImLmZvY3N0aW'
    '1fcnBjLlJlc3BvbnNlV2lmaVBhcmFtZXRlcnNTZXRIAFIZcmVzcG9uc2VXaWZpUGFyYW1ldGVy'
    'c1NldBJSChRyZXNwb25zZV93aWZpX2lwX2dldBj8AyABKAsyHi5mb2NzdGltX3JwYy5SZXNwb2'
    '5zZVdpZmlJUEdldEgAUhFyZXNwb25zZVdpZmlJcEdldBJdChdyZXNwb25zZV9sc202ZHNveF9z'
    'dGFydBjYBCABKAsyIi5mb2NzdGltX3JwYy5SZXNwb25zZUxTTTZEU09YU3RhcnRIAFIVcmVzcG'
    '9uc2VMc202ZHNveFN0YXJ0EloKFnJlc3BvbnNlX2xzbTZkc294X3N0b3AY2QQgASgLMiEuZm9j'
    'c3RpbV9ycGMuUmVzcG9uc2VMU002RFNPWFN0b3BIAFIUcmVzcG9uc2VMc202ZHNveFN0b3AScQ'
    'ofcmVzcG9uc2VfZGVidWdfc3RtMzJfZGVlcF9zbGVlcBjoByABKAsyKC5mb2NzdGltX3JwYy5S'
    'ZXNwb25zZURlYnVnU3RtMzJEZWVwU2xlZXBIAFIbcmVzcG9uc2VEZWJ1Z1N0bTMyRGVlcFNsZW'
    'VwEigKBWVycm9yGAMgASgLMhIuZm9jc3RpbV9ycGMuRXJyb3JSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use errorDescriptor instead')
const Error$json = {
  '1': 'Error',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.focstim_rpc.Errors',
      '10': 'code'
    },
  ],
};

/// Descriptor for `Error`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorDescriptor = $convert.base64Decode(
    'CgVFcnJvchInCgRjb2RlGAEgASgOMhMuZm9jc3RpbV9ycGMuRXJyb3JzUgRjb2Rl');

@$core.Deprecated('Use rpcMessageDescriptor instead')
const RpcMessage$json = {
  '1': 'RpcMessage',
  '2': [
    {
      '1': 'request',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.Request',
      '9': 0,
      '10': 'request'
    },
    {
      '1': 'response',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.Response',
      '9': 0,
      '10': 'response'
    },
    {
      '1': 'notification',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.focstim_rpc.Notification',
      '9': 0,
      '10': 'notification'
    },
  ],
  '8': [
    {'1': 'message'},
  ],
};

/// Descriptor for `RpcMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rpcMessageDescriptor = $convert.base64Decode(
    'CgpScGNNZXNzYWdlEjAKB3JlcXVlc3QYAiABKAsyFC5mb2NzdGltX3JwYy5SZXF1ZXN0SABSB3'
    'JlcXVlc3QSMwoIcmVzcG9uc2UYBCABKAsyFS5mb2NzdGltX3JwYy5SZXNwb25zZUgAUghyZXNw'
    'b25zZRI/Cgxub3RpZmljYXRpb24YBSABKAsyGS5mb2NzdGltX3JwYy5Ob3RpZmljYXRpb25IAF'
    'IMbm90aWZpY2F0aW9uQgkKB21lc3NhZ2U=');
