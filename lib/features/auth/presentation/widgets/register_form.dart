import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import 'auth_or_divider.dart';
import 'auth_text_field_widget.dart';
import 'google_sign_in_button.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Account', style: context.textTheme.headlineMedium),
          const SizedBox(height: AppTheme.spacingSm / 2),
          Text(
            'Sign up to get started',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          AuthTextField(
            controller: _nameController,
            hintText: 'Full Name',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: Validators.fullName,
          ),
          const SizedBox(height: AppTheme.spacingMd),
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
            textInputAction: TextInputAction.next,
            validator: Validators.password,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          AuthTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm Password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                Validators.confirmPassword(value, _passwordController.text),
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (BuildContext context, state) {
              return ElevatedButton(
                onPressed: state.status != AuthStatus.loading ? _submit : null,
                child: state.status == AuthStatus.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Account'),
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingLg),
          const AuthOrDivider(),
          const SizedBox(height: AppTheme.spacingLg),
          GoogleSignInButton(
            onPressed: () => context.read<AuthCubit>().loginWithGoogle(),
          ),
        ],
      ),
    );
  }
}
