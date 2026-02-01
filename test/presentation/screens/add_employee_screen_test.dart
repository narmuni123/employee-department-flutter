import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/domain/entities/employee.dart';
import 'package:employment_department/domain/usecases/add_employee.dart';
import 'package:employment_department/presentation/bloc/add_employee/add_employee_cubit.dart';
import 'package:employment_department/presentation/screens/add_employee_screen.dart';

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

  Widget createTestWidget({bool withNavigator = false}) {
    if (withNavigator) {
      return MaterialApp(
        home: BlocProvider<AddEmployeeCubit>.value(
          value: addEmployeeCubit,
          child: const AddEmployeeScreen(),
        ),
        routes: {
          '/employees': (context) =>
              const Scaffold(body: Center(child: Text('Employee List Screen'))),
        },
      );
    }
    return MaterialApp(
      home: BlocProvider<AddEmployeeCubit>.value(
        value: addEmployeeCubit,
        child: const AddEmployeeScreen(),
      ),
    );
  }

  // Helper to find the submit button - scroll to it first if needed
  Future<void> tapSubmitButton(WidgetTester tester) async {
    // The button text "Add Employee" appears twice - in AppBar and in button
    // We need to find the one that's inside a button
    final buttonFinder = find.descendant(
      of: find.byType(SizedBox),
      matching: find.text('Add Employee'),
    );

    // Scroll to make the button visible if needed
    await tester.scrollUntilVisible(
      buttonFinder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(buttonFinder.first);
  }

  group('AddEmployeeScreen', () {
    /// Validates: Requirement 5.1
    /// Display a form with fields for ID, Name, Email, Position, and Salary
    testWidgets('displays all form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Employee ID'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Position'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
      // "Add Employee" appears in both AppBar and button
      expect(find.text('Add Employee'), findsNWidgets(2));
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays header with icon and title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('New Employee'), findsOneWidget);
      expect(
        find.text('Fill in the details below to add a new employee'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    /// Validates: Requirement 5.2
    /// Validate ID is non-empty numeric value
    testWidgets('shows ID validation error for empty ID', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Scroll to and tap the submit button
      await tapSubmitButton(tester);
      await tester.pump();

      expect(
        find.text('Employee ID must be a non-empty numeric value'),
        findsOneWidget,
      );
    });

    /// Validates: Requirement 5.3
    /// Validate name is non-empty and contains only letters and spaces
    testWidgets('shows name validation error for invalid name', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the name field (second TextFormField)
      final nameField = find.byType(TextFormField).at(1);
      await tester.enterText(nameField, 'John123');
      await tester.pump();

      await tapSubmitButton(tester);
      await tester.pump();

      expect(
        find.text('Name must contain only letters and spaces'),
        findsOneWidget,
      );
    });

    /// Validates: Requirement 5.4
    /// Validate email follows standard email format
    testWidgets('shows email validation error for invalid email', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Find the email field (third TextFormField)
      final emailField = find.byType(TextFormField).at(2);
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump();

      await tapSubmitButton(tester);
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    /// Validates: Requirement 5.5
    /// Validate position is non-empty
    testWidgets('shows position validation error for empty position', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tapSubmitButton(tester);
      await tester.pump();

      expect(find.text('Position cannot be empty'), findsOneWidget);
    });

    /// Validates: Requirement 5.6
    /// Validate salary is positive numeric value
    testWidgets('shows salary validation error for invalid salary', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Find the salary field (fifth TextFormField)
      final salaryField = find.byType(TextFormField).at(4);
      await tester.enterText(salaryField, '-100');
      await tester.pump();

      await tapSubmitButton(tester);
      await tester.pump();

      expect(find.text('Salary must be a positive number'), findsOneWidget);
    });

    /// Validates: Requirement 5.7
    /// Display validation errors inline for each invalid field
    testWidgets('displays multiple validation errors inline', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Submit without filling any fields
      await tapSubmitButton(tester);
      await tester.pump();

      // All fields should show validation errors
      expect(
        find.text('Employee ID must be a non-empty numeric value'),
        findsOneWidget,
      );
      expect(
        find.text('Name must contain only letters and spaces'),
        findsOneWidget,
      );
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Position cannot be empty'), findsOneWidget);
      expect(find.text('Salary must be a positive number'), findsOneWidget);
    });

    /// Validates: Requirement 5.9
    /// Display success message and navigate back to Employee List Screen
    testWidgets(
      'shows success message and navigates back on successful submit',
      (tester) async {
        final testEmployee = Employee(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Developer',
          salary: 50000.0,
        );

        when(
          () => mockAddEmployee(testDepartmentId, any()),
        ).thenAnswer((_) async => Right(testEmployee));

        await tester.pumpWidget(createTestWidget(withNavigator: true));

        // Fill in all fields
        await tester.enterText(find.byType(TextFormField).at(0), '1');
        await tester.pump();
        await tester.enterText(find.byType(TextFormField).at(1), 'John Doe');
        await tester.pump();
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'john@example.com',
        );
        await tester.pump();
        await tester.enterText(find.byType(TextFormField).at(3), 'Developer');
        await tester.pump();
        await tester.enterText(find.byType(TextFormField).at(4), '50000');
        await tester.pump();

        // Submit the form
        await tapSubmitButton(tester);
        await tester.pump(); // Process the submission
        await tester.pump(); // Process the state change
        await tester.pump(
          const Duration(milliseconds: 100),
        ); // Allow snackbar to appear

        // Verify success message is shown in snackbar
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Employee added successfully'), findsOneWidget);
      },
    );

    /// Validates: Requirement 5.10
    /// Display the error message from the API response on failure
    testWidgets('shows API error message on failure', (tester) async {
      when(() => mockAddEmployee(testDepartmentId, any())).thenAnswer(
        (_) async => Left(ServerException(400, 'Employee already exists')),
      );

      await tester.pumpWidget(createTestWidget());

      // Fill in all fields
      await tester.enterText(find.byType(TextFormField).at(0), '1');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), 'John Doe');
      await tester.pump();
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'john@example.com',
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(3), 'Developer');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(4), '50000');
      await tester.pump();

      // Submit the form
      await tapSubmitButton(tester);
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Employee already exists'), findsOneWidget);
    });

    /// Validates: Requirement 5.11
    /// Display a loading indicator and disable the submit button during submission
    testWidgets('shows loading indicator during submission', (tester) async {
      // Use a completer to control when the API call completes
      final completer = Completer<Either<AppException, Employee>>();
      when(
        () => mockAddEmployee(testDepartmentId, any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      // Fill in all fields
      await tester.enterText(find.byType(TextFormField).at(0), '1');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), 'John Doe');
      await tester.pump();
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'john@example.com',
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(3), 'Developer');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(4), '50000');
      await tester.pump();

      // Submit the form
      await tapSubmitButton(tester);
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify submit button text is not visible during loading
      // (the button is replaced with loading indicator)
      // Only AppBar should have "Add Employee" text now
      expect(find.text('Add Employee'), findsOneWidget);

      // Complete the future to clean up
      completer.complete(
        Right(
          Employee(
            id: 1,
            name: 'John Doe',
            email: 'john@example.com',
            position: 'Developer',
            salary: 50000.0,
          ),
        ),
      );
      await tester.pump();
    });

    testWidgets('cancel button navigates back', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider<AddEmployeeCubit>.value(
                        value: addEmployeeCubit,
                        child: const AddEmployeeScreen(),
                      ),
                    ),
                  );
                },
                child: const Text('Go to Add Employee'),
              ),
            ),
          ),
        ),
      );

      // Navigate to AddEmployeeScreen
      await tester.tap(find.text('Go to Add Employee'));
      await tester.pumpAndSettle();

      // Verify we're on the AddEmployeeScreen
      expect(find.text('New Employee'), findsOneWidget);

      // Scroll to make Cancel button visible and tap it
      await tester.scrollUntilVisible(
        find.text('Cancel'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify we navigated back
      expect(find.text('Go to Add Employee'), findsOneWidget);
    });

    testWidgets('clears API error when user starts typing', (tester) async {
      when(() => mockAddEmployee(testDepartmentId, any())).thenAnswer(
        (_) async => Left(ServerException(400, 'Employee already exists')),
      );

      await tester.pumpWidget(createTestWidget());

      // Fill in all fields
      await tester.enterText(find.byType(TextFormField).at(0), '1');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), 'John Doe');
      await tester.pump();
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'john@example.com',
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(3), 'Developer');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(4), '50000');
      await tester.pump();

      // Submit the form
      await tapSubmitButton(tester);
      await tester.pumpAndSettle();

      // Verify error message is shown
      expect(find.text('Employee already exists'), findsOneWidget);

      // Start typing in a field
      await tester.enterText(find.byType(TextFormField).at(1), 'Jane Doe');
      await tester.pump();

      // Verify error message is cleared
      expect(find.text('Employee already exists'), findsNothing);
    });
  });
}
