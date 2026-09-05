import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class BoardTile extends StatelessWidget {
  final String name;
  final Color accentColor;

  const BoardTile({super.key, required this.name, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
            border: Border(left: BorderSide(color: accentColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingMd,
          ),
          child: Row(
            children: [
              Expanded(child: Text(name, style: context.textTheme.bodyLarge)),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
