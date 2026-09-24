import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/board_column_entity.dart';
import '../../domain/entity/task_entity.dart';

Future<void> showMoveTaskBottomSheet(
  BuildContext context, {
  required TaskEntity task,
  required List<BoardColumnEntity> otherColumns,
  void Function(String targetColumnId)? onMove,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _MoveTaskBottomSheet(
      task: task,
      otherColumns: otherColumns,
      onMove: onMove,
    ),
  );
}

class _MoveTaskBottomSheet extends StatelessWidget {
  const _MoveTaskBottomSheet({
    required this.task,
    required this.otherColumns,
    this.onMove,
  });

  final TaskEntity task;
  final List<BoardColumnEntity> otherColumns;
  final void Function(String targetColumnId)? onMove;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: AppTheme.spacingMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Move Task', style: context.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    task.title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            if (otherColumns.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Text(
                  'No other columns to move this task to.',
                  style: context.textTheme.bodyMedium,
                ),
              )
            else
              ...otherColumns.map(
                (column) => ListTile(
                  title: Text(column.name),
                  trailing: Text(
                    '${column.tasks.length}',
                    style: context.textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onMove?.call(column.id);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
