class Validators {
  Validators._();

  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }

    final atCount = '@'.allMatches(email).length;
    if (atCount != 1) {
      return false;
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return false;
    }

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.isEmpty) {
      return false;
    }

    if (domain.isEmpty || !domain.contains('.')) {
      return false;
    }

    if (domain.startsWith('.') || domain.endsWith('.')) {
      return false;
    }

    final lastDotIndex = domain.lastIndexOf('.');
    if (lastDotIndex == domain.length - 1) {
      return false;
    }

    return true;
  }

  static String? validateEmail(String? email) {
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static bool isValidPassword(String? password) {
    if (password == null) {
      return false;
    }
    return password.length >= 6;
  }

  static String? validatePassword(String? password) {
    if (!isValidPassword(password)) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static bool isValidEmployeeId(String? id) {
    if (id == null || id.isEmpty) {
      return false;
    }

    return RegExp(r'^[0-9]+$').hasMatch(id);
  }

  static String? validateEmployeeId(String? id) {
    if (!isValidEmployeeId(id)) {
      return 'Employee ID must be a non-empty numeric value';
    }
    return null;
  }

  static bool isValidEmployeeName(String? name) {
    if (name == null || name.isEmpty) {
      return false;
    }

    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  static String? validateEmployeeName(String? name) {
    if (!isValidEmployeeName(name)) {
      return 'Name must contain only letters and spaces';
    }
    return null;
  }

  static bool isValidPosition(String? position) {
    if (position == null) {
      return false;
    }

    return position.trim().isNotEmpty;
  }

  static String? validatePosition(String? position) {
    if (!isValidPosition(position)) {
      return 'Position cannot be empty';
    }
    return null;
  }

  static bool isValidSalary(String? salary) {
    if (salary == null || salary.isEmpty) {
      return false;
    }

    final parsedValue = double.tryParse(salary);
    if (parsedValue == null) {
      return false;
    }

    return parsedValue > 0;
  }

  static String? validateSalary(String? salary) {
    if (!isValidSalary(salary)) {
      return 'Salary must be a positive number';
    }
    return null;
  }
}
