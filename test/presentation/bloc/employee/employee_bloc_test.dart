import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/domain/entities/employee.dart';
import 'package:employment_department/domain/usecases/delete_employee.dart'
    as usecase;
import 'package:employment_department/domain/usecases/get_employees_by_department.dart';
import 'package:employment_department/presentation/bloc/employee/employee_bloc.dart';
import 'package:employment_department/presentation/bloc/employee/employee_event.dart';
import 'package:employment_department/presentation/bloc/employee/employee_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetEmployeesByDepartment extends Mock
    implements GetEmployeesByDepartment {}

class MockDeleteEmployee extends Mock implements usecase.DeleteEmployee {}

void main() {
  late MockGetEmployeesByDepartment mockGetEmployeesByDepartment;
  late MockDeleteEmployee mockDeleteEmployee;
  late EmployeeBloc employeeBloc;

  setUp(() {
    mockGetEmployeesByDepartment = MockGetEmployeesByDepartment();
    mockDeleteEmployee = MockDeleteEmployee();
    employeeBloc = EmployeeBloc(
      getEmployeesByDepartment: mockGetEmployeesByDepartment,
      deleteEmployee: mockDeleteEmployee,
    );
  });

  tearDown(() {
    employeeBloc.close();
  });

  // Test data
  const testDepartmentId = 1;
  const testEmployees = [
    Employee(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      position: 'Developer',
      salary: 75000.0,
    ),
    Employee(
      id: 2,
      name: 'Jane Smith',
      email: 'jane@example.com',
      position: 'Designer',
      salary: 70000.0,
    ),
    Employee(
      id: 3,
      name: 'Bob Johnson',
      email: 'bob@example.com',
      position: 'Manager',
      salary: 90000.0,
    ),
  ];

  group('EmployeeBloc', () {
    test('initial state is EmployeeInitial', () {
      expect(employeeBloc.state, const EmployeeInitial());
    });

    group('LoadEmployees', () {
      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeLoading, EmployeeLoaded] when employees are fetched successfully',
        build: () {
          when(
            () => mockGetEmployeesByDepartment(testDepartmentId),
          ).thenAnswer((_) async => const Right(testEmployees));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        act: (bloc) => bloc.add(const LoadEmployees(testDepartmentId)),
        expect: () => [
          const EmployeeLoading(),
          const EmployeeLoaded(testEmployees),
        ],
        verify: (_) {
          verify(
            () => mockGetEmployeesByDepartment(testDepartmentId),
          ).called(1);
        },
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeLoading, EmployeeLoaded] with empty list when no employees exist',
        build: () {
          when(
            () => mockGetEmployeesByDepartment(testDepartmentId),
          ).thenAnswer((_) async => const Right(<Employee>[]));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        act: (bloc) => bloc.add(const LoadEmployees(testDepartmentId)),
        expect: () => [
          const EmployeeLoading(),
          const EmployeeLoaded(<Employee>[]),
        ],
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeLoading, EmployeeError] with network error message when NetworkException occurs',
        build: () {
          when(() => mockGetEmployeesByDepartment(testDepartmentId)).thenAnswer(
            (_) async => Left(NetworkException('Connection failed')),
          );
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        act: (bloc) => bloc.add(const LoadEmployees(testDepartmentId)),
        expect: () => [
          const EmployeeLoading(),
          const EmployeeError('No internet connection'),
        ],
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeLoading, EmployeeError] with 404 message when ServerException with 404 occurs',
        build: () {
          when(
            () => mockGetEmployeesByDepartment(testDepartmentId),
          ).thenAnswer((_) async => Left(ServerException(404, 'Not found')));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        act: (bloc) => bloc.add(const LoadEmployees(testDepartmentId)),
        expect: () => [
          const EmployeeLoading(),
          const EmployeeError('Resource not found'),
        ],
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeLoading, EmployeeError] with 500 message when ServerException with 500 occurs',
        build: () {
          when(() => mockGetEmployeesByDepartment(testDepartmentId)).thenAnswer(
            (_) async => Left(ServerException(500, 'Internal error')),
          );
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        act: (bloc) => bloc.add(const LoadEmployees(testDepartmentId)),
        expect: () => [
          const EmployeeLoading(),
          const EmployeeError('Server error, please try again later'),
        ],
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeLoading, EmployeeError] with API message for other server errors',
        build: () {
          when(() => mockGetEmployeesByDepartment(testDepartmentId)).thenAnswer(
            (_) async => Left(ServerException(400, 'Bad request from API')),
          );
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        act: (bloc) => bloc.add(const LoadEmployees(testDepartmentId)),
        expect: () => [
          const EmployeeLoading(),
          const EmployeeError('Bad request from API'),
        ],
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeLoading, EmployeeError] with validation message when ValidationException occurs',
        build: () {
          when(() => mockGetEmployeesByDepartment(testDepartmentId)).thenAnswer(
            (_) async => Left(ValidationException({'field': 'error'})),
          );
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        act: (bloc) => bloc.add(const LoadEmployees(testDepartmentId)),
        expect: () => [
          const EmployeeLoading(),
          const EmployeeError('Validation failed'),
        ],
      );
    });

    group('RefreshEmployees', () {
      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeLoading, EmployeeLoaded] when refresh is successful',
        build: () {
          when(
            () => mockGetEmployeesByDepartment(testDepartmentId),
          ).thenAnswer((_) async => const Right(testEmployees));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        act: (bloc) => bloc.add(const RefreshEmployees(testDepartmentId)),
        expect: () => [
          const EmployeeLoading(),
          const EmployeeLoaded(testEmployees),
        ],
        verify: (_) {
          verify(
            () => mockGetEmployeesByDepartment(testDepartmentId),
          ).called(1);
        },
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeLoading, EmployeeError] when refresh fails',
        build: () {
          when(
            () => mockGetEmployeesByDepartment(testDepartmentId),
          ).thenAnswer((_) async => Left(NetworkException('No connection')));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        seed: () => const EmployeeError('Previous error'),
        act: (bloc) => bloc.add(const RefreshEmployees(testDepartmentId)),
        expect: () => [
          const EmployeeLoading(),
          const EmployeeError('No internet connection'),
        ],
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'can refresh after successful load',
        build: () {
          when(
            () => mockGetEmployeesByDepartment(testDepartmentId),
          ).thenAnswer((_) async => const Right(testEmployees));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        seed: () => const EmployeeLoaded(testEmployees),
        act: (bloc) => bloc.add(const RefreshEmployees(testDepartmentId)),
        expect: () => [
          const EmployeeLoading(),
          const EmployeeLoaded(testEmployees),
        ],
      );
    });

    group('DeleteEmployee', () {
      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeDeleting, EmployeeDeleteSuccess] when deletion is successful',
        build: () {
          when(
            () => mockDeleteEmployee(testDepartmentId, 1),
          ).thenAnswer((_) async => const Right(null));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        seed: () => const EmployeeLoaded(testEmployees),
        act: (bloc) => bloc.add(const DeleteEmployee(testDepartmentId, 1)),
        expect: () => [
          const EmployeeDeleting(testEmployees, 1),
          EmployeeDeleteSuccess(
            testEmployees.where((e) => e.id != 1).toList(),
            'Employee deleted successfully',
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteEmployee(testDepartmentId, 1)).called(1);
        },
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeDeleting, EmployeeDeleteError] when deletion fails with network error',
        build: () {
          when(() => mockDeleteEmployee(testDepartmentId, 1)).thenAnswer(
            (_) async => Left(NetworkException('Connection failed')),
          );
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        seed: () => const EmployeeLoaded(testEmployees),
        act: (bloc) => bloc.add(const DeleteEmployee(testDepartmentId, 1)),
        expect: () => [
          const EmployeeDeleting(testEmployees, 1),
          const EmployeeDeleteError(testEmployees, 'No internet connection'),
        ],
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeDeleting, EmployeeDeleteError] when deletion fails with server error',
        build: () {
          when(
            () => mockDeleteEmployee(testDepartmentId, 1),
          ).thenAnswer((_) async => Left(ServerException(500, 'Server error')));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        seed: () => const EmployeeLoaded(testEmployees),
        act: (bloc) => bloc.add(const DeleteEmployee(testDepartmentId, 1)),
        expect: () => [
          const EmployeeDeleting(testEmployees, 1),
          const EmployeeDeleteError(
            testEmployees,
            'Server error, please try again later',
          ),
        ],
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'emits [EmployeeDeleting, EmployeeDeleteError] with 404 message when employee not found',
        build: () {
          when(
            () => mockDeleteEmployee(testDepartmentId, 1),
          ).thenAnswer((_) async => Left(ServerException(404, 'Not found')));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        seed: () => const EmployeeLoaded(testEmployees),
        act: (bloc) => bloc.add(const DeleteEmployee(testDepartmentId, 1)),
        expect: () => [
          const EmployeeDeleting(testEmployees, 1),
          const EmployeeDeleteError(testEmployees, 'Resource not found'),
        ],
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'preserves employee list when deletion fails',
        build: () {
          when(
            () => mockDeleteEmployee(testDepartmentId, 2),
          ).thenAnswer((_) async => Left(ServerException(500, 'Server error')));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        seed: () => const EmployeeLoaded(testEmployees),
        act: (bloc) => bloc.add(const DeleteEmployee(testDepartmentId, 2)),
        verify: (bloc) {
          final state = bloc.state as EmployeeDeleteError;
          expect(state.employees, testEmployees);
          expect(state.employees.length, 3);
          expect(state.employees.any((e) => e.id == 2), true);
        },
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'removes correct employee from list on successful deletion',
        build: () {
          when(
            () => mockDeleteEmployee(testDepartmentId, 2),
          ).thenAnswer((_) async => const Right(null));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        seed: () => const EmployeeLoaded(testEmployees),
        act: (bloc) => bloc.add(const DeleteEmployee(testDepartmentId, 2)),
        verify: (bloc) {
          final state = bloc.state as EmployeeDeleteSuccess;
          expect(state.employees.length, 2);
          expect(state.employees.any((e) => e.id == 2), false);
          expect(state.employees.any((e) => e.id == 1), true);
          expect(state.employees.any((e) => e.id == 3), true);
        },
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'can delete from EmployeeDeleteSuccess state',
        build: () {
          when(
            () => mockDeleteEmployee(testDepartmentId, 3),
          ).thenAnswer((_) async => const Right(null));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        seed: () => EmployeeDeleteSuccess(
          testEmployees.where((e) => e.id != 1).toList(),
          'Previous deletion',
        ),
        act: (bloc) => bloc.add(const DeleteEmployee(testDepartmentId, 3)),
        verify: (bloc) {
          final state = bloc.state as EmployeeDeleteSuccess;
          expect(state.employees.length, 1);
          expect(state.employees.first.id, 2);
        },
      );

      blocTest<EmployeeBloc, EmployeeState>(
        'can delete from EmployeeDeleteError state',
        build: () {
          when(
            () => mockDeleteEmployee(testDepartmentId, 1),
          ).thenAnswer((_) async => const Right(null));
          return EmployeeBloc(
            getEmployeesByDepartment: mockGetEmployeesByDepartment,
            deleteEmployee: mockDeleteEmployee,
          );
        },
        seed: () => const EmployeeDeleteError(testEmployees, 'Previous error'),
        act: (bloc) => bloc.add(const DeleteEmployee(testDepartmentId, 1)),
        verify: (bloc) {
          final state = bloc.state as EmployeeDeleteSuccess;
          expect(state.employees.length, 2);
          expect(state.employees.any((e) => e.id == 1), false);
        },
      );
    });

    group('EmployeeState', () {
      test('EmployeeLoaded.isEmpty returns true for empty list', () {
        const state = EmployeeLoaded(<Employee>[]);
        expect(state.isEmpty, true);
      });

      test('EmployeeLoaded.isEmpty returns false for non-empty list', () {
        const state = EmployeeLoaded(testEmployees);
        expect(state.isEmpty, false);
      });

      test('EmployeeDeleteSuccess.isEmpty returns true for empty list', () {
        const state = EmployeeDeleteSuccess(<Employee>[], 'Success');
        expect(state.isEmpty, true);
      });

      test(
        'EmployeeDeleteSuccess.isEmpty returns false for non-empty list',
        () {
          const state = EmployeeDeleteSuccess(testEmployees, 'Success');
          expect(state.isEmpty, false);
        },
      );

      test('EmployeeInitial props are empty', () {
        const state = EmployeeInitial();
        expect(state.props, []);
      });

      test('EmployeeLoading props are empty', () {
        const state = EmployeeLoading();
        expect(state.props, []);
      });

      test('EmployeeLoaded props contain employees', () {
        const state = EmployeeLoaded(testEmployees);
        expect(state.props, [testEmployees]);
      });

      test('EmployeeError props contain message', () {
        const state = EmployeeError('Test error');
        expect(state.props, ['Test error']);
      });

      test('EmployeeDeleting props contain employees and deletingId', () {
        const state = EmployeeDeleting(testEmployees, 1);
        expect(state.props, [testEmployees, 1]);
      });

      test('EmployeeDeleteSuccess props contain employees and message', () {
        const state = EmployeeDeleteSuccess(testEmployees, 'Success message');
        expect(state.props, [testEmployees, 'Success message']);
      });

      test('EmployeeDeleteError props contain employees and message', () {
        const state = EmployeeDeleteError(testEmployees, 'Error message');
        expect(state.props, [testEmployees, 'Error message']);
      });

      test('EmployeeLoaded equality works correctly', () {
        const state1 = EmployeeLoaded(testEmployees);
        const state2 = EmployeeLoaded(testEmployees);
        expect(state1, state2);
      });

      test('EmployeeError equality works correctly', () {
        const state1 = EmployeeError('Error message');
        const state2 = EmployeeError('Error message');
        expect(state1, state2);
      });

      test('EmployeeDeleting equality works correctly', () {
        const state1 = EmployeeDeleting(testEmployees, 1);
        const state2 = EmployeeDeleting(testEmployees, 1);
        expect(state1, state2);
      });

      test('EmployeeDeleteSuccess equality works correctly', () {
        const state1 = EmployeeDeleteSuccess(testEmployees, 'Success');
        const state2 = EmployeeDeleteSuccess(testEmployees, 'Success');
        expect(state1, state2);
      });

      test('EmployeeDeleteError equality works correctly', () {
        const state1 = EmployeeDeleteError(testEmployees, 'Error');
        const state2 = EmployeeDeleteError(testEmployees, 'Error');
        expect(state1, state2);
      });
    });

    group('EmployeeEvent', () {
      test('LoadEmployees props contain departmentId', () {
        const event = LoadEmployees(testDepartmentId);
        expect(event.props, [testDepartmentId]);
      });

      test('RefreshEmployees props contain departmentId', () {
        const event = RefreshEmployees(testDepartmentId);
        expect(event.props, [testDepartmentId]);
      });

      test('DeleteEmployee props contain departmentId and employeeId', () {
        const event = DeleteEmployee(testDepartmentId, 1);
        expect(event.props, [testDepartmentId, 1]);
      });

      test('LoadEmployees equality works correctly', () {
        const event1 = LoadEmployees(testDepartmentId);
        const event2 = LoadEmployees(testDepartmentId);
        expect(event1, event2);
      });

      test('RefreshEmployees equality works correctly', () {
        const event1 = RefreshEmployees(testDepartmentId);
        const event2 = RefreshEmployees(testDepartmentId);
        expect(event1, event2);
      });

      test('DeleteEmployee equality works correctly', () {
        const event1 = DeleteEmployee(testDepartmentId, 1);
        const event2 = DeleteEmployee(testDepartmentId, 1);
        expect(event1, event2);
      });

      test('LoadEmployees with different departmentId are not equal', () {
        const event1 = LoadEmployees(1);
        const event2 = LoadEmployees(2);
        expect(event1, isNot(event2));
      });

      test('DeleteEmployee with different employeeId are not equal', () {
        const event1 = DeleteEmployee(testDepartmentId, 1);
        const event2 = DeleteEmployee(testDepartmentId, 2);
        expect(event1, isNot(event2));
      });
    });
  });
}
