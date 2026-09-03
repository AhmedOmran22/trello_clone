import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import 'auth_or_divider.dart';
import 'auth_text_field_widget.dart';
import 'google_sign_in_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {}
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Welcome Back', style: context.textTheme.headlineMedium),
          const SizedBox(height: AppTheme.spacingSm / 2),
          Text(
            'Sign in to continue',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          AuthTextField(
            controller: _emailController,
            hintText: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AuthTextField(
            controller: _passwordController,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: Validators.password,
            onFieldSubmitted: (_) => _submit(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          ElevatedButton(onPressed: () => _submit(), child: const Text('Sign In')),
          const SizedBox(height: AppTheme.spacingLg),
          const AuthOrDivider(),
          const SizedBox(height: AppTheme.spacingLg),
          GoogleSignInButton(onPressed: () {}),
        ],
      ),
    );
  }
}
