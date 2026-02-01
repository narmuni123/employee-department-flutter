import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;
  final bool isAuthenticated;
  final String? authError;

  const AuthState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.isSubmitting = false,
    this.isAuthenticated = false,
    this.authError,
  });

  bool get isValid =>
      emailError == null &&
      passwordError == null &&
      email.isNotEmpty &&
      password.isNotEmpty;

  AuthState copyWith({
    String? email,
    String? password,
    String? Function()? emailError,
    String? Function()? passwordError,
    bool? isSubmitting,
    bool? isAuthenticated,
    String? Function()? authError,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError: passwordError != null
          ? passwordError()
          : this.passwordError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authError: authError != null ? authError() : this.authError,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    emailError,
    passwordError,
    isSubmitting,
    isAuthenticated,
    authError,
  ];
}
