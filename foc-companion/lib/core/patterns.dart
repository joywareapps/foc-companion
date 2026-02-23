import 'dart:math';

// ──────────────────────────────────────────────
// 4-Phase types
// ──────────────────────────────────────────────

class FourPhaseIntensity {
  final double a, b, c, d;
  const FourPhaseIntensity(this.a, this.b, this.c, this.d);
}

abstract class FourphasePattern {
  String get name;
  String get description;
  FourPhaseIntensity update(double dt);
  void reset();
}

// ──────────────────────────────────────────────
// 4-Phase reference points  (match desktop POINTS class)
// ──────────────────────────────────────────────

const _A      = [1.0,  0.33, 0.33, 0.33];
const _B      = [0.33, 1.0,  0.33, 0.33];
const _C      = [0.33, 0.33, 1.0,  0.33];
const _D      = [0.33, 0.33, 0.33, 1.0];

const _AB     = [1.0,  1.0,  0.0,  0.0];
const _AC     = [1.0,  0.0,  1.0,  0.0];
const _AD     = [1.0,  0.0,  0.0,  1.0];
const _BC     = [0.0,  1.0,  1.0,  0.0];
const _BD     = [0.0,  1.0,  0.0,  1.0];
const _CD     = [0.0,  0.0,  1.0,  1.0];

const _ABC    = [1.0,  1.0,  1.0,  0.0];
const _ABD    = [1.0,  1.0,  0.0,  1.0];
const _ACD    = [1.0,  0.0,  1.0,  1.0];

const _CENTER = [1.0,  1.0,  1.0,  1.0];

// ──────────────────────────────────────────────
// Sequence Pattern (matches desktop SequencePattern)
//
// Linearly interpolates through a list of electrode
// intensity keyframes, cycling continuously.
// Keyframes wrap back to the first automatically.
// index advances at dt/2 per second (at velocity=1).
// ──────────────────────────────────────────────

class SequencePattern4Phase implements FourphasePattern {
  final String _name;
  // sequence with wrap-around copy of first element at end
  final List<List<double>> _seq;
  double _index = 0;

  SequencePattern4Phase(this._name, List<List<double>> sequence)
      : _seq = [...sequence, sequence[0]];

  @override
  String get name => _name;

  @override
  String get description => '';

  @override
  FourPhaseIntensity update(double dt) {
    // Advance at dt/2 per second — matches desktop `dt / 2`
    final int wrapLen = _seq.length - 1;
    _index = (_index + dt / 2) % wrapLen;

    final int i0 = _index.floor();
    final int i1 = i0 + 1; // always valid because we added wrap element
    final double t = _index - i0;

    final p0 = _seq[i0];
    final p1 = _seq[i1];

    return FourPhaseIntensity(
      p0[0] + (p1[0] - p0[0]) * t,
      p0[1] + (p1[1] - p0[1]) * t,
      p0[2] + (p1[2] - p0[2]) * t,
      p0[3] + (p1[3] - p0[3]) * t,
    );
  }

  @override
  void reset() {
    _index = 0;
  }
}

// ──────────────────────────────────────────────
// 4-Phase Pattern Registry
// Mirrors the desktop FourphaseMotionGenerator pattern list
// (mouse excluded; orbit/spiral are defined but not in desktop default list)
// ──────────────────────────────────────────────

