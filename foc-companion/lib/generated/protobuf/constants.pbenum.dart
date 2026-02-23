// This is a generated file - do not edit.
//
// Generated from constants.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class AxisType extends $pb.ProtobufEnum {
  static const AxisType AXIS_UNKNOWN =
      AxisType._(0, _omitEnumNames ? '' : 'AXIS_UNKNOWN');
  static const AxisType AXIS_POSITION_ALPHA =
      AxisType._(1, _omitEnumNames ? '' : 'AXIS_POSITION_ALPHA');
  static const AxisType AXIS_POSITION_BETA =
      AxisType._(2, _omitEnumNames ? '' : 'AXIS_POSITION_BETA');
  static const AxisType AXIS_POSITION_GAMMA =
      AxisType._(3, _omitEnumNames ? '' : 'AXIS_POSITION_GAMMA');

  /// AXIS_VOLUME_PERCENT = 10;    // not used
  static const AxisType AXIS_WAVEFORM_AMPLITUDE_AMPS =
      AxisType._(11, _omitEnumNames ? '' : 'AXIS_WAVEFORM_AMPLITUDE_AMPS');
  static const AxisType AXIS_CARRIER_FREQUENCY_HZ =
      AxisType._(20, _omitEnumNames ? '' : 'AXIS_CARRIER_FREQUENCY_HZ');
  static const AxisType AXIS_PULSE_WIDTH_IN_CYCLES =
      AxisType._(21, _omitEnumNames ? '' : 'AXIS_PULSE_WIDTH_IN_CYCLES');
  static const AxisType AXIS_PULSE_RISE_TIME_CYCLES =
      AxisType._(22, _omitEnumNames ? '' : 'AXIS_PULSE_RISE_TIME_CYCLES');
  static const AxisType AXIS_PULSE_FREQUENCY_HZ =
      AxisType._(23, _omitEnumNames ? '' : 'AXIS_PULSE_FREQUENCY_HZ');
  static const AxisType AXIS_PULSE_INTERVAL_RANDOM_PERCENT = AxisType._(
      24, _omitEnumNames ? '' : 'AXIS_PULSE_INTERVAL_RANDOM_PERCENT');
  static const AxisType AXIS_CALIBRATION_3_CENTER =
      AxisType._(30, _omitEnumNames ? '' : 'AXIS_CALIBRATION_3_CENTER');
  static const AxisType AXIS_CALIBRATION_3_UP =
      AxisType._(31, _omitEnumNames ? '' : 'AXIS_CALIBRATION_3_UP');
  static const AxisType AXIS_CALIBRATION_3_LEFT =
      AxisType._(32, _omitEnumNames ? '' : 'AXIS_CALIBRATION_3_LEFT');
  static const AxisType AXIS_CALIBRATION_4_CENTER =
      AxisType._(40, _omitEnumNames ? '' : 'AXIS_CALIBRATION_4_CENTER');
  static const AxisType AXIS_CALIBRATION_4_A =
      AxisType._(41, _omitEnumNames ? '' : 'AXIS_CALIBRATION_4_A');
  static const AxisType AXIS_CALIBRATION_4_B =
      AxisType._(42, _omitEnumNames ? '' : 'AXIS_CALIBRATION_4_B');
  static const AxisType AXIS_CALIBRATION_4_C =
      AxisType._(43, _omitEnumNames ? '' : 'AXIS_CALIBRATION_4_C');
  static const AxisType AXIS_CALIBRATION_4_D =
      AxisType._(44, _omitEnumNames ? '' : 'AXIS_CALIBRATION_4_D');
  static const AxisType AXIS_ELECTRODE_1_POWER =
      AxisType._(50, _omitEnumNames ? '' : 'AXIS_ELECTRODE_1_POWER');
  static const AxisType AXIS_ELECTRODE_2_POWER =
      AxisType._(51, _omitEnumNames ? '' : 'AXIS_ELECTRODE_2_POWER');
  static const AxisType AXIS_ELECTRODE_3_POWER =
      AxisType._(52, _omitEnumNames ? '' : 'AXIS_ELECTRODE_3_POWER');
  static const AxisType AXIS_ELECTRODE_4_POWER =
      AxisType._(53, _omitEnumNames ? '' : 'AXIS_ELECTRODE_4_POWER');

  static const $core.List<AxisType> values = <AxisType>[
    AXIS_UNKNOWN,
    AXIS_POSITION_ALPHA,
    AXIS_POSITION_BETA,
    AXIS_POSITION_GAMMA,
    AXIS_WAVEFORM_AMPLITUDE_AMPS,
    AXIS_CARRIER_FREQUENCY_HZ,
    AXIS_PULSE_WIDTH_IN_CYCLES,
    AXIS_PULSE_RISE_TIME_CYCLES,
    AXIS_PULSE_FREQUENCY_HZ,
    AXIS_PULSE_INTERVAL_RANDOM_PERCENT,
    AXIS_CALIBRATION_3_CENTER,
    AXIS_CALIBRATION_3_UP,
    AXIS_CALIBRATION_3_LEFT,
    AXIS_CALIBRATION_4_CENTER,
    AXIS_CALIBRATION_4_A,
    AXIS_CALIBRATION_4_B,
    AXIS_CALIBRATION_4_C,
    AXIS_CALIBRATION_4_D,
    AXIS_ELECTRODE_1_POWER,
    AXIS_ELECTRODE_2_POWER,
    AXIS_ELECTRODE_3_POWER,
    AXIS_ELECTRODE_4_POWER,
  ];

  static final $core.Map<$core.int, AxisType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static AxisType? valueOf($core.int value) => _byValue[value];

  const AxisType._(super.value, super.name);
}

