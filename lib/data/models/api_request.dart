import 'package:equatable/equatable.dart';

/// Generic wrapper class for standardized API requests to the backend.
///
/// The backend requires POST and PUT requests to wrap payloads in this structure,
/// containing metadata about the request source and a unique identifier for tracking.
///
/// Type parameter [T] represents the type of data contained in the request payload.
class ApiRequest<T> extends Equatable {
  /// Unique identifier for tracking and debugging the request
  final String requestId;

  /// Source identifier indicating where the request originated from
  final String source;

  /// The actual request payload
  final T payload;

  const ApiRequest({
    required this.requestId,
    required this.source,
    required this.payload,
  });

  /// Factory constructor for deserializing JSON requests.
  ///
  /// [json] - The JSON map to deserialize
  /// [fromJsonT] - Function to deserialize the payload field to type T
  ///
  /// Example usage:
  /// ```dart
  /// final request = ApiRequest<Department>.fromJson(
  ///   jsonData,
  ///   (json) => Department.fromJson(json as Map<String, dynamic>),
  /// );
  /// ```
  factory ApiRequest.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiRequest<T>(
      requestId: json['requestId'] as String,
      source: json['source'] as String,
      payload: fromJsonT(json['payload']),
    );
  }

  /// Serializes the ApiRequest to JSON.
  ///
  /// [toJsonT] - Function to serialize the payload field of type T to JSON
  ///
  /// Example usage:
  /// ```dart
  /// final json = request.toJson((data) => data.toJson());
  /// ```
  Map<String, dynamic> toJson(Object? Function(T data) toJsonT) {
    return {
      'requestId': requestId,
      'source': source,
      'payload': toJsonT(payload),
    };
  }

  @override
  List<Object?> get props => [requestId, source, payload];
}
