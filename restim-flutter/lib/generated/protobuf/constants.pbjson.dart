// This is a generated file - do not edit.
//
// Generated from constants.proto.

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

@$core.Deprecated('Use axisTypeDescriptor instead')
const AxisType$json = {
  '1': 'AxisType',
  '2': [
    {'1': 'AXIS_UNKNOWN', '2': 0},
    {'1': 'AXIS_POSITION_ALPHA', '2': 1},
    {'1': 'AXIS_POSITION_BETA', '2': 2},
    {'1': 'AXIS_POSITION_GAMMA', '2': 3},
    {'1': 'AXIS_WAVEFORM_AMPLITUDE_AMPS', '2': 11},
    {'1': 'AXIS_CARRIER_FREQUENCY_HZ', '2': 20},
    {'1': 'AXIS_PULSE_WIDTH_IN_CYCLES', '2': 21},
    {'1': 'AXIS_PULSE_RISE_TIME_CYCLES', '2': 22},
    {'1': 'AXIS_PULSE_FREQUENCY_HZ', '2': 23},
    {'1': 'AXIS_PULSE_INTERVAL_RANDOM_PERCENT', '2': 24},
    {'1': 'AXIS_CALIBRATION_3_CENTER', '2': 30},
    {'1': 'AXIS_CALIBRATION_3_UP', '2': 31},
    {'1': 'AXIS_CALIBRATION_3_LEFT', '2': 32},
    {'1': 'AXIS_CALIBRATION_4_CENTER', '2': 40},
    {'1': 'AXIS_CALIBRATION_4_A', '2': 41},
    {'1': 'AXIS_CALIBRATION_4_B', '2': 42},
    {'1': 'AXIS_CALIBRATION_4_C', '2': 43},
    {'1': 'AXIS_CALIBRATION_4_D', '2': 44},
  ],
};

/// Descriptor for `AxisType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List axisTypeDescriptor = $convert.base64Decode(
    'CghBeGlzVHlwZRIQCgxBWElTX1VOS05PV04QABIXChNBWElTX1BPU0lUSU9OX0FMUEhBEAESFg'
    'oSQVhJU19QT1NJVElPTl9CRVRBEAISFwoTQVhJU19QT1NJVElPTl9HQU1NQRADEiAKHEFYSVNf'
    'V0FWRUZPUk1fQU1QTElUVURFX0FNUFMQCxIdChlBWElTX0NBUlJJRVJfRlJFUVVFTkNZX0haEB'
    'QSHgoaQVhJU19QVUxTRV9XSURUSF9JTl9DWUNMRVMQFRIfChtBWElTX1BVTFNFX1JJU0VfVElN'
    'RV9DWUNMRVMQFhIbChdBWElTX1BVTFNFX0ZSRVFVRU5DWV9IWhAXEiYKIkFYSVNfUFVMU0VfSU'
    '5URVJWQUxfUkFORE9NX1BFUkNFTlQQGBIdChlBWElTX0NBTElCUkFUSU9OXzNfQ0VOVEVSEB4S'
    'GQoVQVhJU19DQUxJQlJBVElPTl8zX1VQEB8SGwoXQVhJU19DQUxJQlJBVElPTl8zX0xFRlQQIB'
    'IdChlBWElTX0NBTElCUkFUSU9OXzRfQ0VOVEVSECgSGAoUQVhJU19DQUxJQlJBVElPTl80X0EQ'
    'KRIYChRBWElTX0NBTElCUkFUSU9OXzRfQhAqEhgKFEFYSVNfQ0FMSUJSQVRJT05fNF9DECsSGA'
    'oUQVhJU19DQUxJQlJBVElPTl80X0QQLA==');

@$core.Deprecated('Use boardIdentifierDescriptor instead')
const BoardIdentifier$json = {
  '1': 'BoardIdentifier',
  '2': [
    {'1': 'BOARD_UNKNOWN', '2': 0},
    {'1': 'BOARD_B_G431B_ESC1', '2': 1},
    {'1': 'BOARD_FOCSTIM_V4', '2': 2},
  ],
};

/// Descriptor for `BoardIdentifier`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List boardIdentifierDescriptor = $convert.base64Decode(
    'Cg9Cb2FyZElkZW50aWZpZXISEQoNQk9BUkRfVU5LTk9XThAAEhYKEkJPQVJEX0JfRzQzMUJfRV'
    'NDMRABEhQKEEJPQVJEX0ZPQ1NUSU1fVjQQAg==');

@$core.Deprecated('Use outputModeDescriptor instead')
const OutputMode$json = {
  '1': 'OutputMode',
  '2': [
    {'1': 'OUTPUT_UNKNOWN', '2': 0},
    {'1': 'OUTPUT_THREEPHASE', '2': 2},
    {'1': 'OUTPUT_FOURPHASE', '2': 3},
  ],
};

/// Descriptor for `OutputMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List outputModeDescriptor = $convert.base64Decode(
    'CgpPdXRwdXRNb2RlEhIKDk9VVFBVVF9VTktOT1dOEAASFQoRT1VUUFVUX1RIUkVFUEhBU0UQAh'
    'IUChBPVVRQVVRfRk9VUlBIQVNFEAM=');

@$core.Deprecated('Use streamingModeDescriptor instead')
const StreamingMode$json = {
  '1': 'StreamingMode',
  '2': [
    {'1': 'STREAMING_UNKNOWN', '2': 0},
    {'1': 'STREAMING_MOVETO', '2': 1},
    {'1': 'STREAMING_BUFFERED', '2': 2},
  ],
};

/// Descriptor for `StreamingMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List streamingModeDescriptor = $convert.base64Decode(
    'Cg1TdHJlYW1pbmdNb2RlEhUKEVNUUkVBTUlOR19VTktOT1dOEAASFAoQU1RSRUFNSU5HX01PVk'
    'VUTxABEhYKElNUUkVBTUlOR19CVUZGRVJFRBAC');

@$core.Deprecated('Use errorsDescriptor instead')
const Errors$json = {
  '1': 'Errors',
  '2': [
    {'1': 'ERROR_UNKNOWN', '2': 0},
    {'1': 'ERROR_OUTPUT_NOT_SUPPORTED', '2': 1},
    {'1': 'ERROR_UNKNOWN_REQUEST', '2': 2},
    {'1': 'ERROR_POWER_NOT_PRESENT', '2': 3},
    {'1': 'ERROR_ALREADY_PLAYING', '2': 4},
  ],
};

/// Descriptor for `Errors`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List errorsDescriptor = $convert.base64Decode(
    'CgZFcnJvcnMSEQoNRVJST1JfVU5LTk9XThAAEh4KGkVSUk9SX09VVFBVVF9OT1RfU1VQUE9SVE'
    'VEEAESGQoVRVJST1JfVU5LTk9XTl9SRVFVRVNUEAISGwoXRVJST1JfUE9XRVJfTk9UX1BSRVNF'
    'TlQQAxIZChVFUlJPUl9BTFJFQURZX1BMQVlJTkcQBA==');
