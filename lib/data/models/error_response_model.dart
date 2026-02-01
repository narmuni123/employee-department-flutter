import 'package:equatable/equatable.dart';

class ErrorResponseModel extends Equatable {
  final String timestamp;
  final int status;
  final String error;
  final String message;

  const ErrorResponseModel({
    required this.timestamp,
    required this.status,
    required this.error,
    required this.message,
  });

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return ErrorResponseModel(
      timestamp: json['timestamp'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      error: json['error'] as String? ?? 'Unknown error',
      message: json['message'] as String? ?? 'An unexpected error occurred',
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'status': status,
    'error': error,
    'message': message,
  };

  @override
  List<Object?> get props => [timestamp, status, error, message];
}
