// This is a generated file - do not edit.
//
// Generated from messages.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'constants.pbenum.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class FirmwareVersion extends $pb.GeneratedMessage {
  factory FirmwareVersion({
    $core.int? major,
    $core.int? minor,
    $core.int? revision,
    $core.String? branch,
    $core.String? comment,
  }) {
    final result = create();
    if (major != null) result.major = major;
    if (minor != null) result.minor = minor;
    if (revision != null) result.revision = revision;
    if (branch != null) result.branch = branch;
    if (comment != null) result.comment = comment;
    return result;
  }

  FirmwareVersion._();

  factory FirmwareVersion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FirmwareVersion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FirmwareVersion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'major', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'minor', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'revision', fieldType: $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'branch')
    ..aOS(5, _omitFieldNames ? '' : 'comment')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirmwareVersion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirmwareVersion copyWith(void Function(FirmwareVersion) updates) =>
      super.copyWith((message) => updates(message as FirmwareVersion))
          as FirmwareVersion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FirmwareVersion create() => FirmwareVersion._();
  @$core.override
  FirmwareVersion createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FirmwareVersion getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FirmwareVersion>(create);
  static FirmwareVersion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get major => $_getIZ(0);
  @$pb.TagNumber(1)
  set major($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMajor() => $_has(0);
  @$pb.TagNumber(1)
  void clearMajor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get minor => $_getIZ(1);
  @$pb.TagNumber(2)
  set minor($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinor() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get revision => $_getIZ(2);
  @$pb.TagNumber(3)
  set revision($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevision() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevision() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get branch => $_getSZ(3);
  @$pb.TagNumber(4)
  set branch($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBranch() => $_has(3);
  @$pb.TagNumber(4)
  void clearBranch() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get comment => $_getSZ(4);
  @$pb.TagNumber(5)
  set comment($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasComment() => $_has(4);
  @$pb.TagNumber(5)
  void clearComment() => $_clearField(5);
}

/// general commands
class RequestFirmwareVersion extends $pb.GeneratedMessage {
  factory RequestFirmwareVersion() => create();

  RequestFirmwareVersion._();

  factory RequestFirmwareVersion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestFirmwareVersion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestFirmwareVersion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestFirmwareVersion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestFirmwareVersion copyWith(
          void Function(RequestFirmwareVersion) updates) =>
      super.copyWith((message) => updates(message as RequestFirmwareVersion))
          as RequestFirmwareVersion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestFirmwareVersion create() => RequestFirmwareVersion._();
  @$core.override
  RequestFirmwareVersion createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestFirmwareVersion getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestFirmwareVersion>(create);
  static RequestFirmwareVersion? _defaultInstance;
}

class ResponseFirmwareVersion extends $pb.GeneratedMessage {
  factory ResponseFirmwareVersion({
    $0.BoardIdentifier? board,
    FirmwareVersion? stm32FirmwareVersion2,
  }) {
    final result = create();
    if (board != null) result.board = board;
    if (stm32FirmwareVersion2 != null)
      result.stm32FirmwareVersion2 = stm32FirmwareVersion2;
    return result;
  }

  ResponseFirmwareVersion._();

  factory ResponseFirmwareVersion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseFirmwareVersion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseFirmwareVersion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aE<$0.BoardIdentifier>(1, _omitFieldNames ? '' : 'board',
        enumValues: $0.BoardIdentifier.values)
    ..aOM<FirmwareVersion>(3, _omitFieldNames ? '' : 'stm32FirmwareVersion2',
        protoName: 'stm32_firmware_version_2',
        subBuilder: FirmwareVersion.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseFirmwareVersion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseFirmwareVersion copyWith(
          void Function(ResponseFirmwareVersion) updates) =>
      super.copyWith((message) => updates(message as ResponseFirmwareVersion))
          as ResponseFirmwareVersion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseFirmwareVersion create() => ResponseFirmwareVersion._();
  @$core.override
  ResponseFirmwareVersion createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseFirmwareVersion getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseFirmwareVersion>(create);
  static ResponseFirmwareVersion? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BoardIdentifier get board => $_getN(0);
  @$pb.TagNumber(1)
  set board($0.BoardIdentifier value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBoard() => $_has(0);
  @$pb.TagNumber(1)
  void clearBoard() => $_clearField(1);

  @$pb.TagNumber(3)
  FirmwareVersion get stm32FirmwareVersion2 => $_getN(1);
  @$pb.TagNumber(3)
  set stm32FirmwareVersion2(FirmwareVersion value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStm32FirmwareVersion2() => $_has(1);
  @$pb.TagNumber(3)
  void clearStm32FirmwareVersion2() => $_clearField(3);
  @$pb.TagNumber(3)
  FirmwareVersion ensureStm32FirmwareVersion2() => $_ensure(1);
}

class RequestCapabilitiesGet extends $pb.GeneratedMessage {
  factory RequestCapabilitiesGet() => create();

  RequestCapabilitiesGet._();

  factory RequestCapabilitiesGet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestCapabilitiesGet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestCapabilitiesGet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestCapabilitiesGet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestCapabilitiesGet copyWith(
          void Function(RequestCapabilitiesGet) updates) =>
      super.copyWith((message) => updates(message as RequestCapabilitiesGet))
          as RequestCapabilitiesGet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestCapabilitiesGet create() => RequestCapabilitiesGet._();
  @$core.override
  RequestCapabilitiesGet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestCapabilitiesGet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestCapabilitiesGet>(create);
  static RequestCapabilitiesGet? _defaultInstance;
}

class ResponseCapabilitiesGet extends $pb.GeneratedMessage {
  factory ResponseCapabilitiesGet({
    $core.bool? threephase,
    $core.bool? fourphase,
    $core.bool? battery,
    $core.bool? potentiometer,
    $core.double? maximumWaveformAmplitudeAmps,
    $core.bool? lsm6dsox,
  }) {
    final result = create();
    if (threephase != null) result.threephase = threephase;
    if (fourphase != null) result.fourphase = fourphase;
    if (battery != null) result.battery = battery;
    if (potentiometer != null) result.potentiometer = potentiometer;
    if (maximumWaveformAmplitudeAmps != null)
      result.maximumWaveformAmplitudeAmps = maximumWaveformAmplitudeAmps;
    if (lsm6dsox != null) result.lsm6dsox = lsm6dsox;
    return result;
  }

  ResponseCapabilitiesGet._();

  factory ResponseCapabilitiesGet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseCapabilitiesGet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseCapabilitiesGet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'threephase')
    ..aOB(2, _omitFieldNames ? '' : 'fourphase')
    ..aOB(3, _omitFieldNames ? '' : 'battery')
    ..aOB(4, _omitFieldNames ? '' : 'potentiometer')
    ..aD(5, _omitFieldNames ? '' : 'maximumWaveformAmplitudeAmps',
        fieldType: $pb.PbFieldType.OF)
    ..aOB(6, _omitFieldNames ? '' : 'lsm6dsox')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseCapabilitiesGet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseCapabilitiesGet copyWith(
          void Function(ResponseCapabilitiesGet) updates) =>
      super.copyWith((message) => updates(message as ResponseCapabilitiesGet))
          as ResponseCapabilitiesGet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseCapabilitiesGet create() => ResponseCapabilitiesGet._();
  @$core.override
  ResponseCapabilitiesGet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseCapabilitiesGet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseCapabilitiesGet>(create);
  static ResponseCapabilitiesGet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get threephase => $_getBF(0);
  @$pb.TagNumber(1)
  set threephase($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasThreephase() => $_has(0);
  @$pb.TagNumber(1)
  void clearThreephase() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get fourphase => $_getBF(1);
  @$pb.TagNumber(2)
  set fourphase($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFourphase() => $_has(1);
  @$pb.TagNumber(2)
  void clearFourphase() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get battery => $_getBF(2);
  @$pb.TagNumber(3)
  set battery($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBattery() => $_has(2);
  @$pb.TagNumber(3)
  void clearBattery() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get potentiometer => $_getBF(3);
  @$pb.TagNumber(4)
  set potentiometer($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPotentiometer() => $_has(3);
  @$pb.TagNumber(4)
  void clearPotentiometer() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get maximumWaveformAmplitudeAmps => $_getN(4);
  @$pb.TagNumber(5)
  set maximumWaveformAmplitudeAmps($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaximumWaveformAmplitudeAmps() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaximumWaveformAmplitudeAmps() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get lsm6dsox => $_getBF(5);
  @$pb.TagNumber(6)
  set lsm6dsox($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLsm6dsox() => $_has(5);
  @$pb.TagNumber(6)
  void clearLsm6dsox() => $_clearField(6);
}

class RequestSignalStart extends $pb.GeneratedMessage {
  factory RequestSignalStart({
    $0.OutputMode? mode,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    return result;
  }

  RequestSignalStart._();

  factory RequestSignalStart.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestSignalStart.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestSignalStart',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aE<$0.OutputMode>(1, _omitFieldNames ? '' : 'mode',
        enumValues: $0.OutputMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSignalStart clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSignalStart copyWith(void Function(RequestSignalStart) updates) =>
      super.copyWith((message) => updates(message as RequestSignalStart))
          as RequestSignalStart;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestSignalStart create() => RequestSignalStart._();
  @$core.override
  RequestSignalStart createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestSignalStart getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestSignalStart>(create);
  static RequestSignalStart? _defaultInstance;

  @$pb.TagNumber(1)
  $0.OutputMode get mode => $_getN(0);
  @$pb.TagNumber(1)
  set mode($0.OutputMode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);
}

class ResponseSignalStart extends $pb.GeneratedMessage {
  factory ResponseSignalStart() => create();

  ResponseSignalStart._();

  factory ResponseSignalStart.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseSignalStart.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseSignalStart',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseSignalStart clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseSignalStart copyWith(void Function(ResponseSignalStart) updates) =>
      super.copyWith((message) => updates(message as ResponseSignalStart))
          as ResponseSignalStart;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseSignalStart create() => ResponseSignalStart._();
  @$core.override
  ResponseSignalStart createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseSignalStart getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseSignalStart>(create);
  static ResponseSignalStart? _defaultInstance;
}

class RequestSignalStop extends $pb.GeneratedMessage {
  factory RequestSignalStop() => create();

  RequestSignalStop._();

  factory RequestSignalStop.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestSignalStop.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestSignalStop',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSignalStop clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSignalStop copyWith(void Function(RequestSignalStop) updates) =>
      super.copyWith((message) => updates(message as RequestSignalStop))
          as RequestSignalStop;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestSignalStop create() => RequestSignalStop._();
  @$core.override
  RequestSignalStop createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestSignalStop getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestSignalStop>(create);
  static RequestSignalStop? _defaultInstance;
}

class ResponseSignalStop extends $pb.GeneratedMessage {
  factory ResponseSignalStop() => create();

  ResponseSignalStop._();

  factory ResponseSignalStop.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseSignalStop.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseSignalStop',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseSignalStop clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseSignalStop copyWith(void Function(ResponseSignalStop) updates) =>
      super.copyWith((message) => updates(message as ResponseSignalStop))
          as ResponseSignalStop;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseSignalStop create() => ResponseSignalStop._();
  @$core.override
  ResponseSignalStop createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseSignalStop getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseSignalStop>(create);
  static ResponseSignalStop? _defaultInstance;
}

/// TODO: implement?
class RequestModeSet extends $pb.GeneratedMessage {
  factory RequestModeSet() => create();

  RequestModeSet._();

  factory RequestModeSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestModeSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestModeSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestModeSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestModeSet copyWith(void Function(RequestModeSet) updates) =>
      super.copyWith((message) => updates(message as RequestModeSet))
          as RequestModeSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestModeSet create() => RequestModeSet._();
  @$core.override
  RequestModeSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestModeSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestModeSet>(create);
  static RequestModeSet? _defaultInstance;
}

class ResponseModeSet extends $pb.GeneratedMessage {
  factory ResponseModeSet() => create();

  ResponseModeSet._();

  factory ResponseModeSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseModeSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseModeSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseModeSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseModeSet copyWith(void Function(ResponseModeSet) updates) =>
      super.copyWith((message) => updates(message as ResponseModeSet))
          as ResponseModeSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseModeSet create() => ResponseModeSet._();
  @$core.override
  ResponseModeSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseModeSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseModeSet>(create);
  static ResponseModeSet? _defaultInstance;
}

/// MoveTo streaming API
class RequestAxisMoveTo extends $pb.GeneratedMessage {
  factory RequestAxisMoveTo({
    $0.AxisType? axis,
    $core.double? value,
    $core.int? interval,
  }) {
    final result = create();
    if (axis != null) result.axis = axis;
    if (value != null) result.value = value;
    if (interval != null) result.interval = interval;
    return result;
  }

  RequestAxisMoveTo._();

  factory RequestAxisMoveTo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestAxisMoveTo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestAxisMoveTo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aE<$0.AxisType>(1, _omitFieldNames ? '' : 'axis',
        enumValues: $0.AxisType.values)
    ..aD(3, _omitFieldNames ? '' : 'value', fieldType: $pb.PbFieldType.OF)
    ..aI(4, _omitFieldNames ? '' : 'interval', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestAxisMoveTo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestAxisMoveTo copyWith(void Function(RequestAxisMoveTo) updates) =>
      super.copyWith((message) => updates(message as RequestAxisMoveTo))
          as RequestAxisMoveTo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestAxisMoveTo create() => RequestAxisMoveTo._();
  @$core.override
  RequestAxisMoveTo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestAxisMoveTo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestAxisMoveTo>(create);
  static RequestAxisMoveTo? _defaultInstance;

  @$pb.TagNumber(1)
  $0.AxisType get axis => $_getN(0);
  @$pb.TagNumber(1)
  set axis($0.AxisType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAxis() => $_has(0);
  @$pb.TagNumber(1)
  void clearAxis() => $_clearField(1);

  @$pb.TagNumber(3)
  $core.double get value => $_getN(1);
  @$pb.TagNumber(3)
  set value($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get interval => $_getIZ(2);
  @$pb.TagNumber(4)
  set interval($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(4)
  $core.bool hasInterval() => $_has(2);
  @$pb.TagNumber(4)
  void clearInterval() => $_clearField(4);
}

class ResponseAxisMoveTo extends $pb.GeneratedMessage {
  factory ResponseAxisMoveTo() => create();

  ResponseAxisMoveTo._();

  factory ResponseAxisMoveTo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseAxisMoveTo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseAxisMoveTo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseAxisMoveTo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseAxisMoveTo copyWith(void Function(ResponseAxisMoveTo) updates) =>
      super.copyWith((message) => updates(message as ResponseAxisMoveTo))
          as ResponseAxisMoveTo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseAxisMoveTo create() => ResponseAxisMoveTo._();
  @$core.override
  ResponseAxisMoveTo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseAxisMoveTo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseAxisMoveTo>(create);
  static ResponseAxisMoveTo? _defaultInstance;
}

/// Buffered streaming API
class RequestAxisSet extends $pb.GeneratedMessage {
  factory RequestAxisSet({
    $0.AxisType? axis,
    $core.int? timestampMs,
    $core.double? value,
    $core.bool? clear_4,
  }) {
    final result = create();
    if (axis != null) result.axis = axis;
    if (timestampMs != null) result.timestampMs = timestampMs;
    if (value != null) result.value = value;
    if (clear_4 != null) result.clear_4 = clear_4;
    return result;
  }

  RequestAxisSet._();

  factory RequestAxisSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestAxisSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestAxisSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aE<$0.AxisType>(1, _omitFieldNames ? '' : 'axis',
        enumValues: $0.AxisType.values)
    ..aI(2, _omitFieldNames ? '' : 'timestampMs',
        fieldType: $pb.PbFieldType.OF3)
    ..aD(3, _omitFieldNames ? '' : 'value', fieldType: $pb.PbFieldType.OF)
    ..aOB(4, _omitFieldNames ? '' : 'clear')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestAxisSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestAxisSet copyWith(void Function(RequestAxisSet) updates) =>
      super.copyWith((message) => updates(message as RequestAxisSet))
          as RequestAxisSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestAxisSet create() => RequestAxisSet._();
  @$core.override
  RequestAxisSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestAxisSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestAxisSet>(create);
  static RequestAxisSet? _defaultInstance;

  @$pb.TagNumber(1)
  $0.AxisType get axis => $_getN(0);
  @$pb.TagNumber(1)
  set axis($0.AxisType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAxis() => $_has(0);
  @$pb.TagNumber(1)
  void clearAxis() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get timestampMs => $_getIZ(1);
  @$pb.TagNumber(2)
  set timestampMs($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestampMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestampMs() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get value => $_getN(2);
  @$pb.TagNumber(3)
  set value($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get clear_4 => $_getBF(3);
  @$pb.TagNumber(4)
  set clear_4($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClear_4() => $_has(3);
  @$pb.TagNumber(4)
  void clearClear_4() => $_clearField(4);
}

class ResponseAxisSet extends $pb.GeneratedMessage {
  factory ResponseAxisSet() => create();

  ResponseAxisSet._();

  factory ResponseAxisSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseAxisSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseAxisSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseAxisSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseAxisSet copyWith(void Function(ResponseAxisSet) updates) =>
      super.copyWith((message) => updates(message as ResponseAxisSet))
          as ResponseAxisSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseAxisSet create() => ResponseAxisSet._();
  @$core.override
  ResponseAxisSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseAxisSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseAxisSet>(create);
  static ResponseAxisSet? _defaultInstance;
}

/// Tell the system what unix timestamp is. Call regularly to avoid drift.
class RequestTimestampSet extends $pb.GeneratedMessage {
  factory RequestTimestampSet({
    $fixnum.Int64? timestampMs,
  }) {
    final result = create();
    if (timestampMs != null) result.timestampMs = timestampMs;
    return result;
  }

  RequestTimestampSet._();

  factory RequestTimestampSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestTimestampSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestTimestampSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'timestampMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestTimestampSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestTimestampSet copyWith(void Function(RequestTimestampSet) updates) =>
      super.copyWith((message) => updates(message as RequestTimestampSet))
          as RequestTimestampSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestTimestampSet create() => RequestTimestampSet._();
  @$core.override
  RequestTimestampSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestTimestampSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestTimestampSet>(create);
  static RequestTimestampSet? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestampMs => $_getI64(0);
  @$pb.TagNumber(1)
  set timestampMs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestampMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestampMs() => $_clearField(1);
}

class ResponseTimestampSet extends $pb.GeneratedMessage {
  factory ResponseTimestampSet({
    $fixnum.Int64? offsetMs,
    $fixnum.Int64? changeMs,
    $fixnum.Int64? errorMs,
  }) {
    final result = create();
    if (offsetMs != null) result.offsetMs = offsetMs;
    if (changeMs != null) result.changeMs = changeMs;
    if (errorMs != null) result.errorMs = errorMs;
    return result;
  }

  ResponseTimestampSet._();

  factory ResponseTimestampSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseTimestampSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseTimestampSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'offsetMs')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'changeMs', $pb.PbFieldType.OS6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'errorMs', $pb.PbFieldType.OS6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseTimestampSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseTimestampSet copyWith(void Function(ResponseTimestampSet) updates) =>
      super.copyWith((message) => updates(message as ResponseTimestampSet))
          as ResponseTimestampSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseTimestampSet create() => ResponseTimestampSet._();
  @$core.override
  ResponseTimestampSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseTimestampSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseTimestampSet>(create);
  static ResponseTimestampSet? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get offsetMs => $_getI64(0);
  @$pb.TagNumber(1)
  set offsetMs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOffsetMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearOffsetMs() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get changeMs => $_getI64(1);
  @$pb.TagNumber(2)
  set changeMs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChangeMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearChangeMs() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get errorMs => $_getI64(2);
  @$pb.TagNumber(3)
  set errorMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasErrorMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorMs() => $_clearField(3);
}

class RequestTimestampGet extends $pb.GeneratedMessage {
  factory RequestTimestampGet() => create();

  RequestTimestampGet._();

  factory RequestTimestampGet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestTimestampGet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestTimestampGet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestTimestampGet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestTimestampGet copyWith(void Function(RequestTimestampGet) updates) =>
      super.copyWith((message) => updates(message as RequestTimestampGet))
          as RequestTimestampGet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestTimestampGet create() => RequestTimestampGet._();
  @$core.override
  RequestTimestampGet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestTimestampGet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestTimestampGet>(create);
  static RequestTimestampGet? _defaultInstance;
}

class ResponseTimestampGet extends $pb.GeneratedMessage {
  factory ResponseTimestampGet({
    $core.int? timestampMs,
    $fixnum.Int64? unixTimestampMs,
  }) {
    final result = create();
    if (timestampMs != null) result.timestampMs = timestampMs;
    if (unixTimestampMs != null) result.unixTimestampMs = unixTimestampMs;
    return result;
  }

  ResponseTimestampGet._();

  factory ResponseTimestampGet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseTimestampGet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseTimestampGet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'timestampMs',
        fieldType: $pb.PbFieldType.OF3)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'unixTimestampMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseTimestampGet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseTimestampGet copyWith(void Function(ResponseTimestampGet) updates) =>
      super.copyWith((message) => updates(message as ResponseTimestampGet))
          as ResponseTimestampGet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseTimestampGet create() => ResponseTimestampGet._();
  @$core.override
  ResponseTimestampGet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseTimestampGet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseTimestampGet>(create);
  static ResponseTimestampGet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get timestampMs => $_getIZ(0);
  @$pb.TagNumber(1)
  set timestampMs($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestampMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestampMs() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get unixTimestampMs => $_getI64(1);
  @$pb.TagNumber(2)
  set unixTimestampMs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnixTimestampMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnixTimestampMs() => $_clearField(2);
}

/// network
class RequestWifiParametersSet extends $pb.GeneratedMessage {
  factory RequestWifiParametersSet({
    $core.List<$core.int>? ssid,
    $core.List<$core.int>? password,
  }) {
    final result = create();
    if (ssid != null) result.ssid = ssid;
    if (password != null) result.password = password;
    return result;
  }

  RequestWifiParametersSet._();

  factory RequestWifiParametersSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestWifiParametersSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestWifiParametersSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'ssid', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'password', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestWifiParametersSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestWifiParametersSet copyWith(
          void Function(RequestWifiParametersSet) updates) =>
      super.copyWith((message) => updates(message as RequestWifiParametersSet))
          as RequestWifiParametersSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestWifiParametersSet create() => RequestWifiParametersSet._();
  @$core.override
  RequestWifiParametersSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestWifiParametersSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestWifiParametersSet>(create);
  static RequestWifiParametersSet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get ssid => $_getN(0);
  @$pb.TagNumber(1)
  set ssid($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSsid() => $_has(0);
  @$pb.TagNumber(1)
  void clearSsid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get password => $_getN(1);
  @$pb.TagNumber(2)
  set password($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);
}

class ResponseWifiParametersSet extends $pb.GeneratedMessage {
  factory ResponseWifiParametersSet() => create();

  ResponseWifiParametersSet._();

  factory ResponseWifiParametersSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseWifiParametersSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseWifiParametersSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseWifiParametersSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseWifiParametersSet copyWith(
          void Function(ResponseWifiParametersSet) updates) =>
      super.copyWith((message) => updates(message as ResponseWifiParametersSet))
          as ResponseWifiParametersSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseWifiParametersSet create() => ResponseWifiParametersSet._();
  @$core.override
  ResponseWifiParametersSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseWifiParametersSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseWifiParametersSet>(create);
  static ResponseWifiParametersSet? _defaultInstance;
}

class RequestWifiIPGet extends $pb.GeneratedMessage {
  factory RequestWifiIPGet() => create();

  RequestWifiIPGet._();

  factory RequestWifiIPGet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestWifiIPGet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestWifiIPGet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestWifiIPGet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestWifiIPGet copyWith(void Function(RequestWifiIPGet) updates) =>
      super.copyWith((message) => updates(message as RequestWifiIPGet))
          as RequestWifiIPGet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestWifiIPGet create() => RequestWifiIPGet._();
  @$core.override
  RequestWifiIPGet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestWifiIPGet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestWifiIPGet>(create);
  static RequestWifiIPGet? _defaultInstance;
}

class ResponseWifiIPGet extends $pb.GeneratedMessage {
  factory ResponseWifiIPGet({
    $core.int? ip,
  }) {
    final result = create();
    if (ip != null) result.ip = ip;
    return result;
  }

  ResponseWifiIPGet._();

  factory ResponseWifiIPGet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseWifiIPGet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseWifiIPGet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'ip', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseWifiIPGet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseWifiIPGet copyWith(void Function(ResponseWifiIPGet) updates) =>
      super.copyWith((message) => updates(message as ResponseWifiIPGet))
          as ResponseWifiIPGet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseWifiIPGet create() => ResponseWifiIPGet._();
  @$core.override
  ResponseWifiIPGet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseWifiIPGet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseWifiIPGet>(create);
  static ResponseWifiIPGet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get ip => $_getIZ(0);
  @$pb.TagNumber(1)
  set ip($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearIp() => $_clearField(1);
}

/// sensors
class RequestLSM6DSOXStart extends $pb.GeneratedMessage {
  factory RequestLSM6DSOXStart({
    $core.double? imuSamplerate,
    $core.double? accFullscale,
    $core.double? gyrFullscale,
  }) {
    final result = create();
    if (imuSamplerate != null) result.imuSamplerate = imuSamplerate;
    if (accFullscale != null) result.accFullscale = accFullscale;
    if (gyrFullscale != null) result.gyrFullscale = gyrFullscale;
    return result;
  }

  RequestLSM6DSOXStart._();

  factory RequestLSM6DSOXStart.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestLSM6DSOXStart.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestLSM6DSOXStart',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'imuSamplerate',
        fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'accFullscale',
        fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'gyrFullscale',
        fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestLSM6DSOXStart clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestLSM6DSOXStart copyWith(void Function(RequestLSM6DSOXStart) updates) =>
      super.copyWith((message) => updates(message as RequestLSM6DSOXStart))
          as RequestLSM6DSOXStart;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestLSM6DSOXStart create() => RequestLSM6DSOXStart._();
  @$core.override
  RequestLSM6DSOXStart createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestLSM6DSOXStart getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestLSM6DSOXStart>(create);
  static RequestLSM6DSOXStart? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get imuSamplerate => $_getN(0);
  @$pb.TagNumber(1)
  set imuSamplerate($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImuSamplerate() => $_has(0);
  @$pb.TagNumber(1)
  void clearImuSamplerate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get accFullscale => $_getN(1);
  @$pb.TagNumber(2)
  set accFullscale($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccFullscale() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccFullscale() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get gyrFullscale => $_getN(2);
  @$pb.TagNumber(3)
  set gyrFullscale($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGyrFullscale() => $_has(2);
  @$pb.TagNumber(3)
  void clearGyrFullscale() => $_clearField(3);
}

class ResponseLSM6DSOXStart extends $pb.GeneratedMessage {
  factory ResponseLSM6DSOXStart({
    $core.double? accSensitivity,
    $core.double? gyrSensitivity,
  }) {
    final result = create();
    if (accSensitivity != null) result.accSensitivity = accSensitivity;
    if (gyrSensitivity != null) result.gyrSensitivity = gyrSensitivity;
    return result;
  }

  ResponseLSM6DSOXStart._();

  factory ResponseLSM6DSOXStart.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseLSM6DSOXStart.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseLSM6DSOXStart',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'accSensitivity',
        fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'gyrSensitivity',
        fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseLSM6DSOXStart clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseLSM6DSOXStart copyWith(
          void Function(ResponseLSM6DSOXStart) updates) =>
      super.copyWith((message) => updates(message as ResponseLSM6DSOXStart))
          as ResponseLSM6DSOXStart;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseLSM6DSOXStart create() => ResponseLSM6DSOXStart._();
  @$core.override
  ResponseLSM6DSOXStart createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseLSM6DSOXStart getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseLSM6DSOXStart>(create);
  static ResponseLSM6DSOXStart? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get accSensitivity => $_getN(0);
  @$pb.TagNumber(1)
  set accSensitivity($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccSensitivity() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccSensitivity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get gyrSensitivity => $_getN(1);
  @$pb.TagNumber(2)
  set gyrSensitivity($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGyrSensitivity() => $_has(1);
  @$pb.TagNumber(2)
  void clearGyrSensitivity() => $_clearField(2);
}

class RequestLSM6DSOXStop extends $pb.GeneratedMessage {
  factory RequestLSM6DSOXStop() => create();

  RequestLSM6DSOXStop._();

  factory RequestLSM6DSOXStop.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestLSM6DSOXStop.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestLSM6DSOXStop',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestLSM6DSOXStop clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestLSM6DSOXStop copyWith(void Function(RequestLSM6DSOXStop) updates) =>
      super.copyWith((message) => updates(message as RequestLSM6DSOXStop))
          as RequestLSM6DSOXStop;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestLSM6DSOXStop create() => RequestLSM6DSOXStop._();
  @$core.override
  RequestLSM6DSOXStop createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestLSM6DSOXStop getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestLSM6DSOXStop>(create);
  static RequestLSM6DSOXStop? _defaultInstance;
}

class ResponseLSM6DSOXStop extends $pb.GeneratedMessage {
  factory ResponseLSM6DSOXStop() => create();

  ResponseLSM6DSOXStop._();

  factory ResponseLSM6DSOXStop.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseLSM6DSOXStop.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseLSM6DSOXStop',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseLSM6DSOXStop clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseLSM6DSOXStop copyWith(void Function(ResponseLSM6DSOXStop) updates) =>
      super.copyWith((message) => updates(message as ResponseLSM6DSOXStop))
          as ResponseLSM6DSOXStop;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseLSM6DSOXStop create() => ResponseLSM6DSOXStop._();
  @$core.override
  ResponseLSM6DSOXStop createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseLSM6DSOXStop getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseLSM6DSOXStop>(create);
  static ResponseLSM6DSOXStop? _defaultInstance;
}

/// debug commands
class RequestDebugStm32DeepSleep extends $pb.GeneratedMessage {
  factory RequestDebugStm32DeepSleep() => create();

  RequestDebugStm32DeepSleep._();

  factory RequestDebugStm32DeepSleep.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestDebugStm32DeepSleep.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestDebugStm32DeepSleep',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestDebugStm32DeepSleep clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestDebugStm32DeepSleep copyWith(
          void Function(RequestDebugStm32DeepSleep) updates) =>
      super.copyWith(
              (message) => updates(message as RequestDebugStm32DeepSleep))
          as RequestDebugStm32DeepSleep;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestDebugStm32DeepSleep create() => RequestDebugStm32DeepSleep._();
  @$core.override
  RequestDebugStm32DeepSleep createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestDebugStm32DeepSleep getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestDebugStm32DeepSleep>(create);
  static RequestDebugStm32DeepSleep? _defaultInstance;
}

class ResponseDebugStm32DeepSleep extends $pb.GeneratedMessage {
  factory ResponseDebugStm32DeepSleep() => create();

  ResponseDebugStm32DeepSleep._();

  factory ResponseDebugStm32DeepSleep.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResponseDebugStm32DeepSleep.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResponseDebugStm32DeepSleep',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseDebugStm32DeepSleep clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResponseDebugStm32DeepSleep copyWith(
          void Function(ResponseDebugStm32DeepSleep) updates) =>
      super.copyWith(
              (message) => updates(message as ResponseDebugStm32DeepSleep))
          as ResponseDebugStm32DeepSleep;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResponseDebugStm32DeepSleep create() =>
      ResponseDebugStm32DeepSleep._();
  @$core.override
  ResponseDebugStm32DeepSleep createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResponseDebugStm32DeepSleep getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResponseDebugStm32DeepSleep>(create);
  static ResponseDebugStm32DeepSleep? _defaultInstance;
}

class RequestDebugEnterBootloader extends $pb.GeneratedMessage {
  factory RequestDebugEnterBootloader() => create();

  RequestDebugEnterBootloader._();

  factory RequestDebugEnterBootloader.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestDebugEnterBootloader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestDebugEnterBootloader',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestDebugEnterBootloader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestDebugEnterBootloader copyWith(
          void Function(RequestDebugEnterBootloader) updates) =>
      super.copyWith(
              (message) => updates(message as RequestDebugEnterBootloader))
          as RequestDebugEnterBootloader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestDebugEnterBootloader create() =>
      RequestDebugEnterBootloader._();
  @$core.override
  RequestDebugEnterBootloader createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestDebugEnterBootloader getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestDebugEnterBootloader>(create);
  static RequestDebugEnterBootloader? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
