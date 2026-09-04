import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class WorkspaceHeader extends StatelessWidget {
  final String name;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onAddBoard;

  const WorkspaceHeader({
    super.key,
    required this.name,
    required this.isExpanded,
    required this.onToggle,
    required this.onAddBoard,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = context.colorScheme.onSurface.withValues(alpha: 0.6);

    return Material(
      color: context.colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
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
              IconButton(
                onPressed: onAddBoard,
                icon: const Icon(Icons.add),
                iconSize: 18,
                color: mutedColor,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.chevron_right, size: 20, color: mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
