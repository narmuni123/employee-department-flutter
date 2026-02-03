import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employment_department/core/constants/api_constants.dart';
import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/core/network/api_client.dart';
import 'package:employment_department/data/datasources/department_remote_datasource.dart';
import 'package:employment_department/data/models/department_model.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late DepartmentRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = DepartmentRemoteDataSourceImpl(mockApiClient);
  });

  group('createDepartment', () {
    const testDepartment = DepartmentModel(
      id: 0,
      name: 'Engineering',
      location: 'Building A',
      employees: [],
    );

    test('should wrap payload in ApiRequest and send to backend', () async {
      // Arrange
      final expectedResponse = Response<Map<String, dynamic>>(
        data: {
          'success': true,
          'message': 'Department created successfully',
          'data': {
            'id': 101,
            'name': 'Engineering',
            'location': 'Building A',
            'employees': [],
          },
          'error': null,
          'timestamp': '2024-01-15T10:30:00Z',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ApiConstants.departments),
      );

      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          ApiConstants.departments,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await dataSource.createDepartment(testDepartment);

      // Assert
      expect(result.id, 101);
      expect(result.name, 'Engineering');
      expect(result.location, 'Building A');

      // Verify the request was wrapped correctly
      final captured = verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          ApiConstants.departments,
          data: captureAny(named: 'data'),
        ),
      ).captured;

      expect(captured.length, 1);
      final requestData = captured[0] as Map<String, dynamic>;

      // Verify ApiRequest structure
      expect(requestData.containsKey('requestId'), true);
      expect(requestData.containsKey('source'), true);
      expect(requestData.containsKey('payload'), true);
      expect(requestData['source'], 'flutter_app');
      expect(requestData['requestId'], isNotEmpty);

      // Verify payload contains department data
      final payload = requestData['payload'] as Map<String, dynamic>;
      expect(payload['name'], 'Engineering');
      expect(payload['location'], 'Building A');
    });

    test('should throw ParsingException when response parsing fails', () async {
      // Arrange
      final malformedResponse = Response<Map<String, dynamic>>(
        data: {
          'success': true,
          'message': 'Success',
          'data': 'invalid_data', // Should be a map, not a string
          'error': null,
          'timestamp': '2024-01-15T10:30:00Z',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ApiConstants.departments),
      );

      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          ApiConstants.departments,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => malformedResponse);

      // Act & Assert
      expect(
        () => dataSource.createDepartment(testDepartment),
        throwsA(isA<ParsingException>()),
      );
    });

    test('should throw NetworkException on connection error', () async {
      // Arrange
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          ApiConstants.departments,
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.departments),
          type: DioExceptionType.connectionError,
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.createDepartment(testDepartment),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
