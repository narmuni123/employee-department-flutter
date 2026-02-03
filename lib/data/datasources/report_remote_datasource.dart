import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/api_response.dart';

abstract class ReportRemoteDataSource {
  Future<List<int>> downloadDepartmentEmployeesReport();
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<int>> downloadDepartmentEmployeesReport() async {
    try {
      final response = await apiClient.downloadFile(
        ApiConstants.departmentEmployeesReport,
      );

      // Check content-type header to determine response format
      final contentType = response.headers.value('content-type');

      if (contentType != null && contentType.contains('application/json')) {
        // JSON response - deserialize as ApiResponse and handle error
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => json,
        );

        if (!apiResponse.success) {
          throw Exception(
            'API Error: ${apiResponse.message} (${apiResponse.error ?? "UNKNOWN"})',
          );
        }

        // If JSON response is successful but we expected PDF, throw error
        throw Exception('Expected PDF but received JSON response');
      } else {
        // Binary (PDF) response - process directly without wrapper
        return response.data!;
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Helper method to parse error responses and extract detailed error messages.
  ///
  /// Attempts to parse the response body as ApiResponse to get the error message.
  /// Falls back to HTTP status code error messages if parsing fails.
  AppException _handleError(DioException exception) {
    final response = exception.response;

    if (response != null && response.data is Map<String, dynamic>) {
      try {
        // Try to parse as ApiResponse to get detailed error message
        final apiResponse = ApiResponse<dynamic>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => json,
        );

        if (!apiResponse.success) {
          final statusCode = response.statusCode ?? 0;
          return ServerException(
            statusCode,
            '${apiResponse.message} (${apiResponse.error ?? "UNKNOWN"})',
          );
        }
      } catch (e) {
        // If parsing fails, fall back to default error handling
      }
    }

    // Fall back to default error handling from ApiClient
    if (exception.type == DioExceptionType.connectionError ||
        exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return NetworkException('No internet connection');
    }

    if (response != null) {
      final statusCode = response.statusCode ?? 0;
      String? errorMessage;

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        errorMessage = data['message'] as String?;
      }

      return ServerException(
        statusCode,
        errorMessage ?? 'An unexpected error occurred',
      );
    }

    return NetworkException('No internet connection');
  }
}
