import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/board_column_entity.dart';
import '../../domain/entity/task_entity.dart';
import '../utils/date_formatter.dart';
import 'move_task_bottom_sheet.dart';

Future<void> showTaskDetailBottomSheet(
  BuildContext context, {
  required TaskEntity task,
  required String columnName,
  required List<BoardColumnEntity> otherColumns,
  VoidCallback? onDelete,
  void Function(String targetColumnId)? onMove,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _TaskDetailBottomSheet(
      task: task,
      columnName: columnName,
      otherColumns: otherColumns,
      onDelete: onDelete,
      onMove: onMove,
    ),
  );
}

class _TaskDetailBottomSheet extends StatelessWidget {
  const _TaskDetailBottomSheet({
    required this.task,
    required this.columnName,
    required this.otherColumns,
    this.onDelete,
    this.onMove,
  });

  final TaskEntity task;
  final String columnName;
  final List<BoardColumnEntity> otherColumns;
  final VoidCallback? onDelete;
  final void Function(String targetColumnId)? onMove;

  Color _priorityColor(String priority) {
    switch (priority) {
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
    final screenHeight = context.screenHeight;

    return SizedBox(
      height: screenHeight * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: _priorityColor(task.priority)),
          const SizedBox(height: AppTheme.spacingSm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: context.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'in $columnName',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingSm),
                  _DetailSection(
                    icon: Icons.description_outlined,
                    label: 'Description',
                    child: Text(
                      task.description?.isNotEmpty == true
                          ? task.description!
                          : 'No description',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: task.description?.isNotEmpty == true
                            ? null
                            : context.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  _DetailSection(
                    icon: Icons.calendar_today,
                    label: 'Due Date',
                    child: Text(
                      task.dueDate != null ? DateFormatter.long(task.dueDate!) : 'No due date',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: task.isOverdue
                            ? AppColors.error
                            : task.dueDate == null
                                ? context.colorScheme.onSurface.withValues(alpha: 0.5)
                                : null,
                        fontWeight: task.isOverdue ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                  _DetailSection(
                    icon: Icons.person_outline,
                    label: 'Assignee',
                    child: task.assigneeName != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: context.colorScheme.primary,
                                child: Text(
                                  task.assigneeName![0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingSm),
                              Text(task.assigneeName!, style: context.textTheme.bodyMedium),
                            ],
                          )
                        : Text(
                            'Unassigned',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                  ),
                  _DetailSection(
                    icon: Icons.flag_outlined,
                    label: 'Priority',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _priorityColor(task.priority).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
                      ),
                      child: Text(
                        task.priority[0].toUpperCase() + task.priority.substring(1),
                        style: TextStyle(
                          color: _priorityColor(task.priority),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showMoveTaskBottomSheet(
                        context,
                        task: task,
                        otherColumns: otherColumns,
                        onMove: onMove,
                      );
                    },
                    icon: const Icon(Icons.drive_file_move_outline),
                    label: const Text('Move'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete?.call();
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.icon, required this.label, required this.child});

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
