import 'package:uuid/uuid.dart';

/// Utility class for generating unique request IDs for API requests.
///
/// Uses UUID v4 format to ensure globally unique identifiers with high
/// probability. Request IDs are used for tracking and debugging API requests.
class RequestIdGenerator {
  static const _uuid = Uuid();

  /// Generates a unique request ID using UUID v4 format.
  ///
  /// Returns a new UUID v4 string on each invocation, ensuring global
  /// uniqueness with high probability.
  ///
  /// Example:
  /// ```dart
  /// final requestId = RequestIdGenerator.generate();
  /// // Returns: "550e8400-e29b-41d4-a716-446655440000"
  /// ```
  static String generate() {
    return _uuid.v4();
  }
}
