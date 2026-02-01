class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8080/api';
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;

  static const String departments = '/departments';
  static const String employees = '/employees';

  static String employeesByDepartment(int deptId) =>
      '/departments/$deptId/employees';

  static String employeeById(int deptId, int empId) =>
      '/departments/$deptId/employees/$empId';

  static const String departmentEmployeesReport =
      '/reports/departments/employees';
}
