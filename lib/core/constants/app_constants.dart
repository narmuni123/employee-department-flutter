class AppConstants {
  AppConstants._();

  static const String appName = 'Employee Department App';
  static const String appVersion = '1.0.0';

  static const int minPasswordLength = 6;
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String namePattern = r'^[a-zA-Z\s]+$';
  static const String numericPattern = r'^[0-9]+$';

  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const int defaultAnimationDuration = 300;

  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  static const String employeeAddedMessage = 'Employee added successfully';
  static const String reportGeneratedMessage = 'Report generated';

  static const String noInternetMessage = 'No internet connection';
  static const String resourceNotFoundMessage = 'Resource not found';
  static const String serverErrorMessage =
      'Server error, please try again later';
  static const String timeoutMessage = 'Request timed out';

  static const String noDepartmentsMessage = 'No departments found';
  static const String noEmployeesMessage = 'No employees in this department';
}