class FourphasePatternRegistry {
  static final List<FourphasePattern> all = [
    SequencePattern4Phase('A→B→C→D',         [_A, _B, _C, _D]),
    SequencePattern4Phase('A→B→D→C',         [_A, _B, _D, _C]),
    SequencePattern4Phase('A→C→B→D',         [_A, _C, _B, _D]),
    SequencePattern4Phase('A→C→D→B',         [_A, _C, _D, _B]),
    SequencePattern4Phase('A→D→B→C',         [_A, _D, _B, _C]),
    SequencePattern4Phase('A→D→C→B',         [_A, _D, _C, _B]),
    SequencePattern4Phase('A→B→C→D (slow)',  [_A, _AB, _B, _BC, _C, _CD, _D, _AD]),
    SequencePattern4Phase('AB→BC→CD→AD',     [_AB, _BC, _CD, _AD]),
    SequencePattern4Phase('AB→BD→CD→AC',     [_AB, _BD, _CD, _AC]),
    SequencePattern4Phase('A ↔ B',           [_A, _AB, _B, _AB]),
    SequencePattern4Phase('A ↔ C',           [_A, _AC, _C, _AC]),
    SequencePattern4Phase('A ↔ D',           [_A, _AD, _D, _AD]),
    SequencePattern4Phase('B ↔ C',           [_B, _BC, _C, _BC]),
    SequencePattern4Phase('A ↔ center',      [_A, _CENTER]),
    SequencePattern4Phase('B ↔ center',      [_B, _CENTER]),
    SequencePattern4Phase('C ↔ center',      [_C, _CENTER]),
    SequencePattern4Phase('D ↔ center',      [_D, _CENTER]),
    SequencePattern4Phase('A+D ↔ center',    [_AD, _CENTER]),
    SequencePattern4Phase('B+C ↔ center',    [_BC, _CENTER]),
    SequencePattern4Phase('A + [B→C→D]',     [_AB, _AC, _AD]),
    SequencePattern4Phase('A + [B→C→D] slow',[_AB, _ABC, _AC, _ACD, _AD, _ABD]),
    SequencePattern4Phase('A + [B→C→D] ctr', [_AB, _CENTER, _AC, _CENTER, _AD, _CENTER]),
  ];
}

// ──────────────────────────────────────────────
// 3-Phase types
// ──────────────────────────────────────────────

class PatternPosition {
  final double x;
  final double y;

  PatternPosition(this.x, this.y);
}

abstract class ThreephasePattern {
  String get name;
  String get description;
  PatternPosition update(double dt);
  void setVelocity(double velocity);
  void reset();
}

// ──────────────────────────────────────────────
// Circle
// x = cos(t)·A,  y = sin(t)·A
// (velocity applied externally to dt by CommandLoop)
// ──────────────────────────────────────────────

class CirclePattern implements ThreephasePattern {
  double _angle = 0;

  @override
  String get name => "Circle";

  @override
  String get description => "Simple circular motion";

  @override
  PatternPosition update(double dt) {
    _angle += dt;
    _angle %= (2 * pi);
    return PatternPosition(cos(_angle), sin(_angle));
  }

  @override
  void setVelocity(double velocity) {}

  @override
  void reset() {
    _angle = 0;
  }
}

// ──────────────────────────────────────────────
// Figure Eight
// α = sin(t),  β = 0.5·sin(2t)
// ──────────────────────────────────────────────

class FigureEightPattern implements ThreephasePattern {
  double _angle = 0;

  @override
  String get name => "Figure Eight";

  @override
  String get description => "Lemniscate (∞) motion";

  @override
  PatternPosition update(double dt) {
    _angle += dt;
    return PatternPosition(sin(_angle), 0.5 * sin(2 * _angle));
  }

  @override
  void setVelocity(double velocity) {}

  @override
  void reset() {
    _angle = 0;
  }
}

// ──────────────────────────────────────────────
// Vertical Oscillation
// α = sin(2π·0.5·t),  β = 0.2·sin(2π·5·t)
// ──────────────────────────────────────────────

class VerticalOscillationPattern implements ThreephasePattern {
  double _time = 0;

  @override
  String get name => "Vertical Osc.";

  @override
  String get description => "Slow vertical sweep with fast shimmer";

  @override
  PatternPosition update(double dt) {
    _time += dt;
    return PatternPosition(
      sin(2 * pi * 0.5 * _time),
      0.2 * sin(2 * pi * 5 * _time),
    );
  }

  @override
  void setVelocity(double velocity) {}

  @override
  void reset() {
    _time = 0;
  }
}

// ──────────────────────────────────────────────
// Panning 1  (matches desktop panning1.py)
// base = sin(2πt)·(π·120/180)    — ±120° arc
// α = cos(base),  β = sin(base)
// ──────────────────────────────────────────────

class Panning1Pattern implements ThreephasePattern {
  // Desktop: pi * 120 / 180  (NOT 2*pi)
  static const double _arcRad = pi * 120 / 180;
  double _time = 0;

  @override
  String get name => "Panning 1";

  @override
  String get description => "Smooth arc sweep (±120°)";

  @override
  PatternPosition update(double dt) {
    _time += dt;
    final base = sin(2 * pi * _time) * _arcRad;
    return PatternPosition(cos(base), sin(base));
  }

