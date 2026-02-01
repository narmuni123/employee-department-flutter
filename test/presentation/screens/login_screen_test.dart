import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employment_department/core/services/auth_service.dart';
import 'package:employment_department/presentation/bloc/auth/auth_cubit.dart';
import 'package:employment_department/presentation/screens/login_screen.dart';

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

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/departments': (context) => const Scaffold(
              body: Center(child: Text('Department List Screen')),
            ),
      },
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('displays email and password fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('displays app title and subtitle', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Employee Department'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('shows email validation error for invalid email',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pump();

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows password validation error for short password',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).last, '12345');
      await tester.pump();

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters long'),
          findsOneWidget);
    });

    testWidgets('navigates to departments screen on successful login',
        (tester) async {
      when(() => mockAuthService.login(any(), any()))
          .thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pump();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Department List Screen'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final passwordField = find.byType(TextFormField).last;
      expect(passwordField, findsOneWidget);

      final visibilityButton = find.byIcon(Icons.visibility_outlined);
      expect(visibilityButton, findsOneWidget);

      await tester.tap(visibilityButton);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
