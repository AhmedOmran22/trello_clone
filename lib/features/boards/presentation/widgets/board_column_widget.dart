import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/board_column_entity.dart';
import '../../domain/entity/task_entity.dart';
import '../utils/drag_task_data.dart';
import 'draggable_task_card.dart';

class BoardColumnWidget extends StatelessWidget {
  const BoardColumnWidget({
    super.key,
    required this.column,
    required this.columnWidth,
    required this.onTaskTap,
    required this.onDropTask,
    required this.onAddCard,
    required this.onMoreOptions,
    required this.onReorderColumns,
  });

  final BoardColumnEntity column;
  final double columnWidth;
  final void Function(TaskEntity task) onTaskTap;
  final void Function(DragTaskData data, int targetIndex) onDropTask;
  final VoidCallback onAddCard;
  final VoidCallback onMoreOptions;
  final VoidCallback onReorderColumns;

  int _dropIndex(Map<String, GlobalKey> cardKeys, Offset globalOffset) {
    for (var i = 0; i < column.tasks.length; i++) {
      final key = cardKeys[column.tasks[i].id];
      final box = key?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero);
      final midY = top.dy + box.size.height / 2;
      if (globalOffset.dy < midY) return i;
    }
    return column.tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final columnBackground = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : scheme.onSurface.withValues(alpha: 0.035);
    final headerBackground = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : scheme.onSurface.withValues(alpha: 0.05);

    final cardKeys = {for (final task in column.tasks) task.id: GlobalKey()};

    return SizedBox(
      width: columnWidth,
      child: DragTarget<DragTaskData>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (details) {
          final index = _dropIndex(cardKeys, details.offset);
          onDropTask(details.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return Container(
            decoration: BoxDecoration(
              color: columnBackground,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
              border: Border.all(
                color: isHovering
                    ? scheme.primary.withValues(alpha: 0.6)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onLongPress: onReorderColumns,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm / 2),
                    decoration: BoxDecoration(
                      color: headerBackground,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.borderRadiusLg),
                      ),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: onReorderColumns,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingSm),
                            child: Icon(
                              Icons.drag_indicator,
                              size: 18,
                              color: scheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${column.name} (${column.tasks.length})',
                            style: context.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: onMoreOptions,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingSm),
                            child: Icon(
                              Icons.more_horiz,
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                    child: column.tasks.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
                            child: Center(
                              child: Text('No tasks yet', style: context.textTheme.bodySmall),
                            ),
                          )
                        : Column(
                            children: [
                              for (final task in column.tasks)
                                DraggableTaskCard(
                                  key: cardKeys[task.id],
                                  task: task,
                                  sourceColumnId: column.id,
                                  cardWidth: columnWidth,
                                  onTap: () => onTaskTap(task),
                                ),
                            ],
                          ),
                  ),
                ),
                InkWell(
                  onTap: onAddCard,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingSm),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 18, color: scheme.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 6),
                        Text(
                          'Add a card',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
