import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';
import '../entities/department.dart';
import '../entities/employee.dart';

abstract class DepartmentRepository {
  Future<Either<AppException, List<Department>>> getDepartments();

  Future<Either<AppException, List<Employee>>> getEmployeesByDepartment(
    int deptId,
  );

  Future<Either<AppException, Department>> createDepartment(
    Department department,
  );
}
