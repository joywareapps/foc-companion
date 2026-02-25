// This is a generated file - do not edit.
//
// Generated from focstim_rpc.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'constants.pbenum.dart' as $2;
import 'messages.pb.dart' as $1;
import 'notifications.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

enum Notification_Notification {
  notificationBoot,
  notificationPotentiometer,
  notificationCurrents,
  notificationModelEstimation,
  notificationSystemStats,
  notificationSignalStats,
  notificationBattery,
  notificationLsm6dsox,
  notificationPressure,
  notificationButtonPress,
  notificationDebugString,
  notificationDebugAs5311,
  notificationDebugEdging,
  notSet
}

class Notification extends $pb.GeneratedMessage {
  factory Notification({
    $0.NotificationBoot? notificationBoot,
    $0.NotificationPotentiometer? notificationPotentiometer,
    $0.NotificationCurrents? notificationCurrents,
    $0.NotificationModelEstimation? notificationModelEstimation,
    $0.NotificationSystemStats? notificationSystemStats,
    $0.NotificationSignalStats? notificationSignalStats,
    $0.NotificationBattery? notificationBattery,
    $0.NotificationLSM6DSOX? notificationLsm6dsox,
    $0.NotificationPressure? notificationPressure,
    $0.NotificationButtonPress? notificationButtonPress,
    $fixnum.Int64? timestamp,
    $0.NotificationDebugString? notificationDebugString,
    $0.NotificationDebugAS5311? notificationDebugAs5311,
    $0.NotificationDebugEdging? notificationDebugEdging,
  }) {
    final result = create();
    if (notificationBoot != null) result.notificationBoot = notificationBoot;
    if (notificationPotentiometer != null)
      result.notificationPotentiometer = notificationPotentiometer;
    if (notificationCurrents != null)
      result.notificationCurrents = notificationCurrents;
    if (notificationModelEstimation != null)
      result.notificationModelEstimation = notificationModelEstimation;
    if (notificationSystemStats != null)
      result.notificationSystemStats = notificationSystemStats;
    if (notificationSignalStats != null)
      result.notificationSignalStats = notificationSignalStats;
    if (notificationBattery != null)
      result.notificationBattery = notificationBattery;
    if (notificationLsm6dsox != null)
      result.notificationLsm6dsox = notificationLsm6dsox;
    if (notificationPressure != null)
      result.notificationPressure = notificationPressure;
    if (notificationButtonPress != null)
      result.notificationButtonPress = notificationButtonPress;
    if (timestamp != null) result.timestamp = timestamp;
    if (notificationDebugString != null)
      result.notificationDebugString = notificationDebugString;
    if (notificationDebugAs5311 != null)
      result.notificationDebugAs5311 = notificationDebugAs5311;
    if (notificationDebugEdging != null)
      result.notificationDebugEdging = notificationDebugEdging;
    return result;
  }

  Notification._();

