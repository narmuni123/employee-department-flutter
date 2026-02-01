import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({required AuthService authService})
    : _authService = authService,
      super(const AuthState());

  void emailChanged(String email) {
    final emailError = Validators.validateEmail(email);
    emit(
      state.copyWith(
        email: email,
        emailError: () => emailError,
        authError: () => null,
      ),
    );
  }

  void passwordChanged(String password) {
    final passwordError = Validators.validatePassword(password);
    emit(
      state.copyWith(
        password: password,
        passwordError: () => passwordError,
        authError: () => null,
      ),
    );
  }

  void validateForm() {
    final emailError = Validators.validateEmail(state.email);
    final passwordError = Validators.validatePassword(state.password);

    emit(
      state.copyWith(
        emailError: () => emailError,
        passwordError: () => passwordError,
      ),
    );
  }

  Future<void> submit() async {
    validateForm();

    if (!state.isValid) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, authError: () => null));

    final result = await _authService.login(state.email, state.password);

    result.fold(
      (exception) {
        emit(
          state.copyWith(
            isSubmitting: false,
            authError: () => exception.message,
          ),
        );
      },
      (success) {
        emit(state.copyWith(isSubmitting: false, isAuthenticated: true));
      },
    );
  }

  void reset() {
    emit(const AuthState());
  }
}
