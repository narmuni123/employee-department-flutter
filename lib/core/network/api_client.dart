import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../error/app_exception.dart';

abstract class ApiClient {
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParams});
  Future<Response<T>> post<T>(String path, {dynamic data});
  Future<Response<T>> put<T>(String path, {dynamic data});
  Future<Response<T>> delete<T>(String path);
  Future<Response<List<int>>> downloadFile(String path);
}

class DioApiClient implements ApiClient {
  final Dio _dio;

  DioApiClient({required String baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
          receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorHandlingInterceptor(),
    ]);
  }

  DioApiClient.withDio(this._dio);

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParams);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    try {
      return await _dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Response<T>> delete<T>(String path) async {
    try {
      return await _dio.delete<T>(path);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Response<List<int>>> downloadFile(String path) async {
    try {
      return await _dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  AppException _handleDioException(DioException exception) {
    if (exception.type == DioExceptionType.connectionError ||
        exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.error is SocketException) {
      return NetworkException('No internet connection');
    }

    final response = exception.response;
    if (response != null) {
      final statusCode = response.statusCode ?? 0;

      String? errorMessage;
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        errorMessage = data['message'] as String?;
      }

      switch (statusCode) {
        case 404:
          return ServerException(
            statusCode,
            errorMessage ?? 'Resource not found',
          );
        case 500:
          return ServerException(
            statusCode,
            errorMessage ?? 'Server error, please try again later',
          );
        default:
          return ServerException(
            statusCode,
            errorMessage ?? 'An unexpected error occurred',
          );
      }
    }

    return NetworkException('No internet connection');
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('┌────────────────────────────────────────────────────────────');
    _log('│ REQUEST: ${options.method} ${options.uri}');
    _log('│ Headers: ${options.headers}');
    if (options.data != null) {
      _log('│ Body: ${options.data}');
    }
    _log('└────────────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('┌────────────────────────────────────────────────────────────');
    _log('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    _log('│ Headers: ${response.headers.map}');
    _log('│ Body: ${response.data}');
    _log('└────────────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('┌────────────────────────────────────────────────────────────');
    _log('│ ERROR: ${err.type} ${err.requestOptions.uri}');
    _log('│ Message: ${err.message}');
    if (err.response != null) {
      _log('│ Status: ${err.response?.statusCode}');
      _log('│ Response: ${err.response?.data}');
    }
    _log('└────────────────────────────────────────────────────────────');
    handler.next(err);
  }

  void _log(String message) {
    // ignore: avoid_print
    print(message);
  }
}

class _ErrorHandlingInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) {
      handler.next(response);
    } else {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );
    }
  }
}
