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
  FourPhaseIntensity update(double dt);
}

/// Cycles through each electrode in sequence (A → B → C → D → A…).
/// Active electrode is at full power; idle electrodes at [idleLevel].
class CyclePattern4Phase implements FourphasePattern {
  static const double _active = 1.0;
  static const double _idle = 0.33;
  static const double _stepDuration = 2.0; // seconds per electrode

  int _currentElectrode = 0;
  double _elapsed = 0;

  @override
  String get name => "Cycle";

  @override
  FourPhaseIntensity update(double dt) {
    _elapsed += dt;
    if (_elapsed >= _stepDuration) {
      _elapsed -= _stepDuration;
      _currentElectrode = (_currentElectrode + 1) % 4;
    }
    final vals = [_idle, _idle, _idle, _idle]..[_currentElectrode] = _active;
    return FourPhaseIntensity(vals[0], vals[1], vals[2], vals[3]);
  }
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
// ──────────────────────────────────────────────

class CirclePattern implements ThreephasePattern {
  double _angle = 0;
  double _amplitude;
  double _velocity;

  CirclePattern({double amplitude = 1.0, double velocity = 1.0})
      : _amplitude = amplitude,
        _velocity = velocity;

  @override
  String get name => "Circle";

  @override
  String get description => "Simple circular motion";

  @override
  PatternPosition update(double dt) {
    _angle += dt * _velocity;
    _angle %= (2 * pi);

    double x = cos(_angle) * _amplitude;
    double y = sin(_angle) * _amplitude;

    return PatternPosition(x, y);
  }

  void setAmplitude(double amplitude) {
    _amplitude = amplitude;
  }

  @override
  void setVelocity(double velocity) {
    _velocity = velocity;
  }

  @override
  void reset() {
    _angle = 0;
  }
}

// ──────────────────────────────────────────────
// Figure Eight
// α = sin(t)·A,  β = 0.5·sin(2t)·A
// ──────────────────────────────────────────────

class FigureEightPattern implements ThreephasePattern {
  double _time = 0;

  @override
  String get name => "Figure Eight";

  @override
  String get description => "Lemniscate (∞) motion";

  @override
  PatternPosition update(double dt) {
    _time += dt;
    return PatternPosition(
      sin(_time),
      0.5 * sin(2 * _time),
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
// Panning 1
// base = sin(2πt)·(2π·120/180)
// α = cos(base),  β = sin(base)
// ──────────────────────────────────────────────

class Panning1Pattern implements ThreephasePattern {
  static const double _arcRad = 2 * pi * 120 / 180; // 240° arc
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
// Panning 2
// base = sin(2πt)
// α = 1 − |base|·1.5,  β = (√3·base/2)
// Traces an equilateral triangle.
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
// Rose Curve (5-petal)
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
// Tremor Circle
// Base circle r=0.6 (period 6 s) with 25 Hz + 31.5 Hz tremor
// and slowly varying envelope 0.8+0.2·sin(t·0.7)
// ──────────────────────────────────────────────

class TremorCirclePattern implements ThreephasePattern {
  static const double _baseRadius = 0.6;
  static const double _basePeriod = 6.0; // seconds at velocity=1
  static const double _tremorFreq1 = 25.0; // Hz
  static const double _tremorFreq2 = 31.5; // Hz
  static const double _tremorAmp = 0.15;

  double _time = 0;
  double _baseAngle = 0;

  @override
  String get name => "Tremor Circle";

  @override
  String get description => "Circle with layered tremor texture";

  @override
  PatternPosition update(double dt) {
    _time += dt;
    _baseAngle += dt * 2 * pi / _basePeriod;

    final envelope = 0.8 + 0.2 * sin(_time * 0.7);

    final baseX = _baseRadius * cos(_baseAngle);
    final baseY = _baseRadius * sin(_baseAngle);

    final tremorX = _tremorAmp * sin(2 * pi * _tremorFreq1 * _time) +
        _tremorAmp * sin(2 * pi * _tremorFreq2 * _time);
    final tremorY = _tremorAmp * cos(2 * pi * _tremorFreq1 * _time) +
        _tremorAmp * cos(2 * pi * _tremorFreq2 * _time);

    return PatternPosition(
      envelope * (baseX + tremorX),
      envelope * (baseY + tremorY),
    );
  }

  @override
  void setVelocity(double velocity) {}

  @override
  void reset() {
    _time = 0;
    _baseAngle = 0;
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
