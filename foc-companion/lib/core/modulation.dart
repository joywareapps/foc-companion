import 'dart:math';
import 'package:foc_companion/models/settings_models.dart';

/// Oscillates between -1 and +1 using one of four wave shapes.
/// Returns 0 when mode is 'off'.
class Modulator {
  PulseModulationConfig config;
  double _time = 0;

  Modulator(this.config);

  /// Evaluate the configured wave shape at [phase] (radians, [0, 2π)).
  double _waveValue(double phase) {
    switch (config.function) {
      case 'triangle':
        return 2 * (phase / pi - 1).abs() - 1;
      case 'saw':
        final c = config.center.clamp(0.01, 0.99);
        final norm = phase / (2 * pi);
        return norm < c
            ? (norm / c) * 2 - 1
            : 1 - ((norm - c) / (1 - c)) * 2;
      case 'square':
        return phase < config.dutyCycle.clamp(0.1, 0.9) * 2 * pi ? 1.0 : -1.0;
      case 'sine':
      default:
        return sin(phase);
    }
  }

  /// Advance time by [dt] seconds and return the current wave value in [-1, 1].
  double update(double dt, double patternVelocity) {
    if (config.mode == 'off') return 0.0;
    _time += dt * config.speedMultiplier * patternVelocity;
    return _waveValue((_time * 2 * pi) % (2 * pi));
  }

  /// Wave value at the current time shifted by [degrees].
  /// Call after [update] to sample the oscillator at a phase offset.
  double valueAtPhaseDeg(double degrees) {
    final phaseOffset = degrees * pi / 180;
    return _waveValue((_time * 2 * pi + phaseOffset) % (2 * pi));
  }

  void reset() {
    _time = 0;
  }
}
