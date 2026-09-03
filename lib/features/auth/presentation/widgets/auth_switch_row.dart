import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

/// Bottom row prompting the user to switch between login and register,
/// e.g. "Don't have an account? Register".
class AuthSwitchRow extends StatelessWidget {
  const AuthSwitchRow({
    super.key,
    required this.promptText,
    required this.actionText,
    this.onPressed,
  });

  final String promptText;
  final String actionText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(promptText, style: context.textTheme.bodyMedium),
          TextButton(onPressed: onPressed, child: Text(actionText)),
        ],
      ),
    );
  }
}
