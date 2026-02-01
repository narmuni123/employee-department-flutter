import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:employment_department/core/error/app_exception.dart';
import 'package:employment_department/core/services/auth_service.dart';
import 'package:employment_department/presentation/bloc/auth/auth_cubit.dart';
import 'package:employment_department/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;
  late AuthCubit authCubit;

  setUp(() {
    mockAuthService = MockAuthService();
    authCubit = AuthCubit(authService: mockAuthService);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state is correct', () {
      expect(authCubit.state, const AuthState());
      expect(authCubit.state.email, '');
      expect(authCubit.state.password, '');
      expect(authCubit.state.emailError, null);
      expect(authCubit.state.passwordError, null);
      expect(authCubit.state.isSubmitting, false);
      expect(authCubit.state.isAuthenticated, false);
      expect(authCubit.state.authError, null);
    });

    group('emailChanged', () {
      blocTest<AuthCubit, AuthState>(
        'emits state with email and no error for valid email',
        build: () => AuthCubit(authService: mockAuthService),
        act: (cubit) => cubit.emailChanged('test@example.com'),
        expect: () => [
          const AuthState(email: 'test@example.com', emailError: null),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits state with email and error for invalid email',
        build: () => AuthCubit(authService: mockAuthService),
        act: (cubit) => cubit.emailChanged('invalid-email'),
        expect: () => [
          const AuthState(
            email: 'invalid-email',
            emailError: 'Please enter a valid email address',
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits state with email and error for email without domain',
        build: () => AuthCubit(authService: mockAuthService),
        act: (cubit) => cubit.emailChanged('test@'),
        expect: () => [
          const AuthState(
            email: 'test@',
            emailError: 'Please enter a valid email address',
          ),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<AuthCubit, AuthState>(
        'emits state with password and no error for valid password',
        build: () => AuthCubit(authService: mockAuthService),
        act: (cubit) => cubit.passwordChanged('password123'),
        expect: () => [
          const AuthState(password: 'password123', passwordError: null),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits state with password and error for short password',
        build: () => AuthCubit(authService: mockAuthService),
        act: (cubit) => cubit.passwordChanged('12345'),
        expect: () => [
          const AuthState(
            password: '12345',
            passwordError: 'Password must be at least 6 characters long',
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits state with password and error for empty password',
        build: () => AuthCubit(authService: mockAuthService),
        act: (cubit) => cubit.passwordChanged(''),
        expect: () => [
          const AuthState(
            password: '',
            passwordError: 'Password must be at least 6 characters long',
          ),
        ],
      );
    });

    group('validateForm', () {
      blocTest<AuthCubit, AuthState>(
        'validates both email and password fields',
        build: () => AuthCubit(authService: mockAuthService),
        seed: () => const AuthState(email: 'invalid', password: '123'),
        act: (cubit) => cubit.validateForm(),
        expect: () => [
          const AuthState(
            email: 'invalid',
            password: '123',
            emailError: 'Please enter a valid email address',
            passwordError: 'Password must be at least 6 characters long',
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'clears errors for valid inputs',
        build: () => AuthCubit(authService: mockAuthService),
        seed: () => const AuthState(
          email: 'test@example.com',
          password: 'password123',
          emailError: 'Previous error',
          passwordError: 'Previous error',
        ),
        act: (cubit) => cubit.validateForm(),
        expect: () => [
          const AuthState(
            email: 'test@example.com',
            password: 'password123',
            emailError: null,
            passwordError: null,
          ),
        ],
      );
    });

    group('submit', () {
      blocTest<AuthCubit, AuthState>(
        'does not submit when form is invalid',
        build: () => AuthCubit(authService: mockAuthService),
        seed: () => const AuthState(email: 'invalid', password: '123'),
        act: (cubit) => cubit.submit(),
        expect: () => [
          const AuthState(
            email: 'invalid',
            password: '123',
            emailError: 'Please enter a valid email address',
            passwordError: 'Password must be at least 6 characters long',
          ),
        ],
        verify: (_) {
          verifyNever(() => mockAuthService.login(any(), any()));
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits loading then authenticated on successful login',
        build: () {
          when(
            () => mockAuthService.login(any(), any()),
          ).thenAnswer((_) async => const Right(true));
          return AuthCubit(authService: mockAuthService);
        },
        seed: () =>
            const AuthState(email: 'test@example.com', password: 'password123'),
        act: (cubit) => cubit.submit(),
        expect: () => [
          // First: loading state (validation passes with no state change since already valid)
          const AuthState(
            email: 'test@example.com',
            password: 'password123',
            emailError: null,
            passwordError: null,
            isSubmitting: true,
          ),
          // Second: authenticated state
          const AuthState(
            email: 'test@example.com',
            password: 'password123',
            emailError: null,
            passwordError: null,
            isSubmitting: false,
            isAuthenticated: true,
          ),
        ],
        verify: (_) {
          verify(
            () => mockAuthService.login('test@example.com', 'password123'),
          ).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits loading then error on failed login',
        build: () {
          when(() => mockAuthService.login(any(), any())).thenAnswer(
            (_) async => Left(NetworkException('No internet connection')),
          );
          return AuthCubit(authService: mockAuthService);
        },
        seed: () =>
            const AuthState(email: 'test@example.com', password: 'password123'),
        act: (cubit) => cubit.submit(),
        expect: () => [
          // First: loading state (validation passes with no state change since already valid)
          const AuthState(
            email: 'test@example.com',
            password: 'password123',
            emailError: null,
            passwordError: null,
            isSubmitting: true,
          ),
          // Second: error state
          const AuthState(
            email: 'test@example.com',
            password: 'password123',
            emailError: null,
            passwordError: null,
            isSubmitting: false,
            authError: 'No internet connection',
          ),
        ],
      );
    });

    group('reset', () {
      blocTest<AuthCubit, AuthState>(
        'resets state to initial values',
        build: () => AuthCubit(authService: mockAuthService),
        seed: () => const AuthState(
          email: 'test@example.com',
          password: 'password123',
          isAuthenticated: true,
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [const AuthState()],
      );
    });

    group('isValid', () {
      test('returns false when email is empty', () {
        const state = AuthState(email: '', password: 'password123');
        expect(state.isValid, false);
      });

      test('returns false when password is empty', () {
        const state = AuthState(email: 'test@example.com', password: '');
        expect(state.isValid, false);
      });

      test('returns false when email has error', () {
        const state = AuthState(
          email: 'test@example.com',
          password: 'password123',
          emailError: 'Invalid email',
        );
        expect(state.isValid, false);
      });

      test('returns false when password has error', () {
        const state = AuthState(
          email: 'test@example.com',
          password: 'password123',
          passwordError: 'Invalid password',
        );
        expect(state.isValid, false);
      });

      test('returns true when all fields are valid', () {
        const state = AuthState(
          email: 'test@example.com',
          password: 'password123',
        );
        expect(state.isValid, true);
      });
    });
  });
}
