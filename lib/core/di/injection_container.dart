import 'package:get_it/get_it.dart';

import '../../data/datasources/department_remote_datasource.dart';
import '../../data/datasources/employee_remote_datasource.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/department_repository_impl.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/department_repository.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/add_employee.dart';
import '../../domain/usecases/delete_employee.dart';
import '../../domain/usecases/download_report.dart';
import '../../domain/usecases/get_departments.dart';
import '../../domain/usecases/get_employees_by_department.dart';
import '../../presentation/bloc/auth/auth_cubit.dart';
import '../../presentation/bloc/department/department_bloc.dart';
import '../../presentation/bloc/employee/employee_bloc.dart';
import '../../presentation/bloc/image_picker/image_picker_cubit.dart';
import '../../presentation/bloc/report/report_cubit.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';
import '../services/auth_service.dart';
import '../services/image_picker_service.dart';
import '../services/notification_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  _registerCoreServices();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
}

void _registerCoreServices() {
  sl.registerLazySingleton<ApiClient>(
    () => DioApiClient(baseUrl: ApiConstants.baseUrl),
  );
  sl.registerLazySingleton<AuthService>(() => MockAuthService());
  sl.registerLazySingleton<NotificationService>(
    () => MockNotificationService(),
  );
  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerServiceImpl());
}

void _registerDataSources() {
  sl.registerLazySingleton<DepartmentRemoteDataSource>(
    () => DepartmentRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<EmployeeRemoteDataSource>(
    () => EmployeeRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(sl<ApiClient>()),
  );
}

void _registerRepositories() {
  sl.registerLazySingleton<DepartmentRepository>(
    () => DepartmentRepositoryImpl(sl<DepartmentRemoteDataSource>()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(sl<EmployeeRemoteDataSource>()),
  );
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(sl<ReportRemoteDataSource>()),
  );
}

void _registerUseCases() {
  sl.registerLazySingleton<GetDepartments>(
    () => GetDepartments(sl<DepartmentRepository>()),
  );
  sl.registerLazySingleton<GetEmployeesByDepartment>(
    () => GetEmployeesByDepartment(sl<DepartmentRepository>()),
  );
  sl.registerLazySingleton<AddEmployee>(
    () => AddEmployee(sl<EmployeeRepository>()),
  );
  sl.registerLazySingleton<DeleteEmployee>(
    () => DeleteEmployee(sl<EmployeeRepository>()),
  );
  sl.registerLazySingleton<DownloadReport>(
    () => DownloadReport(sl<ReportRepository>()),
  );
}

void _registerBlocs() {
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(authService: sl<AuthService>()),
  );
  sl.registerFactory<DepartmentBloc>(
    () => DepartmentBloc(getDepartments: sl<GetDepartments>()),
  );
  sl.registerFactory<EmployeeBloc>(
    () => EmployeeBloc(
      getEmployeesByDepartment: sl<GetEmployeesByDepartment>(),
      deleteEmployee: sl<DeleteEmployee>(),
    ),
  );
  sl.registerFactory<ReportCubit>(
    () => ReportCubit(downloadReport: sl<DownloadReport>()),
  );
  sl.registerFactory<ImagePickerCubit>(
    () => ImagePickerCubit(imagePickerService: sl<ImagePickerService>()),
  );
}

Future<void> resetDependencies() async {
  await sl.reset();
}
