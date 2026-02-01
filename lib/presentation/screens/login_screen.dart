import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _onLoginPressed(BuildContext context) {
    context.read<AuthCubit>().submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/departments');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App logo/icon
                    Icon(
                      Icons.business,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    // App title
                    Text(
                      'Employee Department',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      value: state.email,
                      errorText: state.emailError,
                      onChanged: (value) {
                        context.read<AuthCubit>().emailChanged(value);
                      },
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                      enabled: !state.isSubmitting,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      value: state.password,
                      errorText: state.passwordError,
                      onChanged: (value) {
                        context.read<AuthCubit>().passwordChanged(value);
                      },
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconPressed: _togglePasswordVisibility,
                      textInputAction: TextInputAction.done,
                      onSubmitted: state.isSubmitting
                          ? null
                          : () => _onLoginPressed(context),
                      enabled: !state.isSubmitting,
                    ),
                    const SizedBox(height: 8),

                    // Auth error message (for general authentication errors)
                    if (state.authError != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.authError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 48,
                      child: state.isSubmitting
                          ? const Center(
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : FilledButton(
                              onPressed: () => _onLoginPressed(context),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
