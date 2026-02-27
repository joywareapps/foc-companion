import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

enum LogLevel { debug, info, warning, error }

class LogEntry {
  final DateTime time;
  final LogLevel level;
  final String message;

  const LogEntry({
    required this.time,
    required this.level,
    required this.message,
  });
}

/// Global application logger.
///
/// Keeps the last [_kMaxEntries] log entries in memory for display in the UI.
/// In debug builds, entries are also forwarded to the console via the [logger]
/// package (colour-coded, with timestamps).
///
/// Usage:
///   AppLogger.instance.i("Connected to device");
///   AppLogger.instance.e("Proto parse failed", error: e);
class AppLogger extends ChangeNotifier {
  AppLogger._() {
    if (kDebugMode) {
      _console = Logger(
        printer: SimplePrinter(printTime: true, colors: true),
        filter: DevelopmentFilter(),
      );
    }
  }

  static final AppLogger instance = AppLogger._();

  static const int _kMaxEntries = 500;

  Logger? _console; // non-null only in debug builds
  final List<LogEntry> _entries = [];

  List<LogEntry> get entries => List.unmodifiable(_entries);

  void d(String message) {
    _console?.d(message);
    _append(LogLevel.debug, message);
  }

  void i(String message) {
    _console?.i(message);
    _append(LogLevel.info, message);
  }

  void w(String message) {
    _console?.w(message);
    _append(LogLevel.warning, message);
  }

  void e(String message, {Object? error}) {
    final full = error != null ? '$message — $error' : message;
    _console?.e(full);
    _append(LogLevel.error, full);
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  void _append(LogLevel level, String message) {
    _entries.add(LogEntry(time: DateTime.now(), level: level, message: message));
    if (_entries.length > _kMaxEntries) _entries.removeAt(0);
    notifyListeners();
  }
}
