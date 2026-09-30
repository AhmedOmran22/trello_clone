import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 64,
              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text('No notifications yet', style: context.textTheme.titleMedium),
            const SizedBox(height: AppTheme.spacingSm / 2),
            Text(
              "You'll see updates about your tasks and workspaces here",
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