class BoardIdentifier extends $pb.ProtobufEnum {
  static const BoardIdentifier BOARD_UNKNOWN =
      BoardIdentifier._(0, _omitEnumNames ? '' : 'BOARD_UNKNOWN');
  static const BoardIdentifier BOARD_B_G431B_ESC1 =
      BoardIdentifier._(1, _omitEnumNames ? '' : 'BOARD_B_G431B_ESC1');
  static const BoardIdentifier BOARD_FOCSTIM_V4 =
      BoardIdentifier._(2, _omitEnumNames ? '' : 'BOARD_FOCSTIM_V4');

  static const $core.List<BoardIdentifier> values = <BoardIdentifier>[
    BOARD_UNKNOWN,
    BOARD_B_G431B_ESC1,
    BOARD_FOCSTIM_V4,
  ];

  static final $core.List<BoardIdentifier?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static BoardIdentifier? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const BoardIdentifier._(super.value, super.name);
}

class OutputMode extends $pb.ProtobufEnum {
  static const OutputMode OUTPUT_UNKNOWN =
      OutputMode._(0, _omitEnumNames ? '' : 'OUTPUT_UNKNOWN');

  /// OUTPUT_OFF = 1;
  static const OutputMode OUTPUT_THREEPHASE =
      OutputMode._(2, _omitEnumNames ? '' : 'OUTPUT_THREEPHASE');
  static const OutputMode OUTPUT_FOURPHASE =
      OutputMode._(3, _omitEnumNames ? '' : 'OUTPUT_FOURPHASE');
  static const OutputMode OUTPUT_FOURPHASE_INDIVIDUAL_ELECTRODES = OutputMode._(
      4, _omitEnumNames ? '' : 'OUTPUT_FOURPHASE_INDIVIDUAL_ELECTRODES');

  static const $core.List<OutputMode> values = <OutputMode>[
    OUTPUT_UNKNOWN,
    OUTPUT_THREEPHASE,
    OUTPUT_FOURPHASE,
    OUTPUT_FOURPHASE_INDIVIDUAL_ELECTRODES,
  ];

  static final $core.List<OutputMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static OutputMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OutputMode._(super.value, super.name);
}

/// TODO: implement
class StreamingMode extends $pb.ProtobufEnum {
  static const StreamingMode STREAMING_UNKNOWN =
      StreamingMode._(0, _omitEnumNames ? '' : 'STREAMING_UNKNOWN');
  static const StreamingMode STREAMING_MOVETO =
      StreamingMode._(1, _omitEnumNames ? '' : 'STREAMING_MOVETO');
  static const StreamingMode STREAMING_BUFFERED =
      StreamingMode._(2, _omitEnumNames ? '' : 'STREAMING_BUFFERED');

  static const $core.List<StreamingMode> values = <StreamingMode>[
    STREAMING_UNKNOWN,
    STREAMING_MOVETO,
    STREAMING_BUFFERED,
  ];

  static final $core.List<StreamingMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static StreamingMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const StreamingMode._(super.value, super.name);
}

class Errors extends $pb.ProtobufEnum {
  static const Errors ERROR_UNKNOWN =
      Errors._(0, _omitEnumNames ? '' : 'ERROR_UNKNOWN');
  static const Errors ERROR_OUTPUT_NOT_SUPPORTED =
      Errors._(1, _omitEnumNames ? '' : 'ERROR_OUTPUT_NOT_SUPPORTED');
  static const Errors ERROR_UNKNOWN_REQUEST =
      Errors._(2, _omitEnumNames ? '' : 'ERROR_UNKNOWN_REQUEST');
  static const Errors ERROR_POWER_NOT_PRESENT =
      Errors._(3, _omitEnumNames ? '' : 'ERROR_POWER_NOT_PRESENT');
  static const Errors ERROR_ALREADY_PLAYING =
      Errors._(4, _omitEnumNames ? '' : 'ERROR_ALREADY_PLAYING');

  static const $core.List<Errors> values = <Errors>[
    ERROR_UNKNOWN,
    ERROR_OUTPUT_NOT_SUPPORTED,
    ERROR_UNKNOWN_REQUEST,
    ERROR_POWER_NOT_PRESENT,
    ERROR_ALREADY_PLAYING,
  ];

  static final $core.List<Errors?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static Errors? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Errors._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
