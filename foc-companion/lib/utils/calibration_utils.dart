import 'dart:math' as math;

class CalibrationUtils {
  /// Converts Up-Down and Left-Right calibration values (in dB)
  /// to Electrode A, B, C intensity ratios (0.0 to 1.0).
  static List<double> udLrToIntensityRatio(double ud, double lr) {
    if (ud == 0.0 && lr == 0.0) {
      return [1.0, 1.0, 1.0];
    }

    final double theta = math.atan2(lr, ud) / 2.0;
    final double norm = math.sqrt(ud * ud + lr * lr);
    final double ratio = math.pow(10.0, norm / 10.0).toDouble();
    final double scale = 1.0 / ratio;

    final double s = scale - 1.0;
    final double aDir = math.sin(-theta);
    final double bDir = math.cos(theta);

    final double c00 = 1.0 + s * aDir * aDir;
    final double c01 = s * aDir * bDir;
    final double c10 = c01;
    final double c11 = 1.0 + s * bDir * bDir;

    // ab @ calib
    final double z00 = c00;
    final double z01 = c01;

    final double z10 = -0.5 * c00 + (math.sqrt(3.0) / 2.0) * c10;
    final double z11 = -0.5 * c01 + (math.sqrt(3.0) / 2.0) * c11;

    final double z20 = -0.5 * c00 - (math.sqrt(3.0) / 2.0) * c10;
    final double z21 = -0.5 * c01 - (math.sqrt(3.0) / 2.0) * c11;

    double ia = math.sqrt(z00 * z00 + z01 * z01);
    double ib = math.sqrt(z10 * z10 + z11 * z11);
    double ic = math.sqrt(z20 * z20 + z21 * z21);

    final double maxI = math.max(ia, math.max(ib, ic));
    if (maxI > 0.0) {
      ia /= maxI;
      ib /= maxI;
      ic /= maxI;
    }

    return [ia, ib, ic];
  }

  /// Converts Electrode A, B, C intensity ratios (0.0 to 1.0)
  /// to Up-Down and Left-Right calibration values (in dB).
  static List<double> intensityRatioToUdLr(double a, double b, double c) {
    // Clamp to minimum 0.0001 to avoid division by zero
    a = math.max(0.0001, a);
    b = math.max(0.0001, b);
    c = math.max(0.0001, c);

    // Normalize so that max is 1.0
    double maximum = math.max(a, math.max(b, c));
    a /= maximum;
    b /= maximum;
    c /= maximum;

    // Check triangle inequality: min + mid >= max. If not, add offset to the smaller ones.
    int maxIndex = 0;
    if (b > a && b > c) maxIndex = 1;
    if (c > a && c > b) maxIndex = 2;

    if (maxIndex == 0) {
      if (b + c < a) {
        final double offset = (a - (b + c)) / 2.0;
        b += offset;
        c += offset;
      }
    } else if (maxIndex == 1) {
      if (a + c < b) {
        final double offset = (b - (a + c)) / 2.0;
        a += offset;
        c += offset;
      }
    } else {
      if (a + b < c) {
        final double offset = (c - (a + b)) / 2.0;
        a += offset;
        b += offset;
      }
    }

    // split_point(-a, b, c)
    final double cVal = math.max(0.0001, a);
    final double rational = (b * b - c * c + cVal * cVal) / (2.0 * cVal);
    final double imaginary = math.sqrt(math.max(b * b - rational * rational, 0.0));

    final double complexBReal = -rational;
    final double complexBImag = -imaginary;
    final double complexCReal = rational - a;
    final double complexCImag = imaginary;

    // Least squares solve using hardcoded pseudo-inverse matrix
    final double sqrt3_3 = math.sqrt(3.0) / 3.0;
    final double c00 = (2.0 / 3.0) * a - (1.0 / 3.0) * complexBReal - (1.0 / 3.0) * complexCReal;
    final double c01 = -(1.0 / 3.0) * complexBImag - (1.0 / 3.0) * complexCImag;
    final double c10 = -sqrt3_3 * complexBReal + sqrt3_3 * complexCReal;
    final double c11 = -sqrt3_3 * complexBImag + sqrt3_3 * complexCImag;

    // Rotate so matrix[0, 1] equals matrix[1, 0]
    final double q = math.atan2(c01 - c10, c00 + c11);
    final double cosQ = math.cos(q);
    final double sinQ = math.sin(q);

    double r00 = c00 * cosQ + c01 * sinQ;
    double r01 = -c00 * sinQ + c01 * cosQ;
    double r10 = c10 * cosQ + c11 * sinQ;
    double r11 = -c10 * sinQ + c11 * cosQ;

    // Find eigenvalues of r[:2, :2]
    final double tr = r00 + r11;
    final double det = r00 * r11 - r01 * r10;
    final double discriminant = tr * tr - 4.0 * det;
    final double sqrtDisc = math.sqrt(math.max(discriminant, 0.0));
    final double lambda1 = (tr + sqrtDisc) / 2.0;
    final double lambda2 = (tr - sqrtDisc) / 2.0;
    final double largestEigenvalue = math.max(lambda1, lambda2);

    if (largestEigenvalue.abs() > 0.001) {
      r00 /= largestEigenvalue;
      r01 /= largestEigenvalue;
      r10 /= largestEigenvalue;
      r11 /= largestEigenvalue;
    }

    // Inverse scale in arbitrary direction
    final double s = r00 + r11 - 2.0;
    double scale = s + 1.0;
    double aDir = 0.0;
    double bDir = 0.0;
    if (s.abs() > 0.0001) {
      aDir = math.sqrt(math.max(0.0, (r00 - 1.0) / s));
      bDir = math.sqrt(math.max(0.0, (r11 - 1.0) / s));
      if (r01 <= 0.0) {
        bDir = -bDir;
      }
    } else {
      scale = 1.0;
    }

    final double ratio = 1.0 / (scale.clamp(0.001, double.infinity));
    final double thetaVal = -math.atan2(aDir, -bDir);
    final double normVal = (math.log(ratio) / math.ln10) * 10.0;
    final double doubleTheta = thetaVal * 2.0;

    final double ud = math.cos(doubleTheta) * normVal;
    final double lr = -math.sin(doubleTheta) * normVal;

    return [ud, lr];
  }
}
