import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_employee.dart';
import '../../presentation/bloc/add_employee/add_employee_cubit.dart';
import '../../presentation/bloc/auth/auth_cubit.dart';
import '../../presentation/bloc/department/department_bloc.dart';
import '../../presentation/bloc/employee/employee_bloc.dart';
import '../../presentation/bloc/image_picker/image_picker_cubit.dart';
import '../../presentation/bloc/report/report_cubit.dart';
import '../../presentation/screens/add_employee_screen.dart';
import '../../presentation/screens/department_list_screen.dart';
import '../../presentation/screens/employee_list_screen.dart';
import '../../presentation/screens/image_picker_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/reports_screen.dart';
import '../di/injection_container.dart';
import '../services/notification_service.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String departments = '/departments';
  static const String employees = '/employees';
  static const String addEmployee = '/add-employee';
  static const String reports = '/reports';
  static const String imagePicker = '/image-picker';
}

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  StreamSubscription<NotificationPayload>? _notificationSubscription;

  void initialize() {
    _setupNotificationNavigation();
  }

  void _setupNotificationNavigation() {
    final notificationService = sl<NotificationService>();
    _notificationSubscription = notificationService.onNotificationTapped.listen(
      _handleNotificationTap,
    );
  }

  void _handleNotificationTap(NotificationPayload payload) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final screen = payload.screen;
    if (screen == null) return;

    switch (screen) {
      case AppRoutes.departments:
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.departments,
          (route) => false,
        );
        break;

      case AppRoutes.employees:
        final departmentId = payload.data?['departmentId'] as int?;
        if (departmentId != null) {
          navigator.pushNamed(AppRoutes.employees, arguments: departmentId);
        }
        break;

      case AppRoutes.reports:
        navigator.pushNamed(AppRoutes.reports);
        break;

      case AppRoutes.addEmployee:
        final departmentId = payload.data?['departmentId'] as int?;
        if (departmentId != null) {
          navigator.pushNamed(AppRoutes.addEmployee, arguments: departmentId);
        }
        break;

      case AppRoutes.imagePicker:
        navigator.pushNamed(AppRoutes.imagePicker);
        break;

      default:
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.departments,
          (route) => false,
        );
    }
  }

  void dispose() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const LoginScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.departments:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<DepartmentBloc>(),
            child: const DepartmentListScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.employees:
        final departmentId = settings.arguments as int?;
        if (departmentId == null) {
          return _errorRoute('Department ID is required for Employee List');
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<EmployeeBloc>(),
            child: const EmployeeListScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.addEmployee:
        final departmentId = settings.arguments as int?;
        if (departmentId == null) {
          return _errorRoute('Department ID is required for Add Employee');
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => AddEmployeeCubit(
              addEmployee: sl<AddEmployee>(),
              departmentId: departmentId,
            ),
            child: const AddEmployeeScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.reports:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ReportCubit>(),
            child: const ReportsScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.imagePicker:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ImagePickerCubit>(),
            child: const ImagePickerScreen(),
          ),
          settings: settings,
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final navigator = navigatorKey.currentState;
                    if (navigator != null && navigator.canPop()) {
                      navigator.pop();
                    }
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void navigateToDepartments(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.departments);
  }

  static void navigateToEmployees(BuildContext context, int departmentId) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.employees, arguments: departmentId);
  }

  static void navigateToAddEmployee(BuildContext context, int departmentId) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.addEmployee, arguments: departmentId);
  }

  static void navigateToReports(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.reports);
  }

  static void navigateToImagePicker(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.imagePicker);
  }

  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.of(context).pop(result);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}
