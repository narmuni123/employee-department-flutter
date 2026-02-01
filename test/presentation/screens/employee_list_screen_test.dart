import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/domain/entities/employee.dart';
import 'package:employment_department/domain/usecases/delete_employee.dart';
import 'package:employment_department/domain/usecases/get_employees_by_department.dart';
import 'package:employment_department/presentation/bloc/employee/employee_bloc.dart';
import 'package:employment_department/presentation/screens/employee_list_screen.dart';

class MockGetEmployeesByDepartment extends Mock
    implements GetEmployeesByDepartment {}

class MockDeleteEmployee extends Mock implements DeleteEmployee {}

void main() {
  late MockGetEmployeesByDepartment mockGetEmployeesByDepartment;
  late MockDeleteEmployee mockDeleteEmployee;
  late EmployeeBloc employeeBloc;

  const testDepartmentId = 1;

  setUp(() {
    mockGetEmployeesByDepartment = MockGetEmployeesByDepartment();
    mockDeleteEmployee = MockDeleteEmployee();
  });

  tearDown(() {
    employeeBloc.close();
  });

  Widget createTestWidgetWithArguments() {
    employeeBloc = EmployeeBloc(
      getEmployeesByDepartment: mockGetEmployeesByDepartment,
      deleteEmployee: mockDeleteEmployee,
    );
    return MaterialApp(
      routes: {
        '/add-employee': (context) {
          final departmentId =
              ModalRoute.of(context)!.settings.arguments as int;
          return Scaffold(
            body: Center(
              child: Text('Add Employee Screen - Dept $departmentId'),
            ),
          );
        },
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: RouteSettings(
            name: settings.name,
            arguments: testDepartmentId,
          ),
          builder: (context) => BlocProvider<EmployeeBloc>.value(
            value: employeeBloc,
            child: const EmployeeListScreen(),
          ),
        );
      },
      initialRoute: '/',
    );
  }

  final testEmployees = [
    const Employee(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      position: 'Developer',
      salary: 75000.00,
    ),
    const Employee(
      id: 2,
      name: 'Jane Smith',
      email: 'jane@example.com',
      position: 'Designer',
      salary: 70000.50,
    ),
  ];

  group('EmployeeListScreen', () {
    testWidgets('displays loading indicator while fetching employees', (
      tester,
    ) async {
      // Setup: Use a Completer that never completes to keep loading state
      final completer = Completer<Either<AppException, List<Employee>>>();
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pump();

      // Validates: Requirement 3.4
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading employees...'), findsOneWidget);
    });

    testWidgets('displays employees with name, position, email, and salary', (
      tester,
    ) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Validates: Requirement 3.2 - Display employee name
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);

      // Validates: Requirement 3.2 - Display employee position
      expect(find.text('Developer'), findsOneWidget);
      expect(find.text('Designer'), findsOneWidget);

      // Validates: Requirement 3.2 - Display employee email
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('jane@example.com'), findsOneWidget);

      // Validates: Requirement 3.2 - Display employee salary
      expect(find.text('\$75000.00'), findsOneWidget);
      expect(find.text('\$70000.50'), findsOneWidget);
    });

    testWidgets('displays empty state when no employees exist', (tester) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Validates: Requirement 3.6
      expect(find.text('No employees in this department'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.text('Add Employee'), findsOneWidget);
    });

    testWidgets('displays error message with retry option on error', (
      tester,
    ) async {
      when(() => mockGetEmployeesByDepartment(testDepartmentId)).thenAnswer(
        (_) async => Left(NetworkException('No internet connection')),
      );

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Validates: Requirement 3.5 - Display error message
      expect(find.text('No internet connection'), findsOneWidget);

      // Validates: Requirement 3.5 - Retry option
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('retries loading employees when retry button is pressed', (
      tester,
    ) async {
      // First call returns error
      when(() => mockGetEmployeesByDepartment(testDepartmentId)).thenAnswer(
        (_) async => Left(NetworkException('No internet connection')),
      );

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      expect(find.text('No internet connection'), findsOneWidget);

      // Setup: Second call returns success
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Should now show employees
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('displays app bar with correct title', (tester) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      expect(find.text('Employees'), findsOneWidget);
    });

    testWidgets('displays floating action button to add employee', (
      tester,
    ) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('navigates to add employee screen when FAB is tapped', (
      tester,
    ) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Tap the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should navigate to add employee screen
      expect(find.text('Add Employee Screen - Dept 1'), findsOneWidget);
    });

    testWidgets('displays delete button for each employee', (tester) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Should have delete icons for each employee
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
    });

    testWidgets('shows confirmation dialog when delete button is tapped', (
      tester,
    ) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Tap the first delete button
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Validates: Requirement 4.1 - Display confirmation dialog
      expect(find.text('Delete Employee'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete John Doe? This action cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('cancels deletion when cancel button is pressed', (
      tester,
    ) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Tap the first delete button
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed, employee should still be there
      expect(find.text('Delete Employee'), findsNothing);
      expect(find.text('John Doe'), findsOneWidget);

      // Delete should not have been called
      verifyNever(() => mockDeleteEmployee(any(), any()));
    });

    testWidgets('deletes employee when delete is confirmed', (tester) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));
      when(
        () => mockDeleteEmployee(testDepartmentId, 1),
      ).thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Tap the first delete button
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Tap delete to confirm
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Validates: Requirement 4.2 - Send DELETE request
      verify(() => mockDeleteEmployee(testDepartmentId, 1)).called(1);

      // Validates: Requirement 4.3 - Show success notification
      expect(find.text('Employee deleted successfully'), findsOneWidget);

      // Validates: Requirement 4.3 - Remove employee from list
      expect(find.text('John Doe'), findsNothing);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('shows loading indicator during deletion', (tester) async {
      final deleteCompleter = Completer<Either<AppException, void>>();

      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));
      when(
        () => mockDeleteEmployee(testDepartmentId, 1),
      ).thenAnswer((_) => deleteCompleter.future);

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Tap the first delete button
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Tap delete to confirm
      await tester.tap(find.text('Delete'));
      await tester.pump();

      // Validates: Requirement 4.5 - Display loading indicator during deletion
      // The delete button should be replaced with a loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the deletion
      deleteCompleter.complete(const Right(null));
      await tester.pumpAndSettle();
    });

    testWidgets('shows error message when deletion fails', (tester) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));
      when(() => mockDeleteEmployee(testDepartmentId, 1)).thenAnswer(
        (_) async =>
            Left(ServerException(500, 'Server error, please try again later')),
      );

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Tap the first delete button
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      // Tap delete to confirm
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Validates: Requirement 4.4 - Display error message
      expect(find.text('Server error, please try again later'), findsOneWidget);

      // Validates: Requirement 4.4 - Retain employee in list
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('displays employee avatar with first letter of name', (
      tester,
    ) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Should display first letter of each employee's name
      expect(
        find.text('J'),
        findsNWidgets(2),
      ); // John and Jane both start with J
    });

    testWidgets('displays employee icons for position, email, and salary', (
      tester,
    ) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Position icons
      expect(find.byIcon(Icons.work_outline), findsNWidgets(2));

      // Email icons
      expect(find.byIcon(Icons.email_outlined), findsNWidgets(2));

      // Salary icons
      expect(find.byIcon(Icons.attach_money), findsNWidgets(2));
    });

    testWidgets('supports pull-to-refresh', (tester) async {
      when(
        () => mockGetEmployeesByDepartment(testDepartmentId),
      ).thenAnswer((_) async => Right(testEmployees));

      await tester.pumpWidget(createTestWidgetWithArguments());
      await tester.pumpAndSettle();

      // Verify RefreshIndicator is present
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Perform pull-to-refresh gesture
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      // Validates: Requirement 3.3 - Pull-to-refresh should re-fetch
      verify(() => mockGetEmployeesByDepartment(testDepartmentId)).called(2);
    });
  });
}
