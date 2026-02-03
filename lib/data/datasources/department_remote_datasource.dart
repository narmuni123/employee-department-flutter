import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/api_response.dart';
import '../models/department_model.dart';
import '../models/employee_model.dart';

abstract class DepartmentRemoteDataSource {
  Future<List<DepartmentModel>> getDepartments();
  Future<List<EmployeeModel>> getEmployeesByDepartment(int deptId);
  Future<Map<String, List<EmployeeModel>>> getEmployeesMap();
  Future<DepartmentModel> createDepartment(DepartmentModel department);
  Future<DepartmentModel> updateDepartment(int id, DepartmentModel department);
  Future<void> deleteDepartment(int id);
}

class DepartmentRemoteDataSourceImpl implements DepartmentRemoteDataSource {
  final ApiClient apiClient;

  DepartmentRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<DepartmentModel>> getDepartments() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.departments,
      );

      final apiResponse = ApiResponse<List<DepartmentModel>>.fromJson(
        response.data!,
        (json) => (json as List<dynamic>)
            .map(
              (item) => DepartmentModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );

      return apiResponse.unwrap();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<EmployeeModel>> getEmployeesByDepartment(int deptId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.employeesByDepartment(deptId),
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
    }
  }

  @override
  Future<Map<String, List<EmployeeModel>>> getEmployeesMap() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.departments}/employees-map',
      );

      final apiResponse =
          ApiResponse<Map<String, List<EmployeeModel>>>.fromJson(
            response.data!,
            (json) {
              final map = json as Map<String, dynamic>;
              return map.map(
                (key, value) => MapEntry(
                  key,
                  (value as List<dynamic>)
                      .map(
                        (item) => EmployeeModel.fromJson(
                          item as Map<String, dynamic>,
                        ),
                      )
                      .toList(),
                ),
              );
            },
          );

      return apiResponse.unwrap();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DepartmentModel> createDepartment(DepartmentModel department) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiConstants.departments,
        data: department.toJson(),
      );

      final apiResponse = ApiResponse<DepartmentModel>.fromJson(
        response.data!,
        (json) => DepartmentModel.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse.unwrap();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DepartmentModel> updateDepartment(
    int id,
    DepartmentModel department,
  ) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.departments}/$id',
        data: department.toJson(),
      );

      final apiResponse = ApiResponse<DepartmentModel>.fromJson(
        response.data!,
        (json) => DepartmentModel.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse.unwrap();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteDepartment(int id) async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.departments}/$id',
      );

      final apiResponse = ApiResponse<void>.fromJson(
        response.data!,
        (json) {}, // Return void, not null
      );

      apiResponse.unwrapNullable();
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
