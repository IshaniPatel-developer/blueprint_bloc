import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Login page - Stateless for better performance and maintainability.
/// State is managed entirely by AuthBloc.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.loginTitle)),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            // Show error message if login fails
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            // Navigate to dashboard if authenticated
            if (state is AuthAuthenticated) {
              context.go('/dashboard');
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: _LoginForm(isLoading: isLoading),
            );
          },
        ),
      ),
    );
  }
}

/// Separate form widget for better code organization.
/// Uses GlobalKey to access form state without StatefulWidget.
class _LoginForm extends StatelessWidget {
  final bool isLoading;

  const _LoginForm({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field using common widget
          CustomTextField(
            controller: emailController,
            labelText: AppStrings.emailLabel,
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.emailRequired;
              }
              if (!value.contains('@')) {
                return AppStrings.emailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Password field using common widget
          CustomTextField(
            controller: passwordController,
            labelText: AppStrings.passwordLabel,
            prefixIcon: Icons.lock,
            obscureText: true,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.passwordRequired;
              }
              if (value.length < AppConstants.minimumPasswordLength) {
                return AppStrings.passwordTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Login button
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (formKey.currentState!.validate()) {
                      // Trigger login event in BLoC
                      context.read<AuthBloc>().add(
                        AuthLoginRequested(
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.buttonVerticalPadding,
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppStrings.loginButton),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Navigate to signup
          TextButton(
            onPressed: isLoading ? null : () => context.go('/signup'),
            child: const Text(AppStrings.dontHaveAccount),
          ),
        ],
      ),
    );
  }
}
