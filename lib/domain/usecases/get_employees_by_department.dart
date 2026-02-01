import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';
import '../entities/employee.dart';
import '../repositories/department_repository.dart';

class GetEmployeesByDepartment {
  final DepartmentRepository repository;

  GetEmployeesByDepartment(this.repository);

  Future<Either<AppException, List<Employee>>> call(int deptId) {
    return repository.getEmployeesByDepartment(deptId);
  }
}
