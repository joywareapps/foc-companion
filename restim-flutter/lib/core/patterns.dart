import 'dart:math';

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
