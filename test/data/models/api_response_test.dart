import 'package:employment_department/data/models/api_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponse', () {
    group('fromJson', () {
      test('should deserialize successful response with data', () {
        // Arrange
        final json = {
          'success': true,
          'message': 'Operation successful',
          'data': 'test data',
          'error': null,
          'timestamp': '2024-01-01T00:00:00Z',
        };

        // Act
        final response = ApiResponse<String>.fromJson(
          json,
          (data) => data as String,
        );

        // Assert
        expect(response.success, true);
        expect(response.message, 'Operation successful');
        expect(response.data, 'test data');
        expect(response.error, null);
        expect(response.timestamp, '2024-01-01T00:00:00Z');
      });

      test('should deserialize error response', () {
        // Arrange
        final json = {
          'success': false,
          'message': 'Operation failed',
          'data': null,
          'error': 'ERROR_CODE',
          'timestamp': '2024-01-01T00:00:00Z',
        };

        // Act
        final response = ApiResponse<String>.fromJson(
          json,
          (data) => data as String,
        );

        // Assert
        expect(response.success, false);
        expect(response.message, 'Operation failed');
        expect(response.data, null);
        expect(response.error, 'ERROR_CODE');
        expect(response.timestamp, '2024-01-01T00:00:00Z');
      });

      test('should deserialize response with null data', () {
        // Arrange
        final json = {
          'success': true,
          'message': 'Deleted successfully',
          'data': null,
          'error': null,
          'timestamp': '2024-01-01T00:00:00Z',
        };

        // Act
        final response = ApiResponse<String?>.fromJson(
          json,
          (data) => data as String?,
        );

        // Assert
        expect(response.success, true);
        expect(response.message, 'Deleted successfully');
        expect(response.data, null);
        expect(response.error, null);
      });

      test('should deserialize response with complex data type', () {
        // Arrange
        final json = {
          'success': true,
          'message': 'List retrieved',
          'data': [1, 2, 3],
          'error': null,
          'timestamp': '2024-01-01T00:00:00Z',
        };

        // Act
        final response = ApiResponse<List<int>>.fromJson(
          json,
          (data) => (data as List<dynamic>).map((e) => e as int).toList(),
        );

        // Assert
        expect(response.success, true);
        expect(response.data, [1, 2, 3]);
      });
    });

    group('toJson', () {
      test('should serialize response with data', () {
        // Arrange
        final response = ApiResponse<String>(
          success: true,
          message: 'Success',
          data: 'test data',
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Act
        final json = response.toJson((data) => data);

        // Assert
        expect(json['success'], true);
        expect(json['message'], 'Success');
        expect(json['data'], 'test data');
        expect(json['error'], null);
        expect(json['timestamp'], '2024-01-01T00:00:00Z');
      });

      test('should serialize response with null data', () {
        // Arrange
        final response = ApiResponse<String>(
          success: true,
          message: 'Success',
          data: null,
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Act
        final json = response.toJson((data) => data);

        // Assert
        expect(json['data'], null);
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        // Arrange
        final response1 = ApiResponse<String>(
          success: true,
          message: 'Success',
          data: 'test',
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        final response2 = ApiResponse<String>(
          success: true,
          message: 'Success',
          data: 'test',
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Assert
        expect(response1, equals(response2));
        expect(response1.hashCode, equals(response2.hashCode));
      });

      test('should not be equal when fields differ', () {
        // Arrange
        final response1 = ApiResponse<String>(
          success: true,
          message: 'Success',
          data: 'test1',
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        final response2 = ApiResponse<String>(
          success: true,
          message: 'Success',
          data: 'test2',
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Assert
        expect(response1, isNot(equals(response2)));
      });
    });

    group('unwrap', () {
      test('should return data when success is true and data is non-null', () {
        // Arrange
        final response = ApiResponse<String>(
          success: true,
          message: 'Success',
          data: 'test data',
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Act
        final result = response.unwrap();

        // Assert
        expect(result, 'test data');
      });

      test('should throw exception when success is false', () {
        // Arrange
        final response = ApiResponse<String>(
          success: false,
          message: 'Operation failed',
          data: null,
          error: 'ERROR_CODE',
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Act & Assert
        expect(
          () => response.unwrap(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('API Error: Operation failed (ERROR_CODE)'),
            ),
          ),
        );
      });

      test('should throw exception when success is true but data is null', () {
        // Arrange
        final response = ApiResponse<String>(
          success: true,
          message: 'Success',
          data: null,
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Act & Assert
        expect(
          () => response.unwrap(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Expected data but received null'),
            ),
          ),
        );
      });

      test('should include UNKNOWN when error code is null', () {
        // Arrange
        final response = ApiResponse<String>(
          success: false,
          message: 'Operation failed',
          data: null,
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Act & Assert
        expect(
          () => response.unwrap(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('API Error: Operation failed (UNKNOWN)'),
            ),
          ),
        );
      });
    });

    group('unwrapNullable', () {
      test('should return data when success is true and data is non-null', () {
        // Arrange
        final response = ApiResponse<String>(
          success: true,
          message: 'Success',
          data: 'test data',
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Act
        final result = response.unwrapNullable();

        // Assert
        expect(result, 'test data');
      });

      test('should return null when success is true and data is null', () {
        // Arrange
        final response = ApiResponse<String>(
          success: true,
          message: 'Deleted successfully',
          data: null,
          error: null,
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Act
        final result = response.unwrapNullable();

        // Assert
        expect(result, null);
      });

      test('should throw exception when success is false', () {
        // Arrange
        final response = ApiResponse<String>(
          success: false,
          message: 'Operation failed',
          data: null,
          error: 'ERROR_CODE',
          timestamp: '2024-01-01T00:00:00Z',
        );

        // Act & Assert
        expect(
          () => response.unwrapNullable(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('API Error: Operation failed (ERROR_CODE)'),
            ),
          ),
        );
      });
    });
  });
}
