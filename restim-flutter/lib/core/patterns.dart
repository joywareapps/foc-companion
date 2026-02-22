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

class PatternPosition {
  final double x;
  final double y;

  PatternPosition(this.x, this.y);
}

abstract class ThreephasePattern {
  String get name;
  PatternPosition update(double dt);
  void setVelocity(double velocity);
}

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
}