  factory Notification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Notification_Notification>
      _Notification_NotificationByTag = {
    1: Notification_Notification.notificationBoot,
    2: Notification_Notification.notificationPotentiometer,
    3: Notification_Notification.notificationCurrents,
    4: Notification_Notification.notificationModelEstimation,
    5: Notification_Notification.notificationSystemStats,
    6: Notification_Notification.notificationSignalStats,
    7: Notification_Notification.notificationBattery,
    8: Notification_Notification.notificationLsm6dsox,
    9: Notification_Notification.notificationPressure,
    10: Notification_Notification.notificationButtonPress,
    1000: Notification_Notification.notificationDebugString,
    1001: Notification_Notification.notificationDebugAs5311,
    1002: Notification_Notification.notificationDebugEdging,
    0: Notification_Notification.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1000, 1001, 1002])
    ..aOM<$0.NotificationBoot>(1, _omitFieldNames ? '' : 'notificationBoot',
        subBuilder: $0.NotificationBoot.create)
    ..aOM<$0.NotificationPotentiometer>(
        2, _omitFieldNames ? '' : 'notificationPotentiometer',
        subBuilder: $0.NotificationPotentiometer.create)
    ..aOM<$0.NotificationCurrents>(
        3, _omitFieldNames ? '' : 'notificationCurrents',
        subBuilder: $0.NotificationCurrents.create)
    ..aOM<$0.NotificationModelEstimation>(
        4, _omitFieldNames ? '' : 'notificationModelEstimation',
        subBuilder: $0.NotificationModelEstimation.create)
    ..aOM<$0.NotificationSystemStats>(
        5, _omitFieldNames ? '' : 'notificationSystemStats',
        subBuilder: $0.NotificationSystemStats.create)
    ..aOM<$0.NotificationSignalStats>(
        6, _omitFieldNames ? '' : 'notificationSignalStats',
        subBuilder: $0.NotificationSignalStats.create)
    ..aOM<$0.NotificationBattery>(
        7, _omitFieldNames ? '' : 'notificationBattery',
        subBuilder: $0.NotificationBattery.create)
    ..aOM<$0.NotificationLSM6DSOX>(
        8, _omitFieldNames ? '' : 'notificationLsm6dsox',
        subBuilder: $0.NotificationLSM6DSOX.create)
    ..aOM<$0.NotificationPressure>(
        9, _omitFieldNames ? '' : 'notificationPressure',
        subBuilder: $0.NotificationPressure.create)
    ..aOM<$0.NotificationButtonPress>(
        10, _omitFieldNames ? '' : 'notificationButtonPress',
        subBuilder: $0.NotificationButtonPress.create)
    ..a<$fixnum.Int64>(
        999, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.NotificationDebugString>(
        1000, _omitFieldNames ? '' : 'notificationDebugString',
        subBuilder: $0.NotificationDebugString.create)
    ..aOM<$0.NotificationDebugAS5311>(
        1001, _omitFieldNames ? '' : 'notificationDebugAs5311',
        subBuilder: $0.NotificationDebugAS5311.create)
    ..aOM<$0.NotificationDebugEdging>(
        1002, _omitFieldNames ? '' : 'notificationDebugEdging',
        subBuilder: $0.NotificationDebugEdging.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification copyWith(void Function(Notification) updates) =>
      super.copyWith((message) => updates(message as Notification))
          as Notification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification create() => Notification._();
  @$core.override
  Notification createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notification>(create);
  static Notification? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(1000)
  @$pb.TagNumber(1001)
  @$pb.TagNumber(1002)
  Notification_Notification whichNotification() =>
      _Notification_NotificationByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(1000)
  @$pb.TagNumber(1001)
  @$pb.TagNumber(1002)
  void clearNotification() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $0.NotificationBoot get notificationBoot => $_getN(0);
  @$pb.TagNumber(1)
  set notificationBoot($0.NotificationBoot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNotificationBoot() => $_has(0);
  @$pb.TagNumber(1)
  void clearNotificationBoot() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.NotificationBoot ensureNotificationBoot() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.NotificationPotentiometer get notificationPotentiometer => $_getN(1);
  @$pb.TagNumber(2)
  set notificationPotentiometer($0.NotificationPotentiometer value) =>
      $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNotificationPotentiometer() => $_has(1);
  @$pb.TagNumber(2)
  void clearNotificationPotentiometer() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.NotificationPotentiometer ensureNotificationPotentiometer() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.NotificationCurrents get notificationCurrents => $_getN(2);
  @$pb.TagNumber(3)
  set notificationCurrents($0.NotificationCurrents value) =>
      $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasNotificationCurrents() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotificationCurrents() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.NotificationCurrents ensureNotificationCurrents() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.NotificationModelEstimation get notificationModelEstimation => $_getN(3);
  @$pb.TagNumber(4)
  set notificationModelEstimation($0.NotificationModelEstimation value) =>
      $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasNotificationModelEstimation() => $_has(3);
  @$pb.TagNumber(4)
  void clearNotificationModelEstimation() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.NotificationModelEstimation ensureNotificationModelEstimation() =>
      $_ensure(3);

  @$pb.TagNumber(5)
  $0.NotificationSystemStats get notificationSystemStats => $_getN(4);
  @$pb.TagNumber(5)
  set notificationSystemStats($0.NotificationSystemStats value) =>
      $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasNotificationSystemStats() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotificationSystemStats() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.NotificationSystemStats ensureNotificationSystemStats() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.NotificationSignalStats get notificationSignalStats => $_getN(5);
  @$pb.TagNumber(6)
  set notificationSignalStats($0.NotificationSignalStats value) =>
      $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasNotificationSignalStats() => $_has(5);
  @$pb.TagNumber(6)
  void clearNotificationSignalStats() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.NotificationSignalStats ensureNotificationSignalStats() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.NotificationBattery get notificationBattery => $_getN(6);
  @$pb.TagNumber(7)
  set notificationBattery($0.NotificationBattery value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasNotificationBattery() => $_has(6);
  @$pb.TagNumber(7)
  void clearNotificationBattery() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.NotificationBattery ensureNotificationBattery() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.NotificationLSM6DSOX get notificationLsm6dsox => $_getN(7);
  @$pb.TagNumber(8)
  set notificationLsm6dsox($0.NotificationLSM6DSOX value) =>
      $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasNotificationLsm6dsox() => $_has(7);
  @$pb.TagNumber(8)
  void clearNotificationLsm6dsox() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.NotificationLSM6DSOX ensureNotificationLsm6dsox() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.NotificationPressure get notificationPressure => $_getN(8);
  @$pb.TagNumber(9)
  set notificationPressure($0.NotificationPressure value) =>
      $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasNotificationPressure() => $_has(8);
  @$pb.TagNumber(9)
  void clearNotificationPressure() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.NotificationPressure ensureNotificationPressure() => $_ensure(8);

  @$pb.TagNumber(10)
  $0.NotificationButtonPress get notificationButtonPress => $_getN(9);
  @$pb.TagNumber(10)
  set notificationButtonPress($0.NotificationButtonPress value) =>
      $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasNotificationButtonPress() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotificationButtonPress() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.NotificationButtonPress ensureNotificationButtonPress() => $_ensure(9);

  @$pb.TagNumber(999)
  $fixnum.Int64 get timestamp => $_getI64(10);
  @$pb.TagNumber(999)
  set timestamp($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(999)
  $core.bool hasTimestamp() => $_has(10);
  @$pb.TagNumber(999)
  void clearTimestamp() => $_clearField(999);

  @$pb.TagNumber(1000)
  $0.NotificationDebugString get notificationDebugString => $_getN(11);
  @$pb.TagNumber(1000)
  set notificationDebugString($0.NotificationDebugString value) =>
      $_setField(1000, value);
  @$pb.TagNumber(1000)
  $core.bool hasNotificationDebugString() => $_has(11);
  @$pb.TagNumber(1000)
  void clearNotificationDebugString() => $_clearField(1000);
  @$pb.TagNumber(1000)
  $0.NotificationDebugString ensureNotificationDebugString() => $_ensure(11);

  @$pb.TagNumber(1001)
  $0.NotificationDebugAS5311 get notificationDebugAs5311 => $_getN(12);
  @$pb.TagNumber(1001)
  set notificationDebugAs5311($0.NotificationDebugAS5311 value) =>
      $_setField(1001, value);
  @$pb.TagNumber(1001)
  $core.bool hasNotificationDebugAs5311() => $_has(12);
  @$pb.TagNumber(1001)
  void clearNotificationDebugAs5311() => $_clearField(1001);
  @$pb.TagNumber(1001)
  $0.NotificationDebugAS5311 ensureNotificationDebugAs5311() => $_ensure(12);

  @$pb.TagNumber(1002)
  $0.NotificationDebugEdging get notificationDebugEdging => $_getN(13);
  @$pb.TagNumber(1002)
  set notificationDebugEdging($0.NotificationDebugEdging value) =>
      $_setField(1002, value);
  @$pb.TagNumber(1002)
  $core.bool hasNotificationDebugEdging() => $_has(13);
  @$pb.TagNumber(1002)
  void clearNotificationDebugEdging() => $_clearField(1002);
  @$pb.TagNumber(1002)
  $0.NotificationDebugEdging ensureNotificationDebugEdging() => $_ensure(13);
}

enum Request_Params {
  requestAxisMoveTo,
  requestFirmwareVersion,
  requestCapabilitiesGet,
  requestSignalStart,
  requestSignalStop,
  requestTimestampSet,
  requestTimestampGet,
  requestWifiParametersSet,
  requestWifiIpGet,
  requestLsm6dsoxStart,
  requestLsm6dsoxStop,
  requestDebugStm32DeepSleep,
  requestDebugEnterBootloader,
  notSet
}

class Request extends $pb.GeneratedMessage {
  factory Request({
    $core.int? id,
    $1.RequestAxisMoveTo? requestAxisMoveTo,
    $1.RequestFirmwareVersion? requestFirmwareVersion,
    $1.RequestCapabilitiesGet? requestCapabilitiesGet,
    $1.RequestSignalStart? requestSignalStart,
    $1.RequestSignalStop? requestSignalStop,
    $1.RequestTimestampSet? requestTimestampSet,
    $1.RequestTimestampGet? requestTimestampGet,
    $1.RequestWifiParametersSet? requestWifiParametersSet,
    $1.RequestWifiIPGet? requestWifiIpGet,
    $1.RequestLSM6DSOXStart? requestLsm6dsoxStart,
    $1.RequestLSM6DSOXStop? requestLsm6dsoxStop,
    $1.RequestDebugStm32DeepSleep? requestDebugStm32DeepSleep,
    $1.RequestDebugEnterBootloader? requestDebugEnterBootloader,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (requestAxisMoveTo != null) result.requestAxisMoveTo = requestAxisMoveTo;
    if (requestFirmwareVersion != null)
      result.requestFirmwareVersion = requestFirmwareVersion;
    if (requestCapabilitiesGet != null)
      result.requestCapabilitiesGet = requestCapabilitiesGet;
    if (requestSignalStart != null)
      result.requestSignalStart = requestSignalStart;
    if (requestSignalStop != null) result.requestSignalStop = requestSignalStop;
    if (requestTimestampSet != null)
      result.requestTimestampSet = requestTimestampSet;
    if (requestTimestampGet != null)
      result.requestTimestampGet = requestTimestampGet;
    if (requestWifiParametersSet != null)
      result.requestWifiParametersSet = requestWifiParametersSet;
    if (requestWifiIpGet != null) result.requestWifiIpGet = requestWifiIpGet;
    if (requestLsm6dsoxStart != null)
      result.requestLsm6dsoxStart = requestLsm6dsoxStart;
    if (requestLsm6dsoxStop != null)
      result.requestLsm6dsoxStop = requestLsm6dsoxStop;
    if (requestDebugStm32DeepSleep != null)
      result.requestDebugStm32DeepSleep = requestDebugStm32DeepSleep;
    if (requestDebugEnterBootloader != null)
      result.requestDebugEnterBootloader = requestDebugEnterBootloader;
    return result;
  }

  Request._();

  factory Request.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Request.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Request_Params> _Request_ParamsByTag = {
    5: Request_Params.requestAxisMoveTo,
    500: Request_Params.requestFirmwareVersion,
    501: Request_Params.requestCapabilitiesGet,
    502: Request_Params.requestSignalStart,
    503: Request_Params.requestSignalStop,
    504: Request_Params.requestTimestampSet,
    505: Request_Params.requestTimestampGet,
    507: Request_Params.requestWifiParametersSet,
    508: Request_Params.requestWifiIpGet,
    600: Request_Params.requestLsm6dsoxStart,
    601: Request_Params.requestLsm6dsoxStop,
    1000: Request_Params.requestDebugStm32DeepSleep,
    1001: Request_Params.requestDebugEnterBootloader,
    0: Request_Params.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Request',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..oo(0, [5, 500, 501, 502, 503, 504, 505, 507, 508, 600, 601, 1000, 1001])
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$1.RequestAxisMoveTo>(5, _omitFieldNames ? '' : 'requestAxisMoveTo',
        subBuilder: $1.RequestAxisMoveTo.create)
    ..aOM<$1.RequestFirmwareVersion>(
        500, _omitFieldNames ? '' : 'requestFirmwareVersion',
        subBuilder: $1.RequestFirmwareVersion.create)
    ..aOM<$1.RequestCapabilitiesGet>(
        501, _omitFieldNames ? '' : 'requestCapabilitiesGet',
        subBuilder: $1.RequestCapabilitiesGet.create)
    ..aOM<$1.RequestSignalStart>(
        502, _omitFieldNames ? '' : 'requestSignalStart',
        subBuilder: $1.RequestSignalStart.create)
    ..aOM<$1.RequestSignalStop>(503, _omitFieldNames ? '' : 'requestSignalStop',
        subBuilder: $1.RequestSignalStop.create)
    ..aOM<$1.RequestTimestampSet>(
        504, _omitFieldNames ? '' : 'requestTimestampSet',
        subBuilder: $1.RequestTimestampSet.create)
    ..aOM<$1.RequestTimestampGet>(
        505, _omitFieldNames ? '' : 'requestTimestampGet',
        subBuilder: $1.RequestTimestampGet.create)
    ..aOM<$1.RequestWifiParametersSet>(
        507, _omitFieldNames ? '' : 'requestWifiParametersSet',
        subBuilder: $1.RequestWifiParametersSet.create)
    ..aOM<$1.RequestWifiIPGet>(508, _omitFieldNames ? '' : 'requestWifiIpGet',
        subBuilder: $1.RequestWifiIPGet.create)
    ..aOM<$1.RequestLSM6DSOXStart>(
        600, _omitFieldNames ? '' : 'requestLsm6dsoxStart',
        subBuilder: $1.RequestLSM6DSOXStart.create)
    ..aOM<$1.RequestLSM6DSOXStop>(
        601, _omitFieldNames ? '' : 'requestLsm6dsoxStop',
        subBuilder: $1.RequestLSM6DSOXStop.create)
    ..aOM<$1.RequestDebugStm32DeepSleep>(
        1000, _omitFieldNames ? '' : 'requestDebugStm32DeepSleep',
        subBuilder: $1.RequestDebugStm32DeepSleep.create)
    ..aOM<$1.RequestDebugEnterBootloader>(
        1001, _omitFieldNames ? '' : 'requestDebugEnterBootloader',
        subBuilder: $1.RequestDebugEnterBootloader.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Request clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Request copyWith(void Function(Request) updates) =>
      super.copyWith((message) => updates(message as Request)) as Request;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Request create() => Request._();
  @$core.override
  Request createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Request getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Request>(create);
  static Request? _defaultInstance;

  @$pb.TagNumber(5)
  @$pb.TagNumber(500)
  @$pb.TagNumber(501)
  @$pb.TagNumber(502)
  @$pb.TagNumber(503)
  @$pb.TagNumber(504)
  @$pb.TagNumber(505)
  @$pb.TagNumber(507)
  @$pb.TagNumber(508)
  @$pb.TagNumber(600)
  @$pb.TagNumber(601)
  @$pb.TagNumber(1000)
  @$pb.TagNumber(1001)
  Request_Params whichParams() => _Request_ParamsByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(5)
  @$pb.TagNumber(500)
  @$pb.TagNumber(501)
  @$pb.TagNumber(502)
  @$pb.TagNumber(503)
  @$pb.TagNumber(504)
  @$pb.TagNumber(505)
  @$pb.TagNumber(507)
  @$pb.TagNumber(508)
  @$pb.TagNumber(600)
  @$pb.TagNumber(601)
  @$pb.TagNumber(1000)
  @$pb.TagNumber(1001)
  void clearParams() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// MoveTo streaming API
  @$pb.TagNumber(5)
  $1.RequestAxisMoveTo get requestAxisMoveTo => $_getN(1);
  @$pb.TagNumber(5)
  set requestAxisMoveTo($1.RequestAxisMoveTo value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRequestAxisMoveTo() => $_has(1);
  @$pb.TagNumber(5)
  void clearRequestAxisMoveTo() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.RequestAxisMoveTo ensureRequestAxisMoveTo() => $_ensure(1);

  /// general commands
  @$pb.TagNumber(500)
  $1.RequestFirmwareVersion get requestFirmwareVersion => $_getN(2);
  @$pb.TagNumber(500)
  set requestFirmwareVersion($1.RequestFirmwareVersion value) =>
      $_setField(500, value);
  @$pb.TagNumber(500)
  $core.bool hasRequestFirmwareVersion() => $_has(2);
  @$pb.TagNumber(500)
  void clearRequestFirmwareVersion() => $_clearField(500);
  @$pb.TagNumber(500)
  $1.RequestFirmwareVersion ensureRequestFirmwareVersion() => $_ensure(2);

  @$pb.TagNumber(501)
  $1.RequestCapabilitiesGet get requestCapabilitiesGet => $_getN(3);
  @$pb.TagNumber(501)
  set requestCapabilitiesGet($1.RequestCapabilitiesGet value) =>
      $_setField(501, value);
  @$pb.TagNumber(501)
  $core.bool hasRequestCapabilitiesGet() => $_has(3);
  @$pb.TagNumber(501)
  void clearRequestCapabilitiesGet() => $_clearField(501);
  @$pb.TagNumber(501)
  $1.RequestCapabilitiesGet ensureRequestCapabilitiesGet() => $_ensure(3);

  @$pb.TagNumber(502)
  $1.RequestSignalStart get requestSignalStart => $_getN(4);
  @$pb.TagNumber(502)
  set requestSignalStart($1.RequestSignalStart value) => $_setField(502, value);
  @$pb.TagNumber(502)
  $core.bool hasRequestSignalStart() => $_has(4);
  @$pb.TagNumber(502)
  void clearRequestSignalStart() => $_clearField(502);
  @$pb.TagNumber(502)
  $1.RequestSignalStart ensureRequestSignalStart() => $_ensure(4);

  @$pb.TagNumber(503)
  $1.RequestSignalStop get requestSignalStop => $_getN(5);
  @$pb.TagNumber(503)
  set requestSignalStop($1.RequestSignalStop value) => $_setField(503, value);
  @$pb.TagNumber(503)
  $core.bool hasRequestSignalStop() => $_has(5);
  @$pb.TagNumber(503)
  void clearRequestSignalStop() => $_clearField(503);
  @$pb.TagNumber(503)
  $1.RequestSignalStop ensureRequestSignalStop() => $_ensure(5);

  /// Buffered streaming API -- not yet implemented
  @$pb.TagNumber(504)
  $1.RequestTimestampSet get requestTimestampSet => $_getN(6);
  @$pb.TagNumber(504)
  set requestTimestampSet($1.RequestTimestampSet value) =>
      $_setField(504, value);
  @$pb.TagNumber(504)
  $core.bool hasRequestTimestampSet() => $_has(6);
  @$pb.TagNumber(504)
  void clearRequestTimestampSet() => $_clearField(504);
  @$pb.TagNumber(504)
  $1.RequestTimestampSet ensureRequestTimestampSet() => $_ensure(6);

  @$pb.TagNumber(505)
  $1.RequestTimestampGet get requestTimestampGet => $_getN(7);
  @$pb.TagNumber(505)
  set requestTimestampGet($1.RequestTimestampGet value) =>
      $_setField(505, value);
  @$pb.TagNumber(505)
  $core.bool hasRequestTimestampGet() => $_has(7);
  @$pb.TagNumber(505)
  void clearRequestTimestampGet() => $_clearField(505);
  @$pb.TagNumber(505)
  $1.RequestTimestampGet ensureRequestTimestampGet() => $_ensure(7);

  /// network
  @$pb.TagNumber(507)
  $1.RequestWifiParametersSet get requestWifiParametersSet => $_getN(8);
  @$pb.TagNumber(507)
  set requestWifiParametersSet($1.RequestWifiParametersSet value) =>
      $_setField(507, value);
  @$pb.TagNumber(507)
  $core.bool hasRequestWifiParametersSet() => $_has(8);
  @$pb.TagNumber(507)
  void clearRequestWifiParametersSet() => $_clearField(507);
  @$pb.TagNumber(507)
  $1.RequestWifiParametersSet ensureRequestWifiParametersSet() => $_ensure(8);

  @$pb.TagNumber(508)
  $1.RequestWifiIPGet get requestWifiIpGet => $_getN(9);
  @$pb.TagNumber(508)
  set requestWifiIpGet($1.RequestWifiIPGet value) => $_setField(508, value);
  @$pb.TagNumber(508)
  $core.bool hasRequestWifiIpGet() => $_has(9);
  @$pb.TagNumber(508)
  void clearRequestWifiIpGet() => $_clearField(508);
  @$pb.TagNumber(508)
  $1.RequestWifiIPGet ensureRequestWifiIpGet() => $_ensure(9);

  /// sensors
  @$pb.TagNumber(600)
  $1.RequestLSM6DSOXStart get requestLsm6dsoxStart => $_getN(10);
  @$pb.TagNumber(600)
  set requestLsm6dsoxStart($1.RequestLSM6DSOXStart value) =>
      $_setField(600, value);
  @$pb.TagNumber(600)
  $core.bool hasRequestLsm6dsoxStart() => $_has(10);
  @$pb.TagNumber(600)
  void clearRequestLsm6dsoxStart() => $_clearField(600);
  @$pb.TagNumber(600)
  $1.RequestLSM6DSOXStart ensureRequestLsm6dsoxStart() => $_ensure(10);

  @$pb.TagNumber(601)
  $1.RequestLSM6DSOXStop get requestLsm6dsoxStop => $_getN(11);
  @$pb.TagNumber(601)
  set requestLsm6dsoxStop($1.RequestLSM6DSOXStop value) =>
      $_setField(601, value);
  @$pb.TagNumber(601)
  $core.bool hasRequestLsm6dsoxStop() => $_has(11);
  @$pb.TagNumber(601)
  void clearRequestLsm6dsoxStop() => $_clearField(601);
  @$pb.TagNumber(601)
  $1.RequestLSM6DSOXStop ensureRequestLsm6dsoxStop() => $_ensure(11);

  /// debug
  @$pb.TagNumber(1000)
  $1.RequestDebugStm32DeepSleep get requestDebugStm32DeepSleep => $_getN(12);
  @$pb.TagNumber(1000)
  set requestDebugStm32DeepSleep($1.RequestDebugStm32DeepSleep value) =>
      $_setField(1000, value);
  @$pb.TagNumber(1000)
  $core.bool hasRequestDebugStm32DeepSleep() => $_has(12);
  @$pb.TagNumber(1000)
  void clearRequestDebugStm32DeepSleep() => $_clearField(1000);
  @$pb.TagNumber(1000)
  $1.RequestDebugStm32DeepSleep ensureRequestDebugStm32DeepSleep() =>
      $_ensure(12);

  @$pb.TagNumber(1001)
  $1.RequestDebugEnterBootloader get requestDebugEnterBootloader => $_getN(13);
  @$pb.TagNumber(1001)
  set requestDebugEnterBootloader($1.RequestDebugEnterBootloader value) =>
      $_setField(1001, value);
  @$pb.TagNumber(1001)
  $core.bool hasRequestDebugEnterBootloader() => $_has(13);
  @$pb.TagNumber(1001)
  void clearRequestDebugEnterBootloader() => $_clearField(1001);
  @$pb.TagNumber(1001)
  $1.RequestDebugEnterBootloader ensureRequestDebugEnterBootloader() =>
      $_ensure(13);
}

enum Response_Result {
  responseAxisMoveTo,
  responseFirmwareVersion,
  responseCapabilitiesGet,
  responseSignalStart,
  responseSignalStop,
  responseTimestampSet,
  responseTimestampGet,
  responseWifiParametersSet,
  responseWifiIpGet,
  responseLsm6dsoxStart,
  responseLsm6dsoxStop,
  responseDebugStm32DeepSleep,
  notSet
}

/// Responses have the same ID as the request. NB! not all requests will have a result, and just return a blank response
class Response extends $pb.GeneratedMessage {
  factory Response({
    $core.int? id,
    Error? error,
    $1.ResponseAxisMoveTo? responseAxisMoveTo,
    $1.ResponseFirmwareVersion? responseFirmwareVersion,
    $1.ResponseCapabilitiesGet? responseCapabilitiesGet,
    $1.ResponseSignalStart? responseSignalStart,
    $1.ResponseSignalStop? responseSignalStop,
    $1.ResponseTimestampSet? responseTimestampSet,
    $1.ResponseTimestampGet? responseTimestampGet,
    $1.ResponseWifiParametersSet? responseWifiParametersSet,
    $1.ResponseWifiIPGet? responseWifiIpGet,
    $1.ResponseLSM6DSOXStart? responseLsm6dsoxStart,
    $1.ResponseLSM6DSOXStop? responseLsm6dsoxStop,
    $1.ResponseDebugStm32DeepSleep? responseDebugStm32DeepSleep,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (error != null) result.error = error;
    if (responseAxisMoveTo != null)
      result.responseAxisMoveTo = responseAxisMoveTo;
    if (responseFirmwareVersion != null)
      result.responseFirmwareVersion = responseFirmwareVersion;
    if (responseCapabilitiesGet != null)
      result.responseCapabilitiesGet = responseCapabilitiesGet;
    if (responseSignalStart != null)
      result.responseSignalStart = responseSignalStart;
    if (responseSignalStop != null)
      result.responseSignalStop = responseSignalStop;
    if (responseTimestampSet != null)
      result.responseTimestampSet = responseTimestampSet;
    if (responseTimestampGet != null)
      result.responseTimestampGet = responseTimestampGet;
    if (responseWifiParametersSet != null)
      result.responseWifiParametersSet = responseWifiParametersSet;
    if (responseWifiIpGet != null) result.responseWifiIpGet = responseWifiIpGet;
    if (responseLsm6dsoxStart != null)
      result.responseLsm6dsoxStart = responseLsm6dsoxStart;
    if (responseLsm6dsoxStop != null)
      result.responseLsm6dsoxStop = responseLsm6dsoxStop;
    if (responseDebugStm32DeepSleep != null)
      result.responseDebugStm32DeepSleep = responseDebugStm32DeepSleep;
    return result;
  }

  Response._();

  factory Response.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Response.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Response_Result> _Response_ResultByTag = {
    5: Response_Result.responseAxisMoveTo,
    500: Response_Result.responseFirmwareVersion,
    501: Response_Result.responseCapabilitiesGet,
    502: Response_Result.responseSignalStart,
    503: Response_Result.responseSignalStop,
    504: Response_Result.responseTimestampSet,
    505: Response_Result.responseTimestampGet,
    507: Response_Result.responseWifiParametersSet,
    508: Response_Result.responseWifiIpGet,
    600: Response_Result.responseLsm6dsoxStart,
    601: Response_Result.responseLsm6dsoxStop,
    1000: Response_Result.responseDebugStm32DeepSleep,
    0: Response_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Response',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..oo(0, [5, 500, 501, 502, 503, 504, 505, 507, 508, 600, 601, 1000])
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOM<Error>(3, _omitFieldNames ? '' : 'error', subBuilder: Error.create)
    ..aOM<$1.ResponseAxisMoveTo>(5, _omitFieldNames ? '' : 'responseAxisMoveTo',
        subBuilder: $1.ResponseAxisMoveTo.create)
    ..aOM<$1.ResponseFirmwareVersion>(
        500, _omitFieldNames ? '' : 'responseFirmwareVersion',
        subBuilder: $1.ResponseFirmwareVersion.create)
    ..aOM<$1.ResponseCapabilitiesGet>(
        501, _omitFieldNames ? '' : 'responseCapabilitiesGet',
        subBuilder: $1.ResponseCapabilitiesGet.create)
    ..aOM<$1.ResponseSignalStart>(
        502, _omitFieldNames ? '' : 'responseSignalStart',
        subBuilder: $1.ResponseSignalStart.create)
    ..aOM<$1.ResponseSignalStop>(
        503, _omitFieldNames ? '' : 'responseSignalStop',
        subBuilder: $1.ResponseSignalStop.create)
    ..aOM<$1.ResponseTimestampSet>(
        504, _omitFieldNames ? '' : 'responseTimestampSet',
        subBuilder: $1.ResponseTimestampSet.create)
    ..aOM<$1.ResponseTimestampGet>(
        505, _omitFieldNames ? '' : 'responseTimestampGet',
        subBuilder: $1.ResponseTimestampGet.create)
    ..aOM<$1.ResponseWifiParametersSet>(
        507, _omitFieldNames ? '' : 'responseWifiParametersSet',
        subBuilder: $1.ResponseWifiParametersSet.create)
    ..aOM<$1.ResponseWifiIPGet>(508, _omitFieldNames ? '' : 'responseWifiIpGet',
        subBuilder: $1.ResponseWifiIPGet.create)
    ..aOM<$1.ResponseLSM6DSOXStart>(
        600, _omitFieldNames ? '' : 'responseLsm6dsoxStart',
        subBuilder: $1.ResponseLSM6DSOXStart.create)
    ..aOM<$1.ResponseLSM6DSOXStop>(
        601, _omitFieldNames ? '' : 'responseLsm6dsoxStop',
        subBuilder: $1.ResponseLSM6DSOXStop.create)
    ..aOM<$1.ResponseDebugStm32DeepSleep>(
        1000, _omitFieldNames ? '' : 'responseDebugStm32DeepSleep',
        subBuilder: $1.ResponseDebugStm32DeepSleep.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Response clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Response copyWith(void Function(Response) updates) =>
      super.copyWith((message) => updates(message as Response)) as Response;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Response create() => Response._();
  @$core.override
  Response createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Response getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Response>(create);
  static Response? _defaultInstance;

  @$pb.TagNumber(5)
  @$pb.TagNumber(500)
  @$pb.TagNumber(501)
  @$pb.TagNumber(502)
  @$pb.TagNumber(503)
  @$pb.TagNumber(504)
  @$pb.TagNumber(505)
  @$pb.TagNumber(507)
  @$pb.TagNumber(508)
  @$pb.TagNumber(600)
  @$pb.TagNumber(601)
  @$pb.TagNumber(1000)
  Response_Result whichResult() => _Response_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(5)
  @$pb.TagNumber(500)
  @$pb.TagNumber(501)
  @$pb.TagNumber(502)
  @$pb.TagNumber(503)
  @$pb.TagNumber(504)
  @$pb.TagNumber(505)
  @$pb.TagNumber(507)
  @$pb.TagNumber(508)
  @$pb.TagNumber(600)
  @$pb.TagNumber(601)
  @$pb.TagNumber(1000)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(3)
  Error get error => $_getN(1);
  @$pb.TagNumber(3)
  set error(Error value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
  @$pb.TagNumber(3)
  Error ensureError() => $_ensure(1);

  /// MoveTo streaming API
  @$pb.TagNumber(5)
  $1.ResponseAxisMoveTo get responseAxisMoveTo => $_getN(2);
  @$pb.TagNumber(5)
  set responseAxisMoveTo($1.ResponseAxisMoveTo value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasResponseAxisMoveTo() => $_has(2);
  @$pb.TagNumber(5)
  void clearResponseAxisMoveTo() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.ResponseAxisMoveTo ensureResponseAxisMoveTo() => $_ensure(2);

  /// general commands
  @$pb.TagNumber(500)
  $1.ResponseFirmwareVersion get responseFirmwareVersion => $_getN(3);
  @$pb.TagNumber(500)
  set responseFirmwareVersion($1.ResponseFirmwareVersion value) =>
      $_setField(500, value);
  @$pb.TagNumber(500)
  $core.bool hasResponseFirmwareVersion() => $_has(3);
  @$pb.TagNumber(500)
  void clearResponseFirmwareVersion() => $_clearField(500);
  @$pb.TagNumber(500)
  $1.ResponseFirmwareVersion ensureResponseFirmwareVersion() => $_ensure(3);

  @$pb.TagNumber(501)
  $1.ResponseCapabilitiesGet get responseCapabilitiesGet => $_getN(4);
  @$pb.TagNumber(501)
  set responseCapabilitiesGet($1.ResponseCapabilitiesGet value) =>
      $_setField(501, value);
  @$pb.TagNumber(501)
  $core.bool hasResponseCapabilitiesGet() => $_has(4);
  @$pb.TagNumber(501)
  void clearResponseCapabilitiesGet() => $_clearField(501);
  @$pb.TagNumber(501)
  $1.ResponseCapabilitiesGet ensureResponseCapabilitiesGet() => $_ensure(4);

  @$pb.TagNumber(502)
  $1.ResponseSignalStart get responseSignalStart => $_getN(5);
  @$pb.TagNumber(502)
  set responseSignalStart($1.ResponseSignalStart value) =>
      $_setField(502, value);
  @$pb.TagNumber(502)
  $core.bool hasResponseSignalStart() => $_has(5);
  @$pb.TagNumber(502)
  void clearResponseSignalStart() => $_clearField(502);
  @$pb.TagNumber(502)
  $1.ResponseSignalStart ensureResponseSignalStart() => $_ensure(5);

  @$pb.TagNumber(503)
  $1.ResponseSignalStop get responseSignalStop => $_getN(6);
  @$pb.TagNumber(503)
  set responseSignalStop($1.ResponseSignalStop value) => $_setField(503, value);
  @$pb.TagNumber(503)
  $core.bool hasResponseSignalStop() => $_has(6);
  @$pb.TagNumber(503)
  void clearResponseSignalStop() => $_clearField(503);
  @$pb.TagNumber(503)
  $1.ResponseSignalStop ensureResponseSignalStop() => $_ensure(6);

  /// Buffered streaming API -- not yet implemented
  @$pb.TagNumber(504)
  $1.ResponseTimestampSet get responseTimestampSet => $_getN(7);
  @$pb.TagNumber(504)
  set responseTimestampSet($1.ResponseTimestampSet value) =>
      $_setField(504, value);
  @$pb.TagNumber(504)
  $core.bool hasResponseTimestampSet() => $_has(7);
  @$pb.TagNumber(504)
  void clearResponseTimestampSet() => $_clearField(504);
  @$pb.TagNumber(504)
  $1.ResponseTimestampSet ensureResponseTimestampSet() => $_ensure(7);

  @$pb.TagNumber(505)
  $1.ResponseTimestampGet get responseTimestampGet => $_getN(8);
  @$pb.TagNumber(505)
  set responseTimestampGet($1.ResponseTimestampGet value) =>
      $_setField(505, value);
  @$pb.TagNumber(505)
  $core.bool hasResponseTimestampGet() => $_has(8);
  @$pb.TagNumber(505)
  void clearResponseTimestampGet() => $_clearField(505);
  @$pb.TagNumber(505)
  $1.ResponseTimestampGet ensureResponseTimestampGet() => $_ensure(8);

  /// network
  @$pb.TagNumber(507)
  $1.ResponseWifiParametersSet get responseWifiParametersSet => $_getN(9);
  @$pb.TagNumber(507)
  set responseWifiParametersSet($1.ResponseWifiParametersSet value) =>
      $_setField(507, value);
  @$pb.TagNumber(507)
  $core.bool hasResponseWifiParametersSet() => $_has(9);
  @$pb.TagNumber(507)
  void clearResponseWifiParametersSet() => $_clearField(507);
  @$pb.TagNumber(507)
  $1.ResponseWifiParametersSet ensureResponseWifiParametersSet() => $_ensure(9);

  @$pb.TagNumber(508)
  $1.ResponseWifiIPGet get responseWifiIpGet => $_getN(10);
  @$pb.TagNumber(508)
  set responseWifiIpGet($1.ResponseWifiIPGet value) => $_setField(508, value);
  @$pb.TagNumber(508)
  $core.bool hasResponseWifiIpGet() => $_has(10);
  @$pb.TagNumber(508)
  void clearResponseWifiIpGet() => $_clearField(508);
  @$pb.TagNumber(508)
  $1.ResponseWifiIPGet ensureResponseWifiIpGet() => $_ensure(10);

  /// sensors
  @$pb.TagNumber(600)
  $1.ResponseLSM6DSOXStart get responseLsm6dsoxStart => $_getN(11);
  @$pb.TagNumber(600)
  set responseLsm6dsoxStart($1.ResponseLSM6DSOXStart value) =>
      $_setField(600, value);
  @$pb.TagNumber(600)
  $core.bool hasResponseLsm6dsoxStart() => $_has(11);
  @$pb.TagNumber(600)
  void clearResponseLsm6dsoxStart() => $_clearField(600);
  @$pb.TagNumber(600)
  $1.ResponseLSM6DSOXStart ensureResponseLsm6dsoxStart() => $_ensure(11);

  @$pb.TagNumber(601)
  $1.ResponseLSM6DSOXStop get responseLsm6dsoxStop => $_getN(12);
  @$pb.TagNumber(601)
  set responseLsm6dsoxStop($1.ResponseLSM6DSOXStop value) =>
      $_setField(601, value);
  @$pb.TagNumber(601)
  $core.bool hasResponseLsm6dsoxStop() => $_has(12);
  @$pb.TagNumber(601)
  void clearResponseLsm6dsoxStop() => $_clearField(601);
  @$pb.TagNumber(601)
  $1.ResponseLSM6DSOXStop ensureResponseLsm6dsoxStop() => $_ensure(12);

  /// debug
  @$pb.TagNumber(1000)
  $1.ResponseDebugStm32DeepSleep get responseDebugStm32DeepSleep => $_getN(13);
  @$pb.TagNumber(1000)
  set responseDebugStm32DeepSleep($1.ResponseDebugStm32DeepSleep value) =>
      $_setField(1000, value);
  @$pb.TagNumber(1000)
  $core.bool hasResponseDebugStm32DeepSleep() => $_has(13);
  @$pb.TagNumber(1000)
  void clearResponseDebugStm32DeepSleep() => $_clearField(1000);
  @$pb.TagNumber(1000)
  $1.ResponseDebugStm32DeepSleep ensureResponseDebugStm32DeepSleep() =>
      $_ensure(13);
}

class Error extends $pb.GeneratedMessage {
  factory Error({
    $2.Errors? code,
  }) {
    final result = create();
    if (code != null) result.code = code;
    return result;
  }

  Error._();

  factory Error.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Error.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Error',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..aE<$2.Errors>(1, _omitFieldNames ? '' : 'code',
        enumValues: $2.Errors.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Error clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Error copyWith(void Function(Error) updates) =>
      super.copyWith((message) => updates(message as Error)) as Error;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Error create() => Error._();
  @$core.override
  Error createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Error getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Error>(create);
  static Error? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Errors get code => $_getN(0);
  @$pb.TagNumber(1)
  set code($2.Errors value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);
}

enum RpcMessage_Message { request, response, notification, notSet }

class RpcMessage extends $pb.GeneratedMessage {
  factory RpcMessage({
    Request? request,
    Response? response,
    Notification? notification,
  }) {
    final result = create();
    if (request != null) result.request = request;
    if (response != null) result.response = response;
    if (notification != null) result.notification = notification;
    return result;
  }

  RpcMessage._();

  factory RpcMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RpcMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RpcMessage_Message>
      _RpcMessage_MessageByTag = {
    2: RpcMessage_Message.request,
    4: RpcMessage_Message.response,
    5: RpcMessage_Message.notification,
    0: RpcMessage_Message.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RpcMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'focstim_rpc'),
      createEmptyInstance: create)
    ..oo(0, [2, 4, 5])
    ..aOM<Request>(2, _omitFieldNames ? '' : 'request',
        subBuilder: Request.create)
    ..aOM<Response>(4, _omitFieldNames ? '' : 'response',
        subBuilder: Response.create)
    ..aOM<Notification>(5, _omitFieldNames ? '' : 'notification',
        subBuilder: Notification.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RpcMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RpcMessage copyWith(void Function(RpcMessage) updates) =>
      super.copyWith((message) => updates(message as RpcMessage)) as RpcMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RpcMessage create() => RpcMessage._();
  @$core.override
  RpcMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RpcMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RpcMessage>(create);
  static RpcMessage? _defaultInstance;

  @$pb.TagNumber(2)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  RpcMessage_Message whichMessage() =>
      _RpcMessage_MessageByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(2)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearMessage() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(2)
  Request get request => $_getN(0);
  @$pb.TagNumber(2)
  set request(Request value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRequest() => $_has(0);
  @$pb.TagNumber(2)
  void clearRequest() => $_clearField(2);
  @$pb.TagNumber(2)
  Request ensureRequest() => $_ensure(0);

  /// Requests requests = 3;
  @$pb.TagNumber(4)
  Response get response => $_getN(1);
  @$pb.TagNumber(4)
  set response(Response value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasResponse() => $_has(1);
  @$pb.TagNumber(4)
  void clearResponse() => $_clearField(4);
  @$pb.TagNumber(4)
  Response ensureResponse() => $_ensure(1);

  @$pb.TagNumber(5)
  Notification get notification => $_getN(2);
  @$pb.TagNumber(5)
  set notification(Notification value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasNotification() => $_has(2);
  @$pb.TagNumber(5)
  void clearNotification() => $_clearField(5);
  @$pb.TagNumber(5)
  Notification ensureNotification() => $_ensure(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
