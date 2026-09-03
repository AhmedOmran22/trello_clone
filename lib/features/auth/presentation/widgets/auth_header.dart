import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingXl * 2,
        horizontal: AppTheme.spacingLg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0079BF), Color(0xFF026AA7)],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.dashboard_rounded, color: Colors.white, size: 48),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'TaskBoard',
            style: context.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
