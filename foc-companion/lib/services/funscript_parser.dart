import 'dart:convert';

import 'package:foc_companion/models/funscript.dart';
import 'package:foc_companion/services/app_logger.dart';

/// Parses funscript JSON and provides interpolated value lookups.
class FunscriptParser {
  FunscriptParser._();

  /// Parse raw JSON string into a [Funscript] with actions sorted by `at`.
  static Funscript parse(String jsonContent) {
    try {
      final json = jsonDecode(jsonContent) as Map<String, dynamic>;

      final version = json['version'] as String?;
      final inverted = json['inverted'] as bool? ?? false;

      final rawActions = json['actions'] as List<dynamic>?;
      final actions = <FunscriptAction>[];

      if (rawActions != null) {
        for (final a in rawActions) {
          actions.add(FunscriptAction.fromJson(a as Map<String, dynamic>));
        }
      }

      actions.sort((a, b) => a.at.compareTo(b.at));

      AppLogger.instance.d('FunscriptParser: parsed ${actions.length} actions');
      return Funscript(
        actions: actions,
        version: version,
        inverted: inverted,
      );
    } catch (e) {
      AppLogger.instance.e('FunscriptParser: failed to parse', error: e);
      rethrow;
    }
  }

  /// Get interpolated normalized value at [timeMs].
  /// Returns a value in 0.0–1.0 range.
  /// Uses linear interpolation between surrounding actions via binary search.
  /// Respects the script's `inverted` flag.
  static double getValueAt(Funscript script, int timeMs) {
    final actions = script.actions;

    if (actions.isEmpty) return 0.5;

    if (actions.length == 1) {
      return _applyInvert(actions.first.pos / 100.0, script.inverted);
    }

    // Before first action
    if (timeMs <= actions.first.at) {
      return _applyInvert(actions.first.pos / 100.0, script.inverted);
    }

    // After last action
    if (timeMs >= actions.last.at) {
      return _applyInvert(actions.last.pos / 100.0, script.inverted);
    }

    // Binary search for surrounding actions
    int lo = 0;
    int hi = actions.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) ~/ 2;
      if (actions[mid].at <= timeMs) {
        lo = mid;
      } else {
        hi = mid;
      }
    }

    final a = actions[lo];
    final b = actions[hi];
    final t = (timeMs - a.at) / (b.at - a.at);
    final raw = (a.pos + t * (b.pos - a.pos)) / 100.0;
    return _applyInvert(raw.clamp(0.0, 1.0), script.inverted);
  }

  static double _applyInvert(double value, bool inverted) {
    return inverted ? 1.0 - value : value;
  }
}
