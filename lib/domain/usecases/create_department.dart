import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';
import '../entities/department.dart';
import '../repositories/department_repository.dart';

class CreateDepartment {
  final DepartmentRepository repository;

  CreateDepartment(this.repository);

  Future<Either<AppException, Department>> call(Department department) {
    return repository.createDepartment(department);
  }
}
