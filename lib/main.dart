import 'package:flutter/material.dart';

import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  final notificationService = sl<NotificationService>();
  await notificationService.initialize();
  runApp(const EmployeeDepartmentApp());
}

class EmployeeDepartmentApp extends StatefulWidget {
  const EmployeeDepartmentApp({super.key});

  @override
  State<EmployeeDepartmentApp> createState() => _EmployeeDepartmentAppState();
}

class _EmployeeDepartmentAppState extends State<EmployeeDepartmentApp> {
  final AppRouter _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
    _appRouter.initialize();
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Department',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      navigatorKey: AppRouter.navigatorKey,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.login,
      debugShowCheckedModeBanner: false,
    );
  }
}
