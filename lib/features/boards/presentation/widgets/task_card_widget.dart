import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/task_entity.dart';
import '../utils/date_formatter.dart';

class TaskCardWidget extends StatelessWidget {
  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onTap,
    this.onLongPress,
  });

  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  Color _priorityColor() {
    switch (task.priority) {
      case 'urgent':
        return AppColors.priorityUrgent;
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
      default:
        return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final hasDueDate = task.dueDate != null;
    final isDueToday = hasDueDate &&
        !task.isOverdue &&
        _isSameDay(task.dueDate!, DateTime.now());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm,
            vertical: AppTheme.spacingSm / 2,
          ),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 4, color: _priorityColor()),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: context.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasDueDate || task.description != null) ...[
                      const SizedBox(height: AppTheme.spacingSm),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (hasDueDate)
                            _DueDateBadge(
                              dueDate: task.dueDate!,
                              isOverdue: task.isOverdue,
                              isDueToday: isDueToday,
                            ),
                          if (task.description != null && task.description!.isNotEmpty)
                            Icon(
                              Icons.description_outlined,
                              size: 16,
                              color: scheme.onSurface.withValues(alpha: 0.5),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppTheme.spacingSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (task.assigneeName != null) _AssigneeAvatar(name: task.assigneeName!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DueDateBadge extends StatelessWidget {
  const _DueDateBadge({
    required this.dueDate,
    required this.isOverdue,
    required this.isDueToday,
  });

  final DateTime dueDate;
  final bool isOverdue;
  final bool isDueToday;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    if (isOverdue) {
      background = AppColors.error;
      foreground = Colors.white;
    } else if (isDueToday) {
      background = AppColors.priorityHigh;
      foreground = AppColors.textPrimaryLight;
    } else {
      background = context.colorScheme.onSurface.withValues(alpha: 0.08);
      foreground = context.colorScheme.onSurface.withValues(alpha: 0.7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 11, color: foreground),
          const SizedBox(width: 4),
          Text(
            DateFormatter.short(dueDate),
            style: TextStyle(fontSize: 11, color: foreground, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _AssigneeAvatar extends StatelessWidget {
  const _AssigneeAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: context.colorScheme.primary,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
