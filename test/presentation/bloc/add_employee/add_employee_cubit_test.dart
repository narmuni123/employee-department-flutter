import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/domain/entities/employee.dart';
import 'package:employment_department/domain/usecases/add_employee.dart';
import 'package:employment_department/presentation/bloc/add_employee/add_employee_cubit.dart';
import 'package:employment_department/presentation/bloc/add_employee/add_employee_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAddEmployee extends Mock implements AddEmployee {}

class FakeEmployee extends Fake implements Employee {}

void main() {
  late MockAddEmployee mockAddEmployee;
  late AddEmployeeCubit addEmployeeCubit;
  const testDepartmentId = 1;

  setUpAll(() {
    registerFallbackValue(FakeEmployee());
  });

  setUp(() {
    mockAddEmployee = MockAddEmployee();
    addEmployeeCubit = AddEmployeeCubit(
      addEmployee: mockAddEmployee,
      departmentId: testDepartmentId,
    );
  });

  tearDown(() {
    addEmployeeCubit.close();
  });

  group('AddEmployeeCubit', () {
    test('initial state is correct', () {
      expect(addEmployeeCubit.state, const AddEmployeeState());
      expect(addEmployeeCubit.state.id, '');
      expect(addEmployeeCubit.state.name, '');
      expect(addEmployeeCubit.state.email, '');
      expect(addEmployeeCubit.state.position, '');
      expect(addEmployeeCubit.state.salary, '');
      expect(addEmployeeCubit.state.errors, const {});
      expect(addEmployeeCubit.state.isSubmitting, false);
      expect(addEmployeeCubit.state.isSuccess, false);
      expect(addEmployeeCubit.state.successMessage, null);
      expect(addEmployeeCubit.state.apiError, null);
    });

    group('idChanged', () {
      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with id and no error for valid id',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.idChanged('123'),
        expect: () => [
          const AddEmployeeState(id: '123', errors: {'id': null}),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with id and error for non-numeric id',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.idChanged('abc'),
        expect: () => [
          const AddEmployeeState(
            id: 'abc',
            errors: {'id': 'Employee ID must be a non-empty numeric value'},
          ),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with id and error for empty id',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.idChanged(''),
        expect: () => [
          const AddEmployeeState(
            id: '',
            errors: {'id': 'Employee ID must be a non-empty numeric value'},
          ),
        ],
      );
    });

    group('nameChanged', () {
      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with name and no error for valid name',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.nameChanged('John Doe'),
        expect: () => [
          const AddEmployeeState(name: 'John Doe', errors: {'name': null}),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with name and error for name with numbers',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.nameChanged('John123'),
        expect: () => [
          const AddEmployeeState(
            name: 'John123',
            errors: {'name': 'Name must contain only letters and spaces'},
          ),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with name and error for empty name',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.nameChanged(''),
        expect: () => [
          const AddEmployeeState(
            name: '',
            errors: {'name': 'Name must contain only letters and spaces'},
          ),
        ],
      );
    });

    group('emailChanged', () {
      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with email and no error for valid email',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.emailChanged('john@example.com'),
        expect: () => [
          const AddEmployeeState(
            email: 'john@example.com',
            errors: {'email': null},
          ),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with email and error for invalid email',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.emailChanged('invalid-email'),
        expect: () => [
          const AddEmployeeState(
            email: 'invalid-email',
            errors: {'email': 'Please enter a valid email address'},
          ),
        ],
      );
    });

    group('positionChanged', () {
      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with position and no error for valid position',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.positionChanged('Software Engineer'),
        expect: () => [
          const AddEmployeeState(
            position: 'Software Engineer',
            errors: {'position': null},
          ),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with position and error for empty position',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.positionChanged(''),
        expect: () => [
          const AddEmployeeState(
            position: '',
            errors: {'position': 'Position cannot be empty'},
          ),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with position and error for whitespace-only position',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.positionChanged('   '),
        expect: () => [
          const AddEmployeeState(
            position: '   ',
            errors: {'position': 'Position cannot be empty'},
          ),
        ],
      );
    });

    group('salaryChanged', () {
      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with salary and no error for valid salary',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.salaryChanged('50000'),
        expect: () => [
          const AddEmployeeState(salary: '50000', errors: {'salary': null}),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with salary and no error for decimal salary',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.salaryChanged('50000.50'),
        expect: () => [
          const AddEmployeeState(salary: '50000.50', errors: {'salary': null}),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with salary and error for non-numeric salary',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.salaryChanged('abc'),
        expect: () => [
          const AddEmployeeState(
            salary: 'abc',
            errors: {'salary': 'Salary must be a positive number'},
          ),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with salary and error for zero salary',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.salaryChanged('0'),
        expect: () => [
          const AddEmployeeState(
            salary: '0',
            errors: {'salary': 'Salary must be a positive number'},
          ),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits state with salary and error for negative salary',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        act: (cubit) => cubit.salaryChanged('-100'),
        expect: () => [
          const AddEmployeeState(
            salary: '-100',
            errors: {'salary': 'Salary must be a positive number'},
          ),
        ],
      );
    });

    group('validateForm', () {
      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'validates all fields and sets errors',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        seed: () => const AddEmployeeState(
          id: 'abc',
          name: '123',
          email: 'invalid',
          position: '',
          salary: '-1',
        ),
        act: (cubit) => cubit.validateForm(),
        expect: () => [
          const AddEmployeeState(
            id: 'abc',
            name: '123',
            email: 'invalid',
            position: '',
            salary: '-1',
            errors: {
              'id': 'Employee ID must be a non-empty numeric value',
              'name': 'Name must contain only letters and spaces',
              'email': 'Please enter a valid email address',
              'position': 'Position cannot be empty',
              'salary': 'Salary must be a positive number',
            },
          ),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'clears errors for valid inputs',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        seed: () => const AddEmployeeState(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '50000',
          errors: {
            'id': 'Previous error',
            'name': 'Previous error',
            'email': 'Previous error',
            'position': 'Previous error',
            'salary': 'Previous error',
          },
        ),
        act: (cubit) => cubit.validateForm(),
        expect: () => [
          const AddEmployeeState(
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': null,
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
          ),
        ],
      );
    });

    group('submit', () {
      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'does not submit when form is invalid',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        seed: () => const AddEmployeeState(
          id: 'abc',
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '50000',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          const AddEmployeeState(
            id: 'abc',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': 'Employee ID must be a non-empty numeric value',
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
          ),
        ],
        verify: (_) {
          verifyNever(() => mockAddEmployee(any(), any()));
        },
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits loading then success on successful submission',
        build: () {
          when(() => mockAddEmployee(any(), any())).thenAnswer(
            (_) async => const Right(
              Employee(
                id: 123,
                name: 'John Doe',
                email: 'john@example.com',
                position: 'Engineer',
                salary: 50000,
              ),
            ),
          );
          return AddEmployeeCubit(
            addEmployee: mockAddEmployee,
            departmentId: testDepartmentId,
          );
        },
        seed: () => const AddEmployeeState(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '50000',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          // First: validation state
          const AddEmployeeState(
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': null,
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
          ),
          // Second: loading state
          const AddEmployeeState(
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': null,
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
            isSubmitting: true,
          ),
          // Third: success state
          const AddEmployeeState(
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': null,
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
            isSubmitting: false,
            isSuccess: true,
            successMessage: 'Employee added successfully',
          ),
        ],
        verify: (_) {
          verify(
            () => mockAddEmployee(
              testDepartmentId,
              const Employee(
                id: 123,
                name: 'John Doe',
                email: 'john@example.com',
                position: 'Engineer',
                salary: 50000,
              ),
            ),
          ).called(1);
        },
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits loading then error on failed submission',
        build: () {
          when(() => mockAddEmployee(any(), any())).thenAnswer(
            (_) async => Left(ServerException(400, 'Employee already exists')),
          );
          return AddEmployeeCubit(
            addEmployee: mockAddEmployee,
            departmentId: testDepartmentId,
          );
        },
        seed: () => const AddEmployeeState(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '50000',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          // First: validation state
          const AddEmployeeState(
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': null,
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
          ),
          // Second: loading state
          const AddEmployeeState(
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': null,
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
            isSubmitting: true,
          ),
          // Third: error state
          const AddEmployeeState(
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': null,
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
            isSubmitting: false,
            apiError: 'Employee already exists',
          ),
        ],
      );

      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'emits loading then error on network failure',
        build: () {
          when(() => mockAddEmployee(any(), any())).thenAnswer(
            (_) async => Left(NetworkException('No internet connection')),
          );
          return AddEmployeeCubit(
            addEmployee: mockAddEmployee,
            departmentId: testDepartmentId,
          );
        },
        seed: () => const AddEmployeeState(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '50000',
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          // First: validation state
          const AddEmployeeState(
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': null,
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
          ),
          // Second: loading state
          const AddEmployeeState(
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': null,
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
            isSubmitting: true,
          ),
          // Third: error state
          const AddEmployeeState(
            id: '123',
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Engineer',
            salary: '50000',
            errors: {
              'id': null,
              'name': null,
              'email': null,
              'position': null,
              'salary': null,
            },
            isSubmitting: false,
            apiError: 'No internet connection',
          ),
        ],
      );
    });

    group('reset', () {
      blocTest<AddEmployeeCubit, AddEmployeeState>(
        'resets state to initial values',
        build: () => AddEmployeeCubit(
          addEmployee: mockAddEmployee,
          departmentId: testDepartmentId,
        ),
        seed: () => const AddEmployeeState(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '50000',
          isSuccess: true,
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [const AddEmployeeState()],
      );
    });

    group('isValid', () {
      test('returns false when id is empty', () {
        const state = AddEmployeeState(
          id: '',
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '50000',
        );
        expect(state.isValid, false);
      });

      test('returns false when name is empty', () {
        const state = AddEmployeeState(
          id: '123',
          name: '',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '50000',
        );
        expect(state.isValid, false);
      });

      test('returns false when email is empty', () {
        const state = AddEmployeeState(
          id: '123',
          name: 'John Doe',
          email: '',
          position: 'Engineer',
          salary: '50000',
        );
        expect(state.isValid, false);
      });

      test('returns false when position is empty', () {
        const state = AddEmployeeState(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          position: '',
          salary: '50000',
        );
        expect(state.isValid, false);
      });

      test('returns false when salary is empty', () {
        const state = AddEmployeeState(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '',
        );
        expect(state.isValid, false);
      });

      test('returns false when there are validation errors', () {
        const state = AddEmployeeState(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '50000',
          errors: {'id': 'Invalid ID'},
        );
        expect(state.isValid, false);
      });

      test('returns true when all fields are valid and no errors', () {
        const state = AddEmployeeState(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Engineer',
          salary: '50000',
          errors: {
            'id': null,
            'name': null,
            'email': null,
            'position': null,
            'salary': null,
          },
        );
        expect(state.isValid, true);
      });
    });

    group('error getters', () {
      test('idError returns correct error', () {
        const state = AddEmployeeState(errors: {'id': 'ID error'});
        expect(state.idError, 'ID error');
      });

      test('nameError returns correct error', () {
        const state = AddEmployeeState(errors: {'name': 'Name error'});
        expect(state.nameError, 'Name error');
      });

      test('emailError returns correct error', () {
        const state = AddEmployeeState(errors: {'email': 'Email error'});
        expect(state.emailError, 'Email error');
      });

      test('positionError returns correct error', () {
        const state = AddEmployeeState(errors: {'position': 'Position error'});
        expect(state.positionError, 'Position error');
      });

      test('salaryError returns correct error', () {
        const state = AddEmployeeState(errors: {'salary': 'Salary error'});
        expect(state.salaryError, 'Salary error');
      });
    });
  });
}
