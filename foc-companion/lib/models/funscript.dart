/// A single keyframe in a funscript file.
class FunscriptAction {
  final int at; // timestamp in milliseconds
  final int pos; // position 0–100

  const FunscriptAction({required this.at, required this.pos});

  factory FunscriptAction.fromJson(Map<String, dynamic> json) {
    return FunscriptAction(
      at: json['at'] as int? ?? 0,
      pos: json['pos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'at': at, 'pos': pos};
}

/// Parsed funscript data with sorted actions.
class Funscript {
  final List<FunscriptAction> actions; // sorted by `at`
  final String? version;
  final bool inverted;

  Funscript({
    required List<FunscriptAction> actions,
    this.version,
    this.inverted = false,
  }) : actions = List.unmodifiable(actions);

  /// Duration of the script in milliseconds.
  /// Returns 0 if there are no actions.
  int get durationMs => actions.isEmpty ? 0 : actions.last.at;
}
