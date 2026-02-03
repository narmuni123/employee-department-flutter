import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/request_id_generator.dart';
import '../models/api_request.dart';
import '../models/api_response.dart';
import '../models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getEmployees();
  Future<EmployeeModel> addEmployee(int deptId, EmployeeModel employee);
  Future<void> deleteEmployee(int deptId, int empId);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final ApiClient apiClient;

  EmployeeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.employees,
      );

      final apiResponse = ApiResponse<List<EmployeeModel>>.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      return apiResponse.unwrap();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ParsingException('Failed to parse response', e.toString());
    }
  }

  @override
  Future<EmployeeModel> addEmployee(int deptId, EmployeeModel employee) async {
    try {
      // Wrap the payload in ApiRequest
      final request = ApiRequest<Map<String, dynamic>>(
        requestId: RequestIdGenerator.generate(),
        source: 'flutter_app',
        payload: employee.toJson(),
      );

      // Send wrapped request
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiConstants.employeesByDepartment(deptId),
        data: request.toJson((data) => data),
      );

      // Unwrap the response
      final apiResponse = ApiResponse<EmployeeModel>.fromJson(
        response.data!,
        (json) => EmployeeModel.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse.unwrap();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ParsingException('Failed to parse response', e.toString());
    }
  }

  @override
  Future<void> deleteEmployee(int deptId, int empId) async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>(
        ApiConstants.employeeById(deptId, empId),
      );

      final apiResponse = ApiResponse<void>.fromJson(
        response.data!,
        (json) {}, // Return void, not null
      );

      apiResponse.unwrapNullable();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ParsingException('Failed to parse response', e.toString());
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
