import 'package:dartz/dartz.dart';

import '../../core/error/app_exception.dart';
import '../repositories/report_repository.dart';

class DownloadReport {
  final ReportRepository repository;

  DownloadReport(this.repository);

  Future<Either<AppException, String>> call() {
    return repository.downloadDepartmentReport();
  }
}
