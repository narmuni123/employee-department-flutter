import 'package:dartz/dartz.dart';

import '../error/app_exception.dart';

abstract class AuthService {
  Future<Either<AppException, bool>> login(String email, String password);
  Future<void> logout();
  bool get isAuthenticated;
}

class MockAuthService implements AuthService {
  bool _isAuthenticated = false;

  @override
  Future<Either<AppException, bool>> login(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = true;
    return const Right(true);
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
  }

  @override
  bool get isAuthenticated => _isAuthenticated;
}
