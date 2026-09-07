import 'package:flutter/material.dart';

import '../../domain/entity/task_entity.dart';
import '../utils/drag_task_data.dart';
import 'dashed_placeholder.dart';
import 'task_card_widget.dart';

class DraggableTaskCard extends StatelessWidget {
  const DraggableTaskCard({
    super.key,
    required this.task,
    required this.sourceColumnId,
    required this.cardWidth,
    required this.onTap,
  });

  final TaskEntity task;
  final String sourceColumnId;
  final double cardWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<DragTaskData>(
      data: DragTaskData(task: task, sourceColumnId: sourceColumnId),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.05,
          child: Opacity(
            opacity: 0.85,
            child: SizedBox(
              width: cardWidth,
              child: TaskCardWidget(task: task, onTap: () {}),
            ),
          ),
        ),
      ),
      childWhenDragging: const DashedPlaceholder(),
      child: TaskCardWidget(task: task, onTap: onTap),
    );
  }
}
