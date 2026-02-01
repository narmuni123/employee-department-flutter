import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';
import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<Either<AppException, Employee>> addEmployee(
    int deptId,
    Employee employee,
  );

  Future<Either<AppException, void>> deleteEmployee(int deptId, int empId);
}
