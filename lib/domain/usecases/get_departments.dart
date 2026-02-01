import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';
import '../entities/department.dart';
import '../repositories/department_repository.dart';

class GetDepartments {
  final DepartmentRepository repository;

  GetDepartments(this.repository);

  Future<Either<AppException, List<Department>>> call() {
    return repository.getDepartments();
  }
}
