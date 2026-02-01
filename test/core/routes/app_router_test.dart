import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employment_department/core/routes/app_router.dart';
import 'package:employment_department/core/di/injection_container.dart';
import 'package:employment_department/core/services/notification_service.dart';
import 'package:employment_department/core/services/auth_service.dart';
import 'package:employment_department/core/services/image_picker_service.dart';
import 'package:employment_department/core/network/api_client.dart';
import 'package:employment_department/domain/repositories/department_repository.dart';
import 'package:employment_department/domain/repositories/employee_repository.dart';
import 'package:employment_department/domain/repositories/report_repository.dart';
import 'package:employment_department/domain/usecases/get_departments.dart';
import 'package:employment_department/domain/usecases/get_employees_by_department.dart';
import 'package:employment_department/domain/usecases/add_employee.dart';
import 'package:employment_department/domain/usecases/delete_employee.dart';
import 'package:employment_department/domain/usecases/download_report.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockImagePickerService extends Mock implements ImagePickerService {}

class MockApiClient extends Mock implements ApiClient {}

class MockDepartmentRepository extends Mock implements DepartmentRepository {}

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

class MockReportRepository extends Mock implements ReportRepository {}

class MockGetDepartments extends Mock implements GetDepartments {}

class MockGetEmployeesByDepartment extends Mock
    implements GetEmployeesByDepartment {}

class MockAddEmployee extends Mock implements AddEmployee {}

class MockDeleteEmployee extends Mock implements DeleteEmployee {}

class MockDownloadReport extends Mock implements DownloadReport {}

