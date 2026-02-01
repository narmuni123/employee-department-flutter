import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/domain/entities/department.dart';
import 'package:employment_department/domain/entities/employee.dart';
import 'package:employment_department/domain/usecases/get_departments.dart';
import 'package:employment_department/presentation/bloc/department/department_bloc.dart';
import 'package:employment_department/presentation/screens/department_list_screen.dart';

class MockGetDepartments extends Mock implements GetDepartments {}

void main() {
  late MockGetDepartments mockGetDepartments;
  late DepartmentBloc departmentBloc;

  setUp(() {
    mockGetDepartments = MockGetDepartments();
  });

  tearDown(() {
    departmentBloc.close();
  });

  Widget createTestWidget() {
    departmentBloc = DepartmentBloc(getDepartments: mockGetDepartments);
    return MaterialApp(
      routes: {
        '/employees': (context) {
          final departmentId =
              ModalRoute.of(context)!.settings.arguments as int;
          return Scaffold(
            body: Center(
              child: Text('Employee List Screen - Dept $departmentId'),
            ),
          );
        },
      },
      home: BlocProvider<DepartmentBloc>.value(
        value: departmentBloc,
        child: const DepartmentListScreen(),
      ),
    );
  }

  final testDepartments = [
    const Department(
      id: 1,
      name: 'Engineering',
      location: 'Building A',
      employees: [
        Employee(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          position: 'Developer',
          salary: 75000,
        ),
        Employee(
          id: 2,
          name: 'Jane Smith',
          email: 'jane@example.com',
          position: 'Designer',
          salary: 70000,
        ),
      ],
    ),
    const Department(
      id: 2,
      name: 'Marketing',
      location: 'Building B',
      employees: [
        Employee(
          id: 3,
          name: 'Bob Wilson',
          email: 'bob@example.com',
          position: 'Manager',
          salary: 80000,
        ),
      ],
    ),
  ];

  group('DepartmentListScreen', () {
    testWidgets('displays loading indicator while fetching departments', (
      tester,
    ) async {
      // Setup: Use a Completer that never completes to keep loading state
      final completer = Completer<Either<AppException, List<Department>>>();
      when(() => mockGetDepartments()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Validates: Requirement 2.4
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading departments...'), findsOneWidget);
    });

    testWidgets(
      'displays departments with name, location, and employee count',
      (tester) async {
        when(
          () => mockGetDepartments(),
        ).thenAnswer((_) async => Right(testDepartments));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Validates: Requirement 2.2 - Display department name
        expect(find.text('Engineering'), findsOneWidget);
        expect(find.text('Marketing'), findsOneWidget);

        // Validates: Requirement 2.2 - Display department location
        expect(find.text('Building A'), findsOneWidget);
        expect(find.text('Building B'), findsOneWidget);

        // Validates: Requirement 2.2 - Display employee count
        expect(find.text('2'), findsOneWidget); // Engineering has 2 employees
        expect(find.text('1'), findsOneWidget); // Marketing has 1 employee
      },
    );

    testWidgets('navigates to employee list screen when tapping a department', (
      tester,
    ) async {
      when(
        () => mockGetDepartments(),
      ).thenAnswer((_) async => Right(testDepartments));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on the Engineering department
      await tester.tap(find.text('Engineering'));
      await tester.pumpAndSettle();

      // Validates: Requirement 2.3 - Navigate to Employee List Screen
      expect(find.text('Employee List Screen - Dept 1'), findsOneWidget);
    });

    testWidgets('displays empty state when no departments exist', (
      tester,
    ) async {
      when(() => mockGetDepartments()).thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Validates: Requirement 2.6
      expect(find.text('No departments found'), findsOneWidget);
      expect(find.byIcon(Icons.business_outlined), findsOneWidget);
    });

    testWidgets('displays error message with retry option on error', (
      tester,
    ) async {
      when(() => mockGetDepartments()).thenAnswer(
        (_) async => Left(NetworkException('No internet connection')),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Validates: Requirement 2.5 - Display error message
      expect(find.text('No internet connection'), findsOneWidget);

      // Validates: Requirement 2.5 - Retry option
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('retries loading departments when retry button is pressed', (
      tester,
    ) async {
      // First call returns error
      when(() => mockGetDepartments()).thenAnswer(
        (_) async => Left(NetworkException('No internet connection')),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No internet connection'), findsOneWidget);

      // Setup: Second call returns success
      when(
        () => mockGetDepartments(),
      ).thenAnswer((_) async => Right(testDepartments));

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Should now show departments
      expect(find.text('Engineering'), findsOneWidget);
      expect(find.text('Marketing'), findsOneWidget);
    });

    testWidgets('displays app bar with correct title', (tester) async {
      when(
        () => mockGetDepartments(),
      ).thenAnswer((_) async => Right(testDepartments));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Departments'), findsOneWidget);
    });

    testWidgets('displays department icons and navigation arrows', (
      tester,
    ) async {
      when(
        () => mockGetDepartments(),
      ).thenAnswer((_) async => Right(testDepartments));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Department icons
      expect(find.byIcon(Icons.business), findsNWidgets(2));

      // Location icons
      expect(find.byIcon(Icons.location_on_outlined), findsNWidgets(2));

      // Employee count icons
      expect(find.byIcon(Icons.people_outline), findsNWidgets(2));

      // Navigation arrows
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    });
  });
}
