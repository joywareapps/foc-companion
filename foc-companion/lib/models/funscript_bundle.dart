import 'package:foc_companion/models/funscript.dart';

/// A bundle of per-axis funscripts, imported from a `.focb` zip file.
class FunscriptBundle {
  final String id;
  final String name;
  final DateTime importDate;
  final int durationMs;
  final String sourceFile;
  final Map<String, Funscript> axes;

  FunscriptBundle({
    required this.id,
    required this.name,
    required this.importDate,
    required this.durationMs,
    required this.sourceFile,
    required this.axes,
  });

  List<String> get axisNames => axes.keys.toList();

  bool get hasAlpha => axes.containsKey('alpha');
  bool get hasBeta => axes.containsKey('beta');
  bool get hasVolume => axes.containsKey('volume');
  bool get hasFrequency => axes.containsKey('frequency');
  bool get hasPulseFrequency => axes.containsKey('pulse_frequency');
  bool get hasPulseWidth => axes.containsKey('pulse_width');
  bool get hasPulseRiseTime => axes.containsKey('pulse_rise_time');
  bool get hasPulseIntervalRandom =>
      axes.containsKey('pulse_interval_random');

  /// Create a bundle from library meta + parsed axes.
  /// Used by [FunscriptBundleLoader.loadFromLibrary].
  factory FunscriptBundle.fromMeta({
    required String id,
    required String name,
    required DateTime importDate,
    required int durationMs,
    required String sourceFile,
    required Map<String, Funscript> axes,
  }) {
    return FunscriptBundle(
      id: id,
      name: name,
      importDate: importDate,
      durationMs: durationMs,
      sourceFile: sourceFile,
      axes: axes,
    );
  }

  /// Serialize for meta.json persistence.
  /// Only stores axis suffixes; funscripts are re-parsed from extracted files.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'importDate': importDate.toUtc().toIso8601String(),
        'durationMs': durationMs,
        'sourceFile': sourceFile,
        'axes': axisNames,
      };

  /// Deserialize meta.json (axes will be empty — call loader to populate).
  factory FunscriptBundle.fromJson(Map<String, dynamic> json) {
    return FunscriptBundle(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      importDate: DateTime.parse(json['importDate'] as String),
      durationMs: json['durationMs'] as int? ?? 0,
      sourceFile: json['sourceFile'] as String? ?? '',
      axes: {},
    );
  }
}
