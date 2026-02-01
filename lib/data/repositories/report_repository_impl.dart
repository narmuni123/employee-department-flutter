import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/error/app_exception.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<AppException, String>> downloadDepartmentReport() async {
    try {
      final pdfBytes = await remoteDataSource
          .downloadDepartmentEmployeesReport();

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/department_employees_report.pdf';

      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      return Right(filePath);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(NetworkException('Failed to save report: ${e.toString()}'));
    }
  }
}
