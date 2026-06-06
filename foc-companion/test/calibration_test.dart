import 'package:flutter_test/flutter_test.dart';
import 'package:foc_companion/utils/calibration_utils.dart';

void main() {
  group('Calibration Conversion Tests', () {
    test('Identity Conversion (0, 0)', () {
      final abc = CalibrationUtils.udLrToIntensityRatio(0.0, 0.0);
      expect(abc, [1.0, 1.0, 1.0]);

      final udlr = CalibrationUtils.intensityRatioToUdLr(1.0, 1.0, 1.0);
      expect(udlr[0], closeTo(0.0, 0.0001));
      expect(udlr[1], closeTo(0.0, 0.0001));
    });

    test('Round-trip: ud, lr -> A/B/C -> ud, lr', () {
      final testCases = [
        [0.5, -0.5],
        [-1.2, 0.8],
        [1.8, 1.2],
        [-0.8, -1.5],
      ];

      for (final tc in testCases) {
        final double ud = tc[0];
        final double lr = tc[1];

        final abc = CalibrationUtils.udLrToIntensityRatio(ud, lr);
        final udlrOut = CalibrationUtils.intensityRatioToUdLr(abc[0], abc[1], abc[2]);

        expect(udlrOut[0], closeTo(ud, 0.001));
        expect(udlrOut[1], closeTo(lr, 0.001));
      }
    });

    test('Round-trip: A/B/C -> ud, lr -> A/B/C', () {
      final testCases = [
        [1.0, 0.8, 0.6],
        [0.5, 1.0, 0.7],
        [0.7, 0.5, 1.0],
      ];

      for (final tc in testCases) {
        final double a = tc[0];
        final double b = tc[1];
        final double c = tc[2];

        final udlr = CalibrationUtils.intensityRatioToUdLr(a, b, c);
        final abcOut = CalibrationUtils.udLrToIntensityRatio(udlr[0], udlr[1]);

        expect(abcOut[0], closeTo(a, 0.001));
        expect(abcOut[1], closeTo(b, 0.001));
        expect(abcOut[2], closeTo(c, 0.001));
      }
    });
  });
}
