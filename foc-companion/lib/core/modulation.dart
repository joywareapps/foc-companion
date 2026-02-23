import 'dart:math';
import 'package:foc_companion/models/settings_models.dart';

/// Oscillates a pulse-frequency offset using one of four wave shapes.
/// Returns a value in [-depthHz, +depthHz], or 0 when disabled.
class Modulator {
  PulseModulationConfig config;
  double _time = 0;

  Modulator(this.config);

  double update(double dt, double patternVelocity) {
    if (!config.enabled) return 0.0;

    _time += dt * config.speedMultiplier * patternVelocity;
    final phase = (_time * 2 * pi) % (2 * pi);

    double value;
    switch (config.function) {
      case 'triangle':
        value = 2 * (phase / pi - 1).abs() - 1;
        break;
      case 'saw':
        final c = config.center.clamp(0.01, 0.99);
        final norm = phase / (2 * pi);
        if (norm < c) {
          value = (norm / c) * 2 - 1;
        } else {
          value = 1 - ((norm - c) / (1 - c)) * 2;
        }
        break;
      case 'square':
        value = phase < config.dutyCycle.clamp(0.1, 0.9) * 2 * pi ? 1.0 : -1.0;
        break;
      case 'sine':
      default:
        value = sin(phase);
    }

    return value * config.depthHz;
  }

  void reset() {
    _time = 0;
  }
}