void main() {
  group('AppRoutes', () {
    test('login route should be root path', () {
      expect(AppRoutes.login, '/');
    });

    test('departments route should be /departments', () {
      expect(AppRoutes.departments, '/departments');
    });

    test('employees route should be /employees', () {
      expect(AppRoutes.employees, '/employees');
    });

    test('addEmployee route should be /add-employee', () {
      expect(AppRoutes.addEmployee, '/add-employee');
    });

    test('reports route should be /reports', () {
      expect(AppRoutes.reports, '/reports');
    });

    test('imagePicker route should be /image-picker', () {
      expect(AppRoutes.imagePicker, '/image-picker');
    });
  });

  group('AppRouter.onGenerateRoute', () {
    late MockAuthService mockAuthService;
    late MockNotificationService mockNotificationService;
    late MockImagePickerService mockImagePickerService;
    late MockGetDepartments mockGetDepartments;
    late MockGetEmployeesByDepartment mockGetEmployeesByDepartment;
    late MockAddEmployee mockAddEmployee;
    late MockDeleteEmployee mockDeleteEmployee;
    late MockDownloadReport mockDownloadReport;

    setUp(() async {
      // Reset and setup dependencies
      await sl.reset();

      mockAuthService = MockAuthService();
      mockNotificationService = MockNotificationService();
      mockImagePickerService = MockImagePickerService();
      mockGetDepartments = MockGetDepartments();
      mockGetEmployeesByDepartment = MockGetEmployeesByDepartment();
      mockAddEmployee = MockAddEmployee();
      mockDeleteEmployee = MockDeleteEmployee();
      mockDownloadReport = MockDownloadReport();

      // Setup notification service mock
      when(
        () => mockNotificationService.onNotificationTapped,
      ).thenAnswer((_) => const Stream.empty());

      // Register mocks
      sl.registerLazySingleton<AuthService>(() => mockAuthService);
      sl.registerLazySingleton<NotificationService>(
        () => mockNotificationService,
      );
      sl.registerLazySingleton<ImagePickerService>(
        () => mockImagePickerService,
      );
      sl.registerLazySingleton<GetDepartments>(() => mockGetDepartments);
      sl.registerLazySingleton<GetEmployeesByDepartment>(
        () => mockGetEmployeesByDepartment,
      );
      sl.registerLazySingleton<AddEmployee>(() => mockAddEmployee);
      sl.registerLazySingleton<DeleteEmployee>(() => mockDeleteEmployee);
      sl.registerLazySingleton<DownloadReport>(() => mockDownloadReport);
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('generates login route for root path', (tester) async {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.login),
      );

      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generates departments route', (tester) async {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.departments),
      );

      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generates employees route with departmentId argument', (
      tester,
    ) async {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.employees, arguments: 1),
      );

      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generates error route for employees without departmentId', (
      tester,
    ) async {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.employees),
      );

      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());

      // Build the route to verify it shows error
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return (route as MaterialPageRoute).builder(context);
            },
          ),
        ),
      );

      expect(
        find.text('Department ID is required for Employee List'),
        findsOneWidget,
      );
    });

    testWidgets('generates addEmployee route with departmentId argument', (
      tester,
    ) async {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.addEmployee, arguments: 1),
      );

      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generates error route for addEmployee without departmentId', (
      tester,
    ) async {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.addEmployee),
      );

      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());

      // Build the route to verify it shows error
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return (route as MaterialPageRoute).builder(context);
            },
          ),
        ),
      );

      expect(
        find.text('Department ID is required for Add Employee'),
        findsOneWidget,
      );
    });

    testWidgets('generates reports route', (tester) async {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.reports),
      );

      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generates imagePicker route', (tester) async {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.imagePicker),
      );

      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('generates error route for unknown route', (tester) async {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: '/unknown'),
      );

      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());

      // Build the route to verify it shows error
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return (route as MaterialPageRoute).builder(context);
            },
          ),
        ),
      );

      expect(find.text('Route not found: /unknown'), findsOneWidget);
    });
  });

  group('AppRouter notification handling', () {
    late MockNotificationService mockNotificationService;
    late StreamController<NotificationPayload> notificationController;
    late AppRouter appRouter;

    setUp(() async {
      await sl.reset();

      notificationController =
          StreamController<NotificationPayload>.broadcast();
      mockNotificationService = MockNotificationService();

      when(
        () => mockNotificationService.onNotificationTapped,
      ).thenAnswer((_) => notificationController.stream);

      sl.registerLazySingleton<NotificationService>(
        () => mockNotificationService,
      );

      appRouter = AppRouter();
    });

    tearDown(() async {
      appRouter.dispose();
      await notificationController.close();
      await sl.reset();
    });

    test('initializes notification subscription', () {
      appRouter.initialize();

      verify(() => mockNotificationService.onNotificationTapped).called(1);
    });

    test('disposes notification subscription', () {
      appRouter.initialize();
      appRouter.dispose();

      // Verify no errors when disposing
      expect(() => appRouter.dispose(), returnsNormally);
    });
  });

  group('AppRouter navigation helpers', () {
    testWidgets('navigateToDepartments pushes replacement route', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.login,
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.login) {
              return MaterialPageRoute(
                builder: (_) => Builder(
                  builder: (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () => AppRouter.navigateToDepartments(context),
                      child: const Text('Navigate'),
                    ),
                  ),
                ),
              );
            }
            if (settings.name == AppRoutes.departments) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Departments')),
              );
            }
            return null;
          },
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Departments'), findsOneWidget);
    });

    testWidgets('navigateToEmployees pushes route with departmentId', (
      tester,
    ) async {
      int? receivedDepartmentId;

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.departments,
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.departments) {
              return MaterialPageRoute(
                builder: (_) => Builder(
                  builder: (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () =>
                          AppRouter.navigateToEmployees(context, 42),
                      child: const Text('Navigate'),
                    ),
                  ),
                ),
              );
            }
            if (settings.name == AppRoutes.employees) {
              receivedDepartmentId = settings.arguments as int?;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Employees')),
              );
            }
            return null;
          },
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Employees'), findsOneWidget);
      expect(receivedDepartmentId, 42);
    });

    testWidgets('goBack pops the current route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.departments,
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.departments) {
              return MaterialPageRoute(
                builder: (_) => Builder(
                  builder: (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Builder(
                            builder: (innerContext) => Scaffold(
                              body: ElevatedButton(
                                onPressed: () => AppRouter.goBack(innerContext),
                                child: const Text('Go Back'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: const Text('Push'),
                    ),
                  ),
                ),
              );
            }
            return null;
          },
        ),
      );

      // Push a new route
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      expect(find.text('Go Back'), findsOneWidget);

      // Go back
      await tester.tap(find.text('Go Back'));
      await tester.pumpAndSettle();

      expect(find.text('Push'), findsOneWidget);
    });
  });
}
