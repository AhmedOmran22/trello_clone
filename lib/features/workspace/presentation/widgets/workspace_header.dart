import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class WorkspaceHeader extends StatelessWidget {
  final String name;

  const WorkspaceHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(
            Icons.expand_more,
            size: 20,
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
