sealed class AppException implements Exception {
  String get message;
}

class NetworkException extends AppException {
  @override
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkException &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class ServerException extends AppException {
  final int statusCode;

  @override
  final String message;

  ServerException(this.statusCode, this.message);

  @override
  String toString() => 'ServerException: [$statusCode] $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerException &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode &&
          message == other.message;

  @override
  int get hashCode => Object.hash(statusCode, message);
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  @override
  final String message;

  ValidationException(this.fieldErrors) : message = 'Validation failed';

  @override
  String toString() => 'ValidationException: $message - $fieldErrors';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationException &&
          runtimeType == other.runtimeType &&
          _mapEquals(fieldErrors, other.fieldErrors);

  @override
  int get hashCode => Object.hashAll(fieldErrors.entries);

  static bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

class ParsingException extends AppException {
  final String details;

  @override
  final String message;

  ParsingException(this.message, this.details);

  @override
  String toString() => 'ParsingException: $message - $details';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsingException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          details == other.details;

  @override
  int get hashCode => Object.hash(message, details);
}