  @override
  void setVelocity(double velocity) {}

  @override
  void reset() {
    _time = 0;
  }
}

// ──────────────────────────────────────────────
// Panning 2  (matches desktop panning2.py)
// base = sin(2πt)
// α = 1 − |base|·1.5,  β = (√3·base/2)
// ──────────────────────────────────────────────

class Panning2Pattern implements ThreephasePattern {
  double _time = 0;

  @override
  String get name => "Panning 2";

  @override
  String get description => "Triangular sweep between three points";

  @override
  PatternPosition update(double dt) {
    _time += dt;
    final base = sin(2 * pi * _time);
    return PatternPosition(
      1 - base.abs() * 1.5,
      (sqrt(3) * base / 2),
    );
  }

  @override
  void setVelocity(double velocity) {}

  @override
  void reset() {
    _time = 0;
  }
}

// ──────────────────────────────────────────────
// Rose Curve (5-petal)  (matches desktop rose_curve.py)
// polar: r = |cos(5θ)|
// α = r·cos(θ),  β = r·sin(θ)
// ──────────────────────────────────────────────

class RoseCurvePattern implements ThreephasePattern {
  double _theta = 0;

  @override
  String get name => "Rose Curve";

  @override
  String get description => "5-petal rose curve";

  @override
  PatternPosition update(double dt) {
    _theta += dt;
    final r = cos(5 * _theta).abs();
    return PatternPosition(r * cos(_theta), r * sin(_theta));
  }

  @override
  void setVelocity(double velocity) {}

  @override
  void reset() {
    _theta = 0;
  }
}

// ──────────────────────────────────────────────
// Tremor Circle  (matches desktop tremor_circle.py)
//
// Base circle r=0.6, period=6 s.
// Tremor frequencies in rad/s (NOT Hz — no 2π factor).
//   tremor_freq1=25 rad/s, tremor_freq2=31.5 rad/s
// Each axis mixes two frequencies with different weights
// and slightly offset multipliers — matches desktop formula.
// ──────────────────────────────────────────────

class TremorCirclePattern implements ThreephasePattern {
  static const double _baseRadius      = 0.6;
  static const double _circlePeriod    = 6.0;   // seconds at velocity=1
  static const double _tremorIntensity = 0.08;
  static const double _tremorFreq1     = 25.0;  // rad/s
  static const double _tremorFreq2     = 31.5;  // rad/s

  double _time = 0;

  @override
  String get name => "Tremor Circle";

  @override
  String get description => "Circle with layered tremor texture";

  @override
  PatternPosition update(double dt) {
    _time += dt;

    // Base circular motion
    final circleAngle = (_time / _circlePeriod) * 2 * pi;
    final baseAlpha = _baseRadius * cos(circleAngle);
    final baseBeta  = _baseRadius * sin(circleAngle);

    // Tremor — frequencies in rad/s, different multipliers per axis
    final tremorAlpha = _tremorIntensity * (
      sin(_time * _tremorFreq1)        * 0.6 +
      sin(_time * _tremorFreq2 * 1.3)  * 0.4
    );
    final tremorBeta = _tremorIntensity * (
      cos(_time * _tremorFreq1 * 1.1)  * 0.6 +
      cos(_time * _tremorFreq2 * 0.9)  * 0.4
    );

    final tremorEnvelope = 0.8 + 0.2 * sin(_time * 0.7);

    double alpha = baseAlpha + tremorAlpha * tremorEnvelope;
    double beta  = baseBeta  + tremorBeta  * tremorEnvelope;

    // Clamp to valid range
    alpha = alpha.clamp(-1.0, 1.0);
    beta  = beta.clamp(-1.0, 1.0);

    return PatternPosition(alpha, beta);
  }

  @override
  void setVelocity(double velocity) {}

  @override
  void reset() {
    _time = 0;
  }
}

// ──────────────────────────────────────────────
// Registry
// ──────────────────────────────────────────────

class ThreephasePatternRegistry {
  static final List<ThreephasePattern> all = [
    CirclePattern(),
    FigureEightPattern(),
    VerticalOscillationPattern(),
    Panning1Pattern(),
    Panning2Pattern(),
    RoseCurvePattern(),
    TremorCirclePattern(),
  ];
}
