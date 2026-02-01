import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';

abstract class ReportRepository {
  Future<Either<AppException, String>> downloadDepartmentReport();
}
