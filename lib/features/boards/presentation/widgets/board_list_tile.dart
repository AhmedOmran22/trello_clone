import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class BoardListTile extends StatelessWidget {
  final String name;
  final Color accentColor;
  final VoidCallback? onOptionsTap;

  const BoardListTile({
    super.key,
    required this.name,
    required this.accentColor,
    this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm / 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              name,
              style: context.textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onOptionsTap,
            icon: const Icon(Icons.more_vert),
            iconSize: 18,
            color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Board options',
          ),
        ],
      ),
    );
  }
}
