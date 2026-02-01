import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_datasource.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<AppException, Employee>> addEmployee(
    int deptId,
    Employee employee,
  ) async {
    try {
      final employeeModel = EmployeeModel.fromEntity(employee);
      final createdModel = await remoteDataSource.addEmployee(
        deptId,
        employeeModel,
      );
      return Right(createdModel.toEntity());
    } on AppException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<AppException, void>> deleteEmployee(
    int deptId,
    int empId,
  ) async {
    try {
      await remoteDataSource.deleteEmployee(deptId, empId);
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    }
  }
}
