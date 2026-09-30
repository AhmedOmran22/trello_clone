import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/context_extensions.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/search_result_entity.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({super.key, required this.result, this.onWorkspaceTap});

  final SearchResultEntity result;

  /// Workspaces have no dedicated detail screen yet — this lets the caller
  /// decide what "open" means for now (e.g. just close the search).
  final VoidCallback? onWorkspaceTap;

  (IconData, Color) _typeStyle() {
    switch (result.type) {
      case SearchResultType.workspace:
        return (Icons.workspaces_outlined, AppColors.primary);
      case SearchResultType.board:
        return (Icons.dashboard_outlined, AppColors.success);
      case SearchResultType.task:
        return (Icons.check_box_outlined, Colors.purple);
    }
  }

  Color? _priorityColor() {
    switch (result.priority) {
      case 'urgent':
        return AppColors.priorityUrgent;
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
        return AppColors.priorityLow;
      default:
        return null;
    }
  }

  void _handleTap(BuildContext context) {
    switch (result.type) {
      case SearchResultType.workspace:
        onWorkspaceTap?.call();
      case SearchResultType.board:
        context.push('${RouteNames.board}/${result.id}', extra: result.title);
      case SearchResultType.task:
      // Would navigate to the board and scroll to this task — not wired
      // up yet, so this tile is display-only for now.
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _typeStyle();
    final priorityColor = _priorityColor();
    final subtleColor = context.colorScheme.onSurface.withValues(alpha: 0.6);

    return InkWell(
      onTap: () => _handleTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                if (priorityColor != null)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                      if (result.isOverdue == true) ...[
                        const SizedBox(width: AppTheme.spacingSm),
                        const _OverdueBadge(),
                      ],
                    ],
                  ),
                  if (result.subtitle?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: subtleColor,
                      ),
                    ),
                  ],
                  if (result.breadcrumb?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.breadcrumb!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: subtleColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: subtleColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
      ),
      child: Text(
        'Overdue',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.error,
        ),
      ),
    );
  }
}
