import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/department_model.dart';
import '../models/employee_model.dart';

abstract class DepartmentRemoteDataSource {
  Future<List<DepartmentModel>> getDepartments();
  Future<List<EmployeeModel>> getEmployeesByDepartment(int deptId);
}

class DepartmentRemoteDataSourceImpl implements DepartmentRemoteDataSource {
  final ApiClient apiClient;

  DepartmentRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<DepartmentModel>> getDepartments() async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.departments,
    );

    return response.data!
        .map((json) => DepartmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EmployeeModel>> getEmployeesByDepartment(int deptId) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.employeesByDepartment(deptId),
    );

    return response.data!
        .map((json) => EmployeeModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
