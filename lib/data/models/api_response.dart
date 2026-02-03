import 'package:equatable/equatable.dart';

/// Generic wrapper class for standardized API responses from the backend.
///
/// The backend wraps all responses in this structure, containing metadata
/// about the request success status and the actual data payload.
///
/// Type parameter [T] represents the type of data contained in the response.
class ApiResponse<T> extends Equatable {
  /// Indicates whether the request was successful
  final bool success;

  /// Human-readable message describing the result
  final String message;

  /// The actual response payload (nullable for operations with no content)
  final T? data;

  /// Error code when success is false (nullable)
  final String? error;

  /// ISO 8601 timestamp of the response
  final String timestamp;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    required this.timestamp,
  });

  /// Factory constructor for deserializing JSON responses.
  ///
  /// [json] - The JSON map to deserialize
  /// [fromJsonT] - Function to deserialize the data field to type T
  ///
  /// Example usage:
  /// ```dart
  /// final response = ApiResponse<Department>.fromJson(
  ///   jsonData,
  ///   (json) => Department.fromJson(json as Map<String, dynamic>),
  /// );
  /// ```
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'] as String?,
      timestamp: json['timestamp'] as String,
    );
  }

  /// Serializes the ApiResponse to JSON.
  ///
  /// [toJsonT] - Function to serialize the data field of type T to JSON
  ///
  /// Example usage:
  /// ```dart
  /// final json = response.toJson((data) => data.toJson());
  /// ```
  Map<String, dynamic> toJson(Object? Function(T data) toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
      'error': error,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [success, message, data, error, timestamp];
}

/// Extension methods for unwrapping ApiResponse objects.
///
/// Provides convenient methods to extract data from the wrapper and handle
/// errors consistently across all API calls.
extension ApiResponseExtension<T> on ApiResponse<T> {
  /// Unwraps the ApiResponse and returns the data field.
  ///
  /// Throws an exception if:
  /// - success is false
  /// - data is null (even if success is true)
  ///
  /// Use this method when you expect non-null data in the response.
  T unwrap() {
    if (!success) {
      throw Exception('API Error: $message (${error ?? "UNKNOWN"})');
    }
    if (data == null) {
      throw Exception('API Error: Expected data but received null');
    }
    return data!;
  }

  /// Unwraps the ApiResponse and returns the nullable data field.
  ///
  /// Throws an exception if success is false.
  /// Returns null if data is null (for operations with no content like DELETE).
  ///
  /// Use this method when null data is acceptable (e.g., DELETE operations).
  T? unwrapNullable() {
    if (!success) {
      throw Exception('API Error: $message (${error ?? "UNKNOWN"})');
    }
    return data;
  }
}
