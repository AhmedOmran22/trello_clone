import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.searches,
    this.onSelect,
    this.onClear,
  });

  final List<String> searches;
  final ValueChanged<String>? onSelect;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: AppTheme.spacingSm),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Searches',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              TextButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
        ),
        for (final term in searches) ...[
          ListTile(
            leading: Icon(
              Icons.history,
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            title: Text(term),
            onTap: () => onSelect?.call(term),
          ),
          const Divider(height: 1, indent: AppTheme.spacingLg),
        ],
      ],
    );
  }
}
