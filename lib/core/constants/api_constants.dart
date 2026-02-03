class ApiConstants {
  ApiConstants._();

  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  // Use localhost for iOS simulator or web
  static const String baseUrl = 'http://10.0.2.2:8080/api';
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
