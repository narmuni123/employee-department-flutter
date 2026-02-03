import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';
import '../../domain/entities/department.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/department_repository.dart';
import '../datasources/department_remote_datasource.dart';
import '../models/department_model.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentRemoteDataSource remoteDataSource;

  DepartmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<AppException, List<Department>>> getDepartments() async {
    try {
      final departmentModels = await remoteDataSource.getDepartments();
      final departments = departmentModels
          .map((model) => model.toEntity())
          .toList();
      return Right(departments);
    } on AppException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<AppException, List<Employee>>> getEmployeesByDepartment(
    int deptId,
  ) async {
    try {
      final employeeModels = await remoteDataSource.getEmployeesByDepartment(
        deptId,
      );
      final employees = employeeModels
          .map((model) => model.toEntity())
          .toList();
      return Right(employees);
    } on AppException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<AppException, Department>> createDepartment(
    Department department,
  ) async {
    try {
      final departmentModel = await remoteDataSource.createDepartment(
        _departmentToModel(department),
      );
      return Right(departmentModel.toEntity());
    } on AppException catch (e) {
      return Left(e);
    }
  }

  // Helper method to convert entity to model
  _departmentToModel(Department department) {
    return DepartmentModel(
      id: department.id,
      name: department.name,
      location: department.location,
      employees: [],
    );
  }
}
