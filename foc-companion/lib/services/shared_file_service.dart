import 'dart:async';

import 'package:foc_companion/services/app_logger.dart';

/// Singleton service that bridges incoming .focb file URIs
/// (from receive_sharing_intent or direct VIEW intents)
/// to the rest of the app.
class SharedFileService {
  SharedFileService._();

  static Uri? _pendingUri;
  static final _controller = StreamController<Uri>.broadcast();

  /// Stream of incoming .focb file URIs.
  static Stream<Uri> get stream => _controller.stream;

  /// Enqueue a shared file URI for processing.
  static void add(Uri uri) {
    AppLogger.instance.i('SharedFileService: received $uri');
    _pendingUri = uri;
    _controller.add(uri);
  }

  /// Peek at the pending URI without consuming it.
  static Uri? get pendingUri => _pendingUri;

  /// Consume and return the pending URI, if any.
  /// Returns null if nothing is pending.
  static Uri? consumePending() {
    final uri = _pendingUri;
    _pendingUri = null;
    return uri;
  }

  /// Discard a URI that was handled or invalid.
  static void discard(Uri uri) {
    AppLogger.instance.d('SharedFileService: discarded $uri');
  }
}
