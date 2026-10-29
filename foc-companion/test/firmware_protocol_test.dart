import 'package:flutter_test/flutter_test.dart';
import 'package:foc_companion/core/command_loop.dart';
import 'package:foc_companion/generated/protobuf/constants.pbenum.dart';
import 'package:foc_companion/generated/protobuf/messages.pb.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/focstim_api_service.dart';

FirmwareVersion _v(int major, int minor, int revision, {String branch = 'main'}) =>
    FirmwareVersion()
      ..major = major
      ..minor = minor
      ..revision = revision
      ..branch = branch;

void main() {
  group('Firmware version gate', () {
    test('accepts supported versions and returns the API major', () {
      expect(checkFirmwareVersion(_v(1, 1, 0)), 1);
      expect(checkFirmwareVersion(_v(1, 3, 2)), 1);
      expect(checkFirmwareVersion(_v(2, 0, 0)), 2);
      expect(checkFirmwareVersion(_v(2, 0, 3)), 2);
    });

    test('rejects unsupported versions', () {
      expect(() => checkFirmwareVersion(_v(1, 0, 9)), throwsException);
      expect(() => checkFirmwareVersion(_v(0, 9, 0)), throwsException);
      expect(() => checkFirmwareVersion(_v(3, 0, 0)), throwsException);
    });

    test('rejects non-main branch', () {
      expect(() => checkFirmwareVersion(_v(2, 0, 3, branch: 'dev')), throwsException);
    });
  });

  group('Firmware version formatting', () {
    test('STM32 only', () {
      final resp = ResponseFirmwareVersion()..stm32FirmwareVersion2 = _v(2, 0, 3);
      expect(formatFirmwareVersion(resp), 'v2.0.3 (main)');
    });

    test('with ESP32 version', () {
      final resp = ResponseFirmwareVersion()
        ..stm32FirmwareVersion2 = _v(2, 0, 3)
        ..esp32FirmwareVersion = _v(1, 2, 0);
      expect(formatFirmwareVersion(resp), 'v2.0.3 (main), ESP32 v1.2.0');
    });
  });

  group('Center reduction conversion', () {
    test('0 dB means no reduction', () {
      expect(centerDbToReduction(0.0), closeTo(0.0, 1e-9));
    });

    test('matches restim conversion', () {
      // restim default -0.604 dB ≈ 13 % reduction
      expect(centerDbToReduction(-0.604), closeTo(0.1297, 0.001));
      expect(centerDbToReduction(-0.5), closeTo(0.1087, 0.001));
    });

    test('clamps to the firmware range 0–0.2', () {
      expect(centerDbToReduction(-2.0), 0.2);
      expect(centerDbToReduction(2.0), 0.0);
    });
  });

  group('3-phase calibration axes', () {
    final d = DeviceSettings()
      ..calibration3Center = -0.5
      ..calibration3Up = 0.3
      ..calibration3Left = -0.2
      ..calibration3A = -1.0
      ..calibration3B = -2.0
      ..calibration3C = 0.0;

    test('v1 firmware gets CENTER/UP/LEFT', () {
      final axes = threePhaseCalibrationAxes(d, 1);
      expect(axes, {
        AxisType.AXIS_CALIBRATION_3_CENTER: -0.5,
        AxisType.AXIS_CALIBRATION_3_UP: 0.3,
        AxisType.AXIS_CALIBRATION_3_LEFT: -0.2,
      });
    });

    test('v2 firmware gets A/B/C in dB and center reduction', () {
      final axes = threePhaseCalibrationAxes(d, 2);
      expect(axes.keys, [
        AxisType.AXIS_CALIBRATION_3_A,
        AxisType.AXIS_CALIBRATION_3_B,
        AxisType.AXIS_CALIBRATION_3_C,
        AxisType.AXIS_CALIBRATION_3_REDUCTION_IN_CENTER,
      ]);
      expect(axes[AxisType.AXIS_CALIBRATION_3_A], -1.0);
      expect(axes[AxisType.AXIS_CALIBRATION_3_B], -2.0);
      expect(axes[AxisType.AXIS_CALIBRATION_3_C], 0.0);
      expect(axes[AxisType.AXIS_CALIBRATION_3_REDUCTION_IN_CENTER],
          closeTo(0.1087, 0.001));
    });
  });

  group('DeviceSettings persistence', () {
    test('4-phase center reduction round-trips and defaults to 0.14', () {
      expect(DeviceSettings.fromJson({}).calibration4CenterReduction, 0.14);
      final d = DeviceSettings()..calibration4CenterReduction = 0.07;
      expect(DeviceSettings.fromJson(d.toJson()).calibration4CenterReduction, 0.07);
    });
  });
}
