import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

abstract class ReportRemoteDataSource {
  Future<List<int>> downloadDepartmentEmployeesReport();
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<int>> downloadDepartmentEmployeesReport() async {
    final response = await apiClient.downloadFile(
      ApiConstants.departmentEmployeesReport,
    );

    return response.data!;
  }
}
