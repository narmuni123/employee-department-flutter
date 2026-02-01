import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<EmployeeModel> addEmployee(int deptId, EmployeeModel employee);
  Future<void> deleteEmployee(int deptId, int empId);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final ApiClient apiClient;

  EmployeeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<EmployeeModel> addEmployee(int deptId, EmployeeModel employee) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.employeesByDepartment(deptId),
      data: employee.toJson(),
    );

    return EmployeeModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteEmployee(int deptId, int empId) async {
    await apiClient.delete<void>(ApiConstants.employeeById(deptId, empId));
  }
}
