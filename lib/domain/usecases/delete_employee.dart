import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';
import '../repositories/employee_repository.dart';

class DeleteEmployee {
  final EmployeeRepository repository;

  DeleteEmployee(this.repository);

  Future<Either<AppException, void>> call(int deptId, int empId) {
    return repository.deleteEmployee(deptId, empId);
  }
}
