import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/domain/entities/department.dart';
import 'package:employment_department/domain/usecases/get_departments.dart';
import 'package:employment_department/presentation/bloc/department/department_bloc.dart';
import 'package:employment_department/presentation/bloc/department/department_event.dart';
import 'package:employment_department/presentation/bloc/department/department_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDepartments extends Mock implements GetDepartments {}

void main() {
  late MockGetDepartments mockGetDepartments;
  late DepartmentBloc departmentBloc;

  setUp(() {
    mockGetDepartments = MockGetDepartments();
    departmentBloc = DepartmentBloc(getDepartments: mockGetDepartments);
  });

  tearDown(() {
    departmentBloc.close();
  });

  // Test data
  const testDepartments = [
    Department(id: 1, name: 'Engineering', location: 'Building A'),
    Department(id: 2, name: 'Marketing', location: 'Building B'),
    Department(id: 3, name: 'HR', location: 'Building C'),
  ];

  group('DepartmentBloc', () {
    test('initial state is DepartmentInitial', () {
      expect(departmentBloc.state, const DepartmentInitial());
    });

    group('LoadDepartments', () {
      blocTest<DepartmentBloc, DepartmentState>(
        'emits [DepartmentLoading, DepartmentLoaded] when departments are fetched successfully',
        build: () {
          when(
            () => mockGetDepartments(),
          ).thenAnswer((_) async => const Right(testDepartments));
          return DepartmentBloc(getDepartments: mockGetDepartments);
        },
        act: (bloc) => bloc.add(const LoadDepartments()),
        expect: () => [
          const DepartmentLoading(),
          const DepartmentLoaded(testDepartments),
        ],
        verify: (_) {
          verify(() => mockGetDepartments()).called(1);
        },
      );

      blocTest<DepartmentBloc, DepartmentState>(
        'emits [DepartmentLoading, DepartmentLoaded] with empty list when no departments exist',
        build: () {
          when(
            () => mockGetDepartments(),
          ).thenAnswer((_) async => const Right(<Department>[]));
          return DepartmentBloc(getDepartments: mockGetDepartments);
        },
        act: (bloc) => bloc.add(const LoadDepartments()),
        expect: () => [
          const DepartmentLoading(),
          const DepartmentLoaded(<Department>[]),
        ],
      );

      blocTest<DepartmentBloc, DepartmentState>(
        'emits [DepartmentLoading, DepartmentError] with network error message when NetworkException occurs',
        build: () {
          when(() => mockGetDepartments()).thenAnswer(
            (_) async => Left(NetworkException('Connection failed')),
          );
          return DepartmentBloc(getDepartments: mockGetDepartments);
        },
        act: (bloc) => bloc.add(const LoadDepartments()),
        expect: () => [
          const DepartmentLoading(),
          const DepartmentError('No internet connection'),
        ],
      );

      blocTest<DepartmentBloc, DepartmentState>(
        'emits [DepartmentLoading, DepartmentError] with 404 message when ServerException with 404 occurs',
        build: () {
          when(
            () => mockGetDepartments(),
          ).thenAnswer((_) async => Left(ServerException(404, 'Not found')));
          return DepartmentBloc(getDepartments: mockGetDepartments);
        },
        act: (bloc) => bloc.add(const LoadDepartments()),
        expect: () => [
          const DepartmentLoading(),
          const DepartmentError('Resource not found'),
        ],
      );

      blocTest<DepartmentBloc, DepartmentState>(
        'emits [DepartmentLoading, DepartmentError] with 500 message when ServerException with 500 occurs',
        build: () {
          when(() => mockGetDepartments()).thenAnswer(
            (_) async => Left(ServerException(500, 'Internal error')),
          );
          return DepartmentBloc(getDepartments: mockGetDepartments);
        },
        act: (bloc) => bloc.add(const LoadDepartments()),
        expect: () => [
          const DepartmentLoading(),
          const DepartmentError('Server error, please try again later'),
        ],
      );

      blocTest<DepartmentBloc, DepartmentState>(
        'emits [DepartmentLoading, DepartmentError] with API message for other server errors',
        build: () {
          when(() => mockGetDepartments()).thenAnswer(
            (_) async => Left(ServerException(400, 'Bad request from API')),
          );
          return DepartmentBloc(getDepartments: mockGetDepartments);
        },
        act: (bloc) => bloc.add(const LoadDepartments()),
        expect: () => [
          const DepartmentLoading(),
          const DepartmentError('Bad request from API'),
        ],
      );

      blocTest<DepartmentBloc, DepartmentState>(
        'emits [DepartmentLoading, DepartmentError] with validation message when ValidationException occurs',
        build: () {
          when(() => mockGetDepartments()).thenAnswer(
            (_) async => Left(ValidationException({'field': 'error'})),
          );
          return DepartmentBloc(getDepartments: mockGetDepartments);
        },
        act: (bloc) => bloc.add(const LoadDepartments()),
        expect: () => [
          const DepartmentLoading(),
          const DepartmentError('Validation failed'),
        ],
      );
    });

    group('RefreshDepartments', () {
      blocTest<DepartmentBloc, DepartmentState>(
        'emits [DepartmentLoading, DepartmentLoaded] when refresh is successful',
        build: () {
          when(
            () => mockGetDepartments(),
          ).thenAnswer((_) async => const Right(testDepartments));
          return DepartmentBloc(getDepartments: mockGetDepartments);
        },
        act: (bloc) => bloc.add(const RefreshDepartments()),
        expect: () => [
          const DepartmentLoading(),
          const DepartmentLoaded(testDepartments),
        ],
        verify: (_) {
          verify(() => mockGetDepartments()).called(1);
        },
      );

      blocTest<DepartmentBloc, DepartmentState>(
        'emits [DepartmentLoading, DepartmentError] when refresh fails',
        build: () {
          when(
            () => mockGetDepartments(),
          ).thenAnswer((_) async => Left(NetworkException('No connection')));
          return DepartmentBloc(getDepartments: mockGetDepartments);
        },
        seed: () => const DepartmentError('Previous error'),
        act: (bloc) => bloc.add(const RefreshDepartments()),
        expect: () => [
          const DepartmentLoading(),
          const DepartmentError('No internet connection'),
        ],
      );

      blocTest<DepartmentBloc, DepartmentState>(
        'can refresh after successful load',
        build: () {
          when(
            () => mockGetDepartments(),
          ).thenAnswer((_) async => const Right(testDepartments));
          return DepartmentBloc(getDepartments: mockGetDepartments);
        },
        seed: () => const DepartmentLoaded(testDepartments),
        act: (bloc) => bloc.add(const RefreshDepartments()),
        expect: () => [
          const DepartmentLoading(),
          const DepartmentLoaded(testDepartments),
        ],
      );
    });

    group('DepartmentState', () {
      test('DepartmentLoaded.isEmpty returns true for empty list', () {
        const state = DepartmentLoaded(<Department>[]);
        expect(state.isEmpty, true);
      });

      test('DepartmentLoaded.isEmpty returns false for non-empty list', () {
        const state = DepartmentLoaded(testDepartments);
        expect(state.isEmpty, false);
      });

      test('DepartmentInitial props are empty', () {
        const state = DepartmentInitial();
        expect(state.props, []);
      });

      test('DepartmentLoading props are empty', () {
        const state = DepartmentLoading();
        expect(state.props, []);
      });

      test('DepartmentLoaded props contain departments', () {
        const state = DepartmentLoaded(testDepartments);
        expect(state.props, [testDepartments]);
      });

      test('DepartmentError props contain message', () {
        const state = DepartmentError('Test error');
        expect(state.props, ['Test error']);
      });

      test('DepartmentLoaded equality works correctly', () {
        const state1 = DepartmentLoaded(testDepartments);
        const state2 = DepartmentLoaded(testDepartments);
        expect(state1, state2);
      });

      test('DepartmentError equality works correctly', () {
        const state1 = DepartmentError('Error message');
        const state2 = DepartmentError('Error message');
        expect(state1, state2);
      });
    });

    group('DepartmentEvent', () {
      test('LoadDepartments props are empty', () {
        const event = LoadDepartments();
        expect(event.props, []);
      });

      test('RefreshDepartments props are empty', () {
        const event = RefreshDepartments();
        expect(event.props, []);
      });

      test('LoadDepartments equality works correctly', () {
        const event1 = LoadDepartments();
        const event2 = LoadDepartments();
        expect(event1, event2);
      });

      test('RefreshDepartments equality works correctly', () {
        const event1 = RefreshDepartments();
        const event2 = RefreshDepartments();
        expect(event1, event2);
      });
    });
  });
}
