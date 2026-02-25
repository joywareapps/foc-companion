// This is a generated file - do not edit.
//
// Generated from notifications.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class NotificationBoot extends $pb.GeneratedMessage {
  factory NotificationBoot() => create();

  NotificationBoot._();

  factory NotificationBoot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationBoot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationBoot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationBoot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationBoot copyWith(void Function(NotificationBoot) updates) =>
      super.copyWith((message) => updates(message as NotificationBoot))
          as NotificationBoot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationBoot create() => NotificationBoot._();
  @$core.override
  NotificationBoot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationBoot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationBoot>(create);
  static NotificationBoot? _defaultInstance;
}

class NotificationPotentiometer extends $pb.GeneratedMessage {
  factory NotificationPotentiometer({
    $core.double? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  NotificationPotentiometer._();

  factory NotificationPotentiometer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationPotentiometer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationPotentiometer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'value', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationPotentiometer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationPotentiometer copyWith(
          void Function(NotificationPotentiometer) updates) =>
      super.copyWith((message) => updates(message as NotificationPotentiometer))
          as NotificationPotentiometer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationPotentiometer create() => NotificationPotentiometer._();
  @$core.override
  NotificationPotentiometer createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationPotentiometer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationPotentiometer>(create);
  static NotificationPotentiometer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class NotificationButtonPress extends $pb.GeneratedMessage {
  factory NotificationButtonPress({
    $core.bool? pressed,
  }) {
    final result = create();
    if (pressed != null) result.pressed = pressed;
    return result;
  }

  NotificationButtonPress._();

  factory NotificationButtonPress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationButtonPress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationButtonPress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'pressed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationButtonPress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationButtonPress copyWith(
          void Function(NotificationButtonPress) updates) =>
      super.copyWith((message) => updates(message as NotificationButtonPress))
          as NotificationButtonPress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationButtonPress create() => NotificationButtonPress._();
  @$core.override
  NotificationButtonPress createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationButtonPress getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationButtonPress>(create);
  static NotificationButtonPress? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get pressed => $_getBF(0);
  @$pb.TagNumber(1)
  set pressed($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPressed() => $_has(0);
  @$pb.TagNumber(1)
  void clearPressed() => $_clearField(1);
}

class NotificationDeviceState extends $pb.GeneratedMessage {
  factory NotificationDeviceState({
    $core.bool? volumeLocked,
  }) {
    final result = create();
    if (volumeLocked != null) result.volumeLocked = volumeLocked;
    return result;
  }

  NotificationDeviceState._();

  factory NotificationDeviceState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationDeviceState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationDeviceState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'volumeLocked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDeviceState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDeviceState copyWith(
          void Function(NotificationDeviceState) updates) =>
      super.copyWith((message) => updates(message as NotificationDeviceState))
          as NotificationDeviceState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationDeviceState create() => NotificationDeviceState._();
  @$core.override
  NotificationDeviceState createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationDeviceState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationDeviceState>(create);
  static NotificationDeviceState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get volumeLocked => $_getBF(0);
  @$pb.TagNumber(1)
  set volumeLocked($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVolumeLocked() => $_has(0);
  @$pb.TagNumber(1)
  void clearVolumeLocked() => $_clearField(1);
}

class NotificationCurrents extends $pb.GeneratedMessage {
  factory NotificationCurrents({
    $core.double? rmsA,
    $core.double? rmsB,
    $core.double? rmsC,
    $core.double? rmsD,
    $core.double? peakA,
    $core.double? peakB,
    $core.double? peakC,
    $core.double? peakD,
    $core.double? outputPower,
    $core.double? outputPowerSkin,
    $core.double? peakCmd,
  }) {
    final result = create();
    if (rmsA != null) result.rmsA = rmsA;
    if (rmsB != null) result.rmsB = rmsB;
    if (rmsC != null) result.rmsC = rmsC;
    if (rmsD != null) result.rmsD = rmsD;
    if (peakA != null) result.peakA = peakA;
    if (peakB != null) result.peakB = peakB;
    if (peakC != null) result.peakC = peakC;
    if (peakD != null) result.peakD = peakD;
    if (outputPower != null) result.outputPower = outputPower;
    if (outputPowerSkin != null) result.outputPowerSkin = outputPowerSkin;
    if (peakCmd != null) result.peakCmd = peakCmd;
    return result;
  }

  NotificationCurrents._();

  factory NotificationCurrents.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationCurrents.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationCurrents',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'rmsA', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'rmsB', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'rmsC', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'rmsD', fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'peakA', fieldType: $pb.PbFieldType.OF)
    ..aD(6, _omitFieldNames ? '' : 'peakB', fieldType: $pb.PbFieldType.OF)
    ..aD(7, _omitFieldNames ? '' : 'peakC', fieldType: $pb.PbFieldType.OF)
    ..aD(8, _omitFieldNames ? '' : 'peakD', fieldType: $pb.PbFieldType.OF)
    ..aD(9, _omitFieldNames ? '' : 'outputPower', fieldType: $pb.PbFieldType.OF)
    ..aD(10, _omitFieldNames ? '' : 'outputPowerSkin',
        fieldType: $pb.PbFieldType.OF)
    ..aD(11, _omitFieldNames ? '' : 'peakCmd', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationCurrents clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationCurrents copyWith(void Function(NotificationCurrents) updates) =>
      super.copyWith((message) => updates(message as NotificationCurrents))
          as NotificationCurrents;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationCurrents create() => NotificationCurrents._();
  @$core.override
  NotificationCurrents createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationCurrents getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationCurrents>(create);
  static NotificationCurrents? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get rmsA => $_getN(0);
  @$pb.TagNumber(1)
  set rmsA($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRmsA() => $_has(0);
  @$pb.TagNumber(1)
  void clearRmsA() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get rmsB => $_getN(1);
  @$pb.TagNumber(2)
  set rmsB($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRmsB() => $_has(1);
  @$pb.TagNumber(2)
  void clearRmsB() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get rmsC => $_getN(2);
  @$pb.TagNumber(3)
  set rmsC($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRmsC() => $_has(2);
  @$pb.TagNumber(3)
  void clearRmsC() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get rmsD => $_getN(3);
  @$pb.TagNumber(4)
  set rmsD($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRmsD() => $_has(3);
  @$pb.TagNumber(4)
  void clearRmsD() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get peakA => $_getN(4);
  @$pb.TagNumber(5)
  set peakA($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPeakA() => $_has(4);
  @$pb.TagNumber(5)
  void clearPeakA() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get peakB => $_getN(5);
  @$pb.TagNumber(6)
  set peakB($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPeakB() => $_has(5);
  @$pb.TagNumber(6)
  void clearPeakB() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get peakC => $_getN(6);
  @$pb.TagNumber(7)
  set peakC($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPeakC() => $_has(6);
  @$pb.TagNumber(7)
  void clearPeakC() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get peakD => $_getN(7);
  @$pb.TagNumber(8)
  set peakD($core.double value) => $_setFloat(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPeakD() => $_has(7);
  @$pb.TagNumber(8)
  void clearPeakD() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get outputPower => $_getN(8);
  @$pb.TagNumber(9)
  set outputPower($core.double value) => $_setFloat(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOutputPower() => $_has(8);
  @$pb.TagNumber(9)
  void clearOutputPower() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get outputPowerSkin => $_getN(9);
  @$pb.TagNumber(10)
  set outputPowerSkin($core.double value) => $_setFloat(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOutputPowerSkin() => $_has(9);
  @$pb.TagNumber(10)
  void clearOutputPowerSkin() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get peakCmd => $_getN(10);
  @$pb.TagNumber(11)
  set peakCmd($core.double value) => $_setFloat(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPeakCmd() => $_has(10);
  @$pb.TagNumber(11)
  void clearPeakCmd() => $_clearField(11);
}

class NotificationModelEstimation extends $pb.GeneratedMessage {
  factory NotificationModelEstimation({
    $core.double? resistanceA,
    $core.double? reluctanceA,
    $core.double? resistanceB,
    $core.double? reluctanceB,
    $core.double? resistanceC,
    $core.double? reluctanceC,
    $core.double? resistanceD,
    $core.double? reluctanceD,
    $core.double? constant,
  }) {
    final result = create();
    if (resistanceA != null) result.resistanceA = resistanceA;
    if (reluctanceA != null) result.reluctanceA = reluctanceA;
    if (resistanceB != null) result.resistanceB = resistanceB;
    if (reluctanceB != null) result.reluctanceB = reluctanceB;
    if (resistanceC != null) result.resistanceC = resistanceC;
    if (reluctanceC != null) result.reluctanceC = reluctanceC;
    if (resistanceD != null) result.resistanceD = resistanceD;
    if (reluctanceD != null) result.reluctanceD = reluctanceD;
    if (constant != null) result.constant = constant;
    return result;
  }

  NotificationModelEstimation._();

  factory NotificationModelEstimation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationModelEstimation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationModelEstimation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'resistanceA', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'reluctanceA', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'resistanceB', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'reluctanceB', fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'resistanceC', fieldType: $pb.PbFieldType.OF)
    ..aD(6, _omitFieldNames ? '' : 'reluctanceC', fieldType: $pb.PbFieldType.OF)
    ..aD(7, _omitFieldNames ? '' : 'resistanceD', fieldType: $pb.PbFieldType.OF)
    ..aD(8, _omitFieldNames ? '' : 'reluctanceD', fieldType: $pb.PbFieldType.OF)
    ..aD(20, _omitFieldNames ? '' : 'constant', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationModelEstimation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationModelEstimation copyWith(
          void Function(NotificationModelEstimation) updates) =>
      super.copyWith(
              (message) => updates(message as NotificationModelEstimation))
          as NotificationModelEstimation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationModelEstimation create() =>
      NotificationModelEstimation._();
  @$core.override
  NotificationModelEstimation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationModelEstimation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationModelEstimation>(create);
  static NotificationModelEstimation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get resistanceA => $_getN(0);
  @$pb.TagNumber(1)
  set resistanceA($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResistanceA() => $_has(0);
  @$pb.TagNumber(1)
  void clearResistanceA() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get reluctanceA => $_getN(1);
  @$pb.TagNumber(2)
  set reluctanceA($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReluctanceA() => $_has(1);
  @$pb.TagNumber(2)
  void clearReluctanceA() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get resistanceB => $_getN(2);
  @$pb.TagNumber(3)
  set resistanceB($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasResistanceB() => $_has(2);
  @$pb.TagNumber(3)
  void clearResistanceB() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get reluctanceB => $_getN(3);
  @$pb.TagNumber(4)
  set reluctanceB($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReluctanceB() => $_has(3);
  @$pb.TagNumber(4)
  void clearReluctanceB() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get resistanceC => $_getN(4);
  @$pb.TagNumber(5)
  set resistanceC($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasResistanceC() => $_has(4);
  @$pb.TagNumber(5)
  void clearResistanceC() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get reluctanceC => $_getN(5);
  @$pb.TagNumber(6)
  set reluctanceC($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReluctanceC() => $_has(5);
  @$pb.TagNumber(6)
  void clearReluctanceC() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get resistanceD => $_getN(6);
  @$pb.TagNumber(7)
  set resistanceD($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasResistanceD() => $_has(6);
  @$pb.TagNumber(7)
  void clearResistanceD() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get reluctanceD => $_getN(7);
  @$pb.TagNumber(8)
  set reluctanceD($core.double value) => $_setFloat(7, value);
  @$pb.TagNumber(8)
  $core.bool hasReluctanceD() => $_has(7);
  @$pb.TagNumber(8)
  void clearReluctanceD() => $_clearField(8);

  @$pb.TagNumber(20)
  $core.double get constant => $_getN(8);
  @$pb.TagNumber(20)
  set constant($core.double value) => $_setFloat(8, value);
  @$pb.TagNumber(20)
  $core.bool hasConstant() => $_has(8);
  @$pb.TagNumber(20)
  void clearConstant() => $_clearField(20);
}

class SystemStatsESC1 extends $pb.GeneratedMessage {
  factory SystemStatsESC1({
    $core.double? tempStm32,
    $core.double? tempBoard,
    $core.double? vBus,
    $core.double? vRef,
  }) {
    final result = create();
    if (tempStm32 != null) result.tempStm32 = tempStm32;
    if (tempBoard != null) result.tempBoard = tempBoard;
    if (vBus != null) result.vBus = vBus;
    if (vRef != null) result.vRef = vRef;
    return result;
  }

  SystemStatsESC1._();

  factory SystemStatsESC1.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SystemStatsESC1.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SystemStatsESC1',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'tempStm32', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'tempBoard', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'vBus', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'vRef', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemStatsESC1 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemStatsESC1 copyWith(void Function(SystemStatsESC1) updates) =>
      super.copyWith((message) => updates(message as SystemStatsESC1))
          as SystemStatsESC1;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemStatsESC1 create() => SystemStatsESC1._();
  @$core.override
  SystemStatsESC1 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SystemStatsESC1 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SystemStatsESC1>(create);
  static SystemStatsESC1? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get tempStm32 => $_getN(0);
  @$pb.TagNumber(1)
  set tempStm32($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTempStm32() => $_has(0);
  @$pb.TagNumber(1)
  void clearTempStm32() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get tempBoard => $_getN(1);
  @$pb.TagNumber(2)
  set tempBoard($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTempBoard() => $_has(1);
  @$pb.TagNumber(2)
  void clearTempBoard() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get vBus => $_getN(2);
  @$pb.TagNumber(3)
  set vBus($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVBus() => $_has(2);
  @$pb.TagNumber(3)
  void clearVBus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get vRef => $_getN(3);
  @$pb.TagNumber(4)
  set vRef($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVRef() => $_has(3);
  @$pb.TagNumber(4)
  void clearVRef() => $_clearField(4);
}

class SystemStatsFocstimV3 extends $pb.GeneratedMessage {
  factory SystemStatsFocstimV3({
    $core.double? tempStm32,
    $core.double? vSysMin,
    $core.double? vRef,
    $core.double? vBoostMin,
    $core.double? boostDutyCycle,
    $core.double? vSysMax,
    $core.double? vBoostMax,
  }) {
    final result = create();
    if (tempStm32 != null) result.tempStm32 = tempStm32;
    if (vSysMin != null) result.vSysMin = vSysMin;
    if (vRef != null) result.vRef = vRef;
    if (vBoostMin != null) result.vBoostMin = vBoostMin;
    if (boostDutyCycle != null) result.boostDutyCycle = boostDutyCycle;
    if (vSysMax != null) result.vSysMax = vSysMax;
    if (vBoostMax != null) result.vBoostMax = vBoostMax;
    return result;
  }

  SystemStatsFocstimV3._();

  factory SystemStatsFocstimV3.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SystemStatsFocstimV3.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SystemStatsFocstimV3',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'tempStm32', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'vSysMin', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'vRef', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'vBoostMin', fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'boostDutyCycle',
        fieldType: $pb.PbFieldType.OF)
    ..aD(6, _omitFieldNames ? '' : 'vSysMax', fieldType: $pb.PbFieldType.OF)
    ..aD(7, _omitFieldNames ? '' : 'vBoostMax', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemStatsFocstimV3 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemStatsFocstimV3 copyWith(void Function(SystemStatsFocstimV3) updates) =>
      super.copyWith((message) => updates(message as SystemStatsFocstimV3))
          as SystemStatsFocstimV3;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemStatsFocstimV3 create() => SystemStatsFocstimV3._();
  @$core.override
  SystemStatsFocstimV3 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SystemStatsFocstimV3 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SystemStatsFocstimV3>(create);
  static SystemStatsFocstimV3? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get tempStm32 => $_getN(0);
  @$pb.TagNumber(1)
  set tempStm32($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTempStm32() => $_has(0);
  @$pb.TagNumber(1)
  void clearTempStm32() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get vSysMin => $_getN(1);
  @$pb.TagNumber(2)
  set vSysMin($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVSysMin() => $_has(1);
  @$pb.TagNumber(2)
  void clearVSysMin() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get vRef => $_getN(2);
  @$pb.TagNumber(3)
  set vRef($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVRef() => $_has(2);
  @$pb.TagNumber(3)
  void clearVRef() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get vBoostMin => $_getN(3);
  @$pb.TagNumber(4)
  set vBoostMin($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVBoostMin() => $_has(3);
  @$pb.TagNumber(4)
  void clearVBoostMin() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get boostDutyCycle => $_getN(4);
  @$pb.TagNumber(5)
  set boostDutyCycle($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBoostDutyCycle() => $_has(4);
  @$pb.TagNumber(5)
  void clearBoostDutyCycle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get vSysMax => $_getN(5);
  @$pb.TagNumber(6)
  set vSysMax($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVSysMax() => $_has(5);
  @$pb.TagNumber(6)
  void clearVSysMax() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get vBoostMax => $_getN(6);
  @$pb.TagNumber(7)
  set vBoostMax($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVBoostMax() => $_has(6);
  @$pb.TagNumber(7)
  void clearVBoostMax() => $_clearField(7);
}

enum NotificationSystemStats_System { esc1, focstimv3, notSet }

class NotificationSystemStats extends $pb.GeneratedMessage {
  factory NotificationSystemStats({
    SystemStatsESC1? esc1,
    SystemStatsFocstimV3? focstimv3,
  }) {
    final result = create();
    if (esc1 != null) result.esc1 = esc1;
    if (focstimv3 != null) result.focstimv3 = focstimv3;
    return result;
  }

  NotificationSystemStats._();

  factory NotificationSystemStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationSystemStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, NotificationSystemStats_System>
      _NotificationSystemStats_SystemByTag = {
    1: NotificationSystemStats_System.esc1,
    2: NotificationSystemStats_System.focstimv3,
    0: NotificationSystemStats_System.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationSystemStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SystemStatsESC1>(1, _omitFieldNames ? '' : 'esc1',
        subBuilder: SystemStatsESC1.create)
    ..aOM<SystemStatsFocstimV3>(2, _omitFieldNames ? '' : 'focstimv3',
        subBuilder: SystemStatsFocstimV3.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSystemStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSystemStats copyWith(
          void Function(NotificationSystemStats) updates) =>
      super.copyWith((message) => updates(message as NotificationSystemStats))
          as NotificationSystemStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationSystemStats create() => NotificationSystemStats._();
  @$core.override
  NotificationSystemStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationSystemStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationSystemStats>(create);
  static NotificationSystemStats? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  NotificationSystemStats_System whichSystem() =>
      _NotificationSystemStats_SystemByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearSystem() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SystemStatsESC1 get esc1 => $_getN(0);
  @$pb.TagNumber(1)
  set esc1(SystemStatsESC1 value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEsc1() => $_has(0);
  @$pb.TagNumber(1)
  void clearEsc1() => $_clearField(1);
  @$pb.TagNumber(1)
  SystemStatsESC1 ensureEsc1() => $_ensure(0);

  @$pb.TagNumber(2)
  SystemStatsFocstimV3 get focstimv3 => $_getN(1);
  @$pb.TagNumber(2)
  set focstimv3(SystemStatsFocstimV3 value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFocstimv3() => $_has(1);
  @$pb.TagNumber(2)
  void clearFocstimv3() => $_clearField(2);
  @$pb.TagNumber(2)
  SystemStatsFocstimV3 ensureFocstimv3() => $_ensure(1);
}

class NotificationSignalStats extends $pb.GeneratedMessage {
  factory NotificationSignalStats({
    $core.double? actualPulseFrequency,
    $core.double? vDrive,
  }) {
    final result = create();
    if (actualPulseFrequency != null)
      result.actualPulseFrequency = actualPulseFrequency;
    if (vDrive != null) result.vDrive = vDrive;
    return result;
  }

  NotificationSignalStats._();

  factory NotificationSignalStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationSignalStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationSignalStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'actualPulseFrequency',
        fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'vDrive', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSignalStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSignalStats copyWith(
          void Function(NotificationSignalStats) updates) =>
      super.copyWith((message) => updates(message as NotificationSignalStats))
          as NotificationSignalStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationSignalStats create() => NotificationSignalStats._();
  @$core.override
  NotificationSignalStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationSignalStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationSignalStats>(create);
  static NotificationSignalStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get actualPulseFrequency => $_getN(0);
  @$pb.TagNumber(1)
  set actualPulseFrequency($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActualPulseFrequency() => $_has(0);
  @$pb.TagNumber(1)
  void clearActualPulseFrequency() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get vDrive => $_getN(1);
  @$pb.TagNumber(2)
  set vDrive($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVDrive() => $_has(1);
  @$pb.TagNumber(2)
  void clearVDrive() => $_clearField(2);
}

class NotificationBattery extends $pb.GeneratedMessage {
  factory NotificationBattery({
    $core.double? batteryVoltage,
    $core.double? batteryChargeRateWatt,
    $core.double? batterySoc,
    $core.bool? wallPowerPresent,
    $core.double? chipTemperature,
  }) {
    final result = create();
    if (batteryVoltage != null) result.batteryVoltage = batteryVoltage;
    if (batteryChargeRateWatt != null)
      result.batteryChargeRateWatt = batteryChargeRateWatt;
    if (batterySoc != null) result.batterySoc = batterySoc;
    if (wallPowerPresent != null) result.wallPowerPresent = wallPowerPresent;
    if (chipTemperature != null) result.chipTemperature = chipTemperature;
    return result;
  }

  NotificationBattery._();

  factory NotificationBattery.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationBattery.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationBattery',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'batteryVoltage',
        fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'batteryChargeRateWatt',
        fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'batterySoc', fieldType: $pb.PbFieldType.OF)
    ..aOB(4, _omitFieldNames ? '' : 'wallPowerPresent')
    ..aD(5, _omitFieldNames ? '' : 'chipTemperature',
        fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationBattery clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationBattery copyWith(void Function(NotificationBattery) updates) =>
      super.copyWith((message) => updates(message as NotificationBattery))
          as NotificationBattery;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationBattery create() => NotificationBattery._();
  @$core.override
  NotificationBattery createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationBattery getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationBattery>(create);
  static NotificationBattery? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get batteryVoltage => $_getN(0);
  @$pb.TagNumber(1)
  set batteryVoltage($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBatteryVoltage() => $_has(0);
  @$pb.TagNumber(1)
  void clearBatteryVoltage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get batteryChargeRateWatt => $_getN(1);
  @$pb.TagNumber(2)
  set batteryChargeRateWatt($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBatteryChargeRateWatt() => $_has(1);
  @$pb.TagNumber(2)
  void clearBatteryChargeRateWatt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get batterySoc => $_getN(2);
  @$pb.TagNumber(3)
  set batterySoc($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBatterySoc() => $_has(2);
  @$pb.TagNumber(3)
  void clearBatterySoc() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get wallPowerPresent => $_getBF(3);
  @$pb.TagNumber(4)
  set wallPowerPresent($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWallPowerPresent() => $_has(3);
  @$pb.TagNumber(4)
  void clearWallPowerPresent() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get chipTemperature => $_getN(4);
  @$pb.TagNumber(5)
  set chipTemperature($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasChipTemperature() => $_has(4);
  @$pb.TagNumber(5)
  void clearChipTemperature() => $_clearField(5);
}

class NotificationLSM6DSOX extends $pb.GeneratedMessage {
  factory NotificationLSM6DSOX({
    $core.int? accX,
    $core.int? accY,
    $core.int? accZ,
    $core.int? gyrX,
    $core.int? gyrY,
    $core.int? gyrZ,
  }) {
    final result = create();
    if (accX != null) result.accX = accX;
    if (accY != null) result.accY = accY;
    if (accZ != null) result.accZ = accZ;
    if (gyrX != null) result.gyrX = gyrX;
    if (gyrY != null) result.gyrY = gyrY;
    if (gyrZ != null) result.gyrZ = gyrZ;
    return result;
  }

  NotificationLSM6DSOX._();

  factory NotificationLSM6DSOX.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationLSM6DSOX.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationLSM6DSOX',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'accX', fieldType: $pb.PbFieldType.OS3)
    ..aI(2, _omitFieldNames ? '' : 'accY', fieldType: $pb.PbFieldType.OS3)
    ..aI(3, _omitFieldNames ? '' : 'accZ', fieldType: $pb.PbFieldType.OS3)
    ..aI(4, _omitFieldNames ? '' : 'gyrX', fieldType: $pb.PbFieldType.OS3)
    ..aI(5, _omitFieldNames ? '' : 'gyrY', fieldType: $pb.PbFieldType.OS3)
    ..aI(6, _omitFieldNames ? '' : 'gyrZ', fieldType: $pb.PbFieldType.OS3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationLSM6DSOX clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationLSM6DSOX copyWith(void Function(NotificationLSM6DSOX) updates) =>
      super.copyWith((message) => updates(message as NotificationLSM6DSOX))
          as NotificationLSM6DSOX;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationLSM6DSOX create() => NotificationLSM6DSOX._();
  @$core.override
  NotificationLSM6DSOX createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationLSM6DSOX getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationLSM6DSOX>(create);
  static NotificationLSM6DSOX? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get accX => $_getIZ(0);
  @$pb.TagNumber(1)
  set accX($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccX() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get accY => $_getIZ(1);
  @$pb.TagNumber(2)
  set accY($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccY() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccY() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get accZ => $_getIZ(2);
  @$pb.TagNumber(3)
  set accZ($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccZ() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccZ() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get gyrX => $_getIZ(3);
  @$pb.TagNumber(4)
  set gyrX($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGyrX() => $_has(3);
  @$pb.TagNumber(4)
  void clearGyrX() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get gyrY => $_getIZ(4);
  @$pb.TagNumber(5)
  set gyrY($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGyrY() => $_has(4);
  @$pb.TagNumber(5)
  void clearGyrY() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get gyrZ => $_getIZ(5);
  @$pb.TagNumber(6)
  set gyrZ($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGyrZ() => $_has(5);
  @$pb.TagNumber(6)
  void clearGyrZ() => $_clearField(6);
}

class NotificationPressure extends $pb.GeneratedMessage {
  factory NotificationPressure({
    $core.double? pressure,
  }) {
    final result = create();
    if (pressure != null) result.pressure = pressure;
    return result;
  }

  NotificationPressure._();

  factory NotificationPressure.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationPressure.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationPressure',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'pressure', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationPressure clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationPressure copyWith(void Function(NotificationPressure) updates) =>
      super.copyWith((message) => updates(message as NotificationPressure))
          as NotificationPressure;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationPressure create() => NotificationPressure._();
  @$core.override
  NotificationPressure createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationPressure getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationPressure>(create);
  static NotificationPressure? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get pressure => $_getN(0);
  @$pb.TagNumber(1)
  set pressure($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPressure() => $_has(0);
  @$pb.TagNumber(1)
  void clearPressure() => $_clearField(1);
}

class NotificationDebugString extends $pb.GeneratedMessage {
  factory NotificationDebugString({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  NotificationDebugString._();

  factory NotificationDebugString.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationDebugString.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationDebugString',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDebugString clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDebugString copyWith(
          void Function(NotificationDebugString) updates) =>
      super.copyWith((message) => updates(message as NotificationDebugString))
          as NotificationDebugString;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationDebugString create() => NotificationDebugString._();
  @$core.override
  NotificationDebugString createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationDebugString getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationDebugString>(create);
  static NotificationDebugString? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class NotificationDebugAS5311 extends $pb.GeneratedMessage {
  factory NotificationDebugAS5311({
    $core.int? raw,
    $core.int? tracked,
    $core.int? flags,
  }) {
    final result = create();
    if (raw != null) result.raw = raw;
    if (tracked != null) result.tracked = tracked;
    if (flags != null) result.flags = flags;
    return result;
  }

  NotificationDebugAS5311._();

  factory NotificationDebugAS5311.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationDebugAS5311.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationDebugAS5311',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'raw')
    ..aI(2, _omitFieldNames ? '' : 'tracked', fieldType: $pb.PbFieldType.OS3)
    ..aI(3, _omitFieldNames ? '' : 'flags')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDebugAS5311 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDebugAS5311 copyWith(
          void Function(NotificationDebugAS5311) updates) =>
      super.copyWith((message) => updates(message as NotificationDebugAS5311))
          as NotificationDebugAS5311;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationDebugAS5311 create() => NotificationDebugAS5311._();
  @$core.override
  NotificationDebugAS5311 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationDebugAS5311 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationDebugAS5311>(create);
  static NotificationDebugAS5311? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get raw => $_getIZ(0);
  @$pb.TagNumber(1)
  set raw($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRaw() => $_has(0);
  @$pb.TagNumber(1)
  void clearRaw() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get tracked => $_getIZ(1);
  @$pb.TagNumber(2)
  set tracked($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTracked() => $_has(1);
  @$pb.TagNumber(2)
  void clearTracked() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get flags => $_getIZ(2);
  @$pb.TagNumber(3)
  set flags($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFlags() => $_has(2);
  @$pb.TagNumber(3)
  void clearFlags() => $_clearField(3);
}

/// only abused for debug within logging in restim
class NotificationDebugEdging extends $pb.GeneratedMessage {
  factory NotificationDebugEdging({
    $core.double? fullPowerThreshold,
    $core.double? reducedPowerThreshold,
    $core.double? reduction,
  }) {
    final result = create();
    if (fullPowerThreshold != null)
      result.fullPowerThreshold = fullPowerThreshold;
    if (reducedPowerThreshold != null)
      result.reducedPowerThreshold = reducedPowerThreshold;
    if (reduction != null) result.reduction = reduction;
    return result;
  }

  NotificationDebugEdging._();

  factory NotificationDebugEdging.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationDebugEdging.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationDebugEdging',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'fullPowerThreshold',
        fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'reducedPowerThreshold',
        fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'reduction', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDebugEdging clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationDebugEdging copyWith(
          void Function(NotificationDebugEdging) updates) =>
      super.copyWith((message) => updates(message as NotificationDebugEdging))
          as NotificationDebugEdging;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationDebugEdging create() => NotificationDebugEdging._();
  @$core.override
  NotificationDebugEdging createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationDebugEdging getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationDebugEdging>(create);
  static NotificationDebugEdging? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get fullPowerThreshold => $_getN(0);
  @$pb.TagNumber(1)
  set fullPowerThreshold($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFullPowerThreshold() => $_has(0);
  @$pb.TagNumber(1)
  void clearFullPowerThreshold() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get reducedPowerThreshold => $_getN(1);
  @$pb.TagNumber(2)
  set reducedPowerThreshold($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReducedPowerThreshold() => $_has(1);
  @$pb.TagNumber(2)
  void clearReducedPowerThreshold() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get reduction => $_getN(2);
  @$pb.TagNumber(3)
  set reduction($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReduction() => $_has(2);
  @$pb.TagNumber(3)
  void clearReduction() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
