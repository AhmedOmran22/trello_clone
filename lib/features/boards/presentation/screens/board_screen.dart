import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/board_column_entity.dart';
import '../../domain/entity/task_entity.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_event.dart';
import '../bloc/board_state.dart';
import '../widgets/add_column_bottom_sheet.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/board_column_widget.dart';
import '../widgets/reorder_columns_bottom_sheet.dart';
import '../widgets/rename_column_bottom_sheet.dart';
import '../widgets/task_detail_bottom_sheet.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key, required this.boardId, required this.boardName});

  final String boardId;
  final String boardName;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  void _openTaskDetail(
    BoardBloc bloc,
    BoardColumnEntity column,
    List<BoardColumnEntity> allColumns,
    TaskEntity task,
  ) {
    showTaskDetailBottomSheet(
      context,
      task: task,
      columnName: column.name,
      otherColumns: allColumns.where((c) => c.id != column.id).toList(),
      onDelete: () => bloc.add(TaskDeleted(taskId: task.id, columnId: column.id)),
      onMove: (targetColumnId) {
        final targetColumn = allColumns.firstWhere((c) => c.id == targetColumnId);
        bloc.add(
          TaskMoved(
            taskId: task.id,
            fromColumnId: column.id,
            targetColumnId: targetColumnId,
            newPosition: targetColumn.tasks.length,
          ),
        );
      },
    );
  }

  void _openAddColumnSheet(BoardBloc bloc) {
    showAddColumnBottomSheet(context, onSubmit: (name) => bloc.add(ColumnCreated(name)));
  }

  void _openAddTaskSheet(BoardBloc bloc, BoardColumnEntity column) {
    showAddTaskBottomSheet(
      context,
      columnName: column.name,
      onSubmit: (title, description, priority, dueDate) => bloc.add(
        TaskCreated(
          columnId: column.id,
          title: title,
          description: description,
          priority: priority,
          dueDate: dueDate,
        ),
      ),
    );
  }

  void _openRenameColumnSheet(BoardBloc bloc, BoardColumnEntity column) {
    showRenameColumnBottomSheet(
      context,
      currentName: column.name,
      onSave: (newName) => bloc.add(ColumnRenamed(columnId: column.id, name: newName)),
    );
  }

  void _openReorderColumnsSheet(BoardBloc bloc, List<BoardColumnEntity> columns) {
    showReorderColumnsBottomSheet(
      context,
      columns: columns,
      onSave: (newOrder) => bloc.add(ColumnsReordered(newOrder)),
    );
  }

  void _confirmDeleteColumn(BoardBloc bloc, BoardColumnEntity column) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${column.name}?'),
        content: const Text('All tasks in this column will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              bloc.add(ColumnDeleted(column.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openColumnOptions(
    BoardBloc bloc,
    BoardColumnEntity column,
    List<BoardColumnEntity> columns,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename Column'),
              onTap: () {
                Navigator.pop(context);
                _openRenameColumnSheet(bloc, column);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Reorder Columns'),
              onTap: () {
                Navigator.pop(context);
                _openReorderColumnsSheet(bloc, columns);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Column', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteColumn(bloc, column);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openBoardOptionsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename board'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete board'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final columnWidth = context.screenWidth * 0.8;
    const gap = AppTheme.spacingSm;
    final itemExtent = columnWidth + gap * 2;
    final bloc = context.read<BoardBloc>();

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<BoardBloc, BoardState>(
          builder: (context, state) {
            return Text(state is BoardLoaded ? state.boardName : widget.boardName);
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _openBoardOptionsSheet),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _openAddColumnSheet(bloc)),
        ],
      ),
      body: BlocListener<BoardBloc, BoardState>(
        listenWhen: (previous, current) =>
            current is BoardLoaded &&
            current.actionError != null &&
            !(previous is BoardLoaded && previous.actionError == current.actionError),
        listener: (context, state) {
          context.showErrorSnackBar((state as BoardLoaded).actionError!);
        },
        child: BlocBuilder<BoardBloc, BoardState>(
          builder: (context, state) {
            if (state is BoardError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.isNetworkError ? Icons.wifi_off : Icons.error_outline,
                        size: 48,
                        color: context.colorScheme.error,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: AppTheme.spacingMd),
                      ElevatedButton(
                        onPressed: () => bloc.add(BoardLoadRequested(widget.boardId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is! BoardLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final columns = state.columns;

            return NotificationListener<ScrollEndNotification>(
              onNotification: (notification) {
                if (!_horizontalController.hasClients) return false;
                final position = _horizontalController.position;
                final page = (position.pixels / itemExtent).round();
                final target = (page * itemExtent).clamp(0.0, position.maxScrollExtent);
                if ((target - position.pixels).abs() > 1) {
                  _horizontalController.animateTo(
                    target,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final column in columns)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: gap),
                        child: BoardColumnWidget(
                          column: column,
                          columnWidth: columnWidth,
                          onTaskTap: (task) => _openTaskDetail(bloc, column, columns, task),
                          onDropTask: (data, index) => bloc.add(
                            TaskMoved(
                              taskId: data.task.id,
                              fromColumnId: data.sourceColumnId,
                              targetColumnId: column.id,
                              newPosition: index,
                            ),
                          ),
                          onAddCard: () => _openAddTaskSheet(bloc, column),
                          onMoreOptions: () => _openColumnOptions(bloc, column, columns),
                          onReorderColumns: () => _openReorderColumnsSheet(bloc, columns),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: gap),
                      child: SizedBox(
                        width: columnWidth,
                        child: _AddColumnCard(onTap: () => _openAddColumnSheet(bloc)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddColumnCard extends StatelessWidget {
  const _AddColumnCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.onSurface.withValues(alpha: 0.035),
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 36,
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Add Column',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
