import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';
import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class AddEmployee {
  final EmployeeRepository repository;

  AddEmployee(this.repository);

  Future<Either<AppException, Employee>> call(int deptId, Employee employee) {
    return repository.addEmployee(deptId, employee);
  }
}
