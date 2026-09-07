import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/board_column_entity.dart';
import '../../domain/entity/board_entity.dart';
import '../../domain/entity/task_entity.dart';
import '../utils/board_mock_data.dart';
import '../utils/drag_task_data.dart';
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
  late BoardEntity _board;
  final _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _board = BoardMockData.board(boardId: widget.boardId, boardName: widget.boardName);
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  int _columnIndex(String columnId) => _board.columns.indexWhere((c) => c.id == columnId);

  BoardColumnEntity _reindexedColumn(BoardColumnEntity column, List<TaskEntity> tasks) {
    return BoardColumnEntity(
      id: column.id,
      boardId: column.boardId,
      name: column.name,
      position: column.position,
      createdAt: column.createdAt,
      tasks: [
        for (var i = 0; i < tasks.length; i++)
          TaskEntity(
            id: tasks[i].id,
            columnId: column.id,
            title: tasks[i].title,
            description: tasks[i].description,
            priority: tasks[i].priority,
            position: i,
            dueDate: tasks[i].dueDate,
            assigneeId: tasks[i].assigneeId,
            assigneeName: tasks[i].assigneeName,
            assigneeAvatarUrl: tasks[i].assigneeAvatarUrl,
            createdAt: tasks[i].createdAt,
          ),
      ],
    );
  }

  BoardEntity _replaceColumn(BoardColumnEntity updatedColumn) {
    return BoardEntity(
      id: _board.id,
      workspaceId: _board.workspaceId,
      name: _board.name,
      createdAt: _board.createdAt,
      columns: [
        for (final column in _board.columns)
          if (column.id == updatedColumn.id) updatedColumn else column,
      ],
    );
  }

  void _moveTask(DragTaskData data, String toColumnId, int targetIndex) {
    setState(() {
      final fromColumn = _board.columns[_columnIndex(data.sourceColumnId)];
      final toColumn = _board.columns[_columnIndex(toColumnId)];

      if (fromColumn.id == toColumn.id) {
        final tasks = List<TaskEntity>.from(fromColumn.tasks);
        final oldIndex = tasks.indexWhere((t) => t.id == data.task.id);
        if (oldIndex == -1) return;
        var newIndex = targetIndex;
        if (newIndex > oldIndex) newIndex -= 1;
        newIndex = newIndex.clamp(0, tasks.length - 1);
        final task = tasks.removeAt(oldIndex);
        tasks.insert(newIndex, task);
        _board = _replaceColumn(_reindexedColumn(fromColumn, tasks));
        return;
      }

      final remaining = fromColumn.tasks.where((t) => t.id != data.task.id).toList();
      final destTasks = List<TaskEntity>.from(toColumn.tasks);
      final clampedIndex = targetIndex.clamp(0, destTasks.length);
      destTasks.insert(clampedIndex, data.task);

      _board = BoardEntity(
        id: _board.id,
        workspaceId: _board.workspaceId,
        name: _board.name,
        createdAt: _board.createdAt,
        columns: [
          for (final column in _board.columns)
            if (column.id == fromColumn.id)
              _reindexedColumn(fromColumn, remaining)
            else if (column.id == toColumn.id)
              _reindexedColumn(toColumn, destTasks)
            else
              column,
        ],
      );
    });
  }

  void _deleteTask(String columnId, String taskId) {
    setState(() {
      final column = _board.columns[_columnIndex(columnId)];
      _board = _replaceColumn(
        _reindexedColumn(column, column.tasks.where((t) => t.id != taskId).toList()),
      );
    });
  }

  void _addTask(
    String columnId,
    String title,
    String? description,
    String priority,
    DateTime? dueDate,
  ) {
    setState(() {
      final column = _board.columns[_columnIndex(columnId)];
      final newTask = TaskEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        columnId: columnId,
        title: title,
        description: description,
        priority: priority,
        position: column.tasks.length,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );
      _board = _replaceColumn(
        BoardColumnEntity(
          id: column.id,
          boardId: column.boardId,
          name: column.name,
          position: column.position,
          createdAt: column.createdAt,
          tasks: [...column.tasks, newTask],
        ),
      );
    });
  }

  void _addColumn(String name) {
    setState(() {
      final newColumn = BoardColumnEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        boardId: _board.id,
        name: name,
        position: _board.columns.length,
        createdAt: DateTime.now(),
      );
      _board = BoardEntity(
        id: _board.id,
        workspaceId: _board.workspaceId,
        name: _board.name,
        createdAt: _board.createdAt,
        columns: [..._board.columns, newColumn],
      );
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_horizontalController.hasClients) {
        _horizontalController.animateTo(
          _horizontalController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _renameColumn(String columnId, String newName) {
    setState(() {
      final column = _board.columns[_columnIndex(columnId)];
      _board = _replaceColumn(
        BoardColumnEntity(
          id: column.id,
          boardId: column.boardId,
          name: newName,
          position: column.position,
          createdAt: column.createdAt,
          tasks: column.tasks,
        ),
      );
    });
  }

  void _deleteColumn(String columnId) {
    setState(() {
      final remaining = _board.columns.where((c) => c.id != columnId).toList();
      _board = BoardEntity(
        id: _board.id,
        workspaceId: _board.workspaceId,
        name: _board.name,
        createdAt: _board.createdAt,
        columns: [
          for (var i = 0; i < remaining.length; i++)
            BoardColumnEntity(
              id: remaining[i].id,
              boardId: remaining[i].boardId,
              name: remaining[i].name,
              position: i,
              createdAt: remaining[i].createdAt,
              tasks: remaining[i].tasks,
            ),
        ],
      );
    });
  }

  void _applyColumnOrder(List<BoardColumnEntity> newOrder) {
    setState(() {
      _board = BoardEntity(
        id: _board.id,
        workspaceId: _board.workspaceId,
        name: _board.name,
        createdAt: _board.createdAt,
        columns: [
          for (var i = 0; i < newOrder.length; i++)
            BoardColumnEntity(
              id: newOrder[i].id,
              boardId: newOrder[i].boardId,
              name: newOrder[i].name,
              position: i,
              createdAt: newOrder[i].createdAt,
              tasks: newOrder[i].tasks,
            ),
        ],
      );
    });
  }

  void _openTaskDetail(BoardColumnEntity column, TaskEntity task) {
    showTaskDetailBottomSheet(
      context,
      task: task,
      columnName: column.name,
      otherColumns: _board.columns.where((c) => c.id != column.id).toList(),
      onDelete: () => _deleteTask(column.id, task.id),
      onMove: (targetColumnId) {
        final targetColumn = _board.columns[_columnIndex(targetColumnId)];
        _moveTask(
          DragTaskData(task: task, sourceColumnId: column.id),
          targetColumnId,
          targetColumn.tasks.length,
        );
      },
    );
  }

  void _openAddColumnSheet() {
    showAddColumnBottomSheet(context, onSubmit: _addColumn);
  }

  void _openAddTaskSheet(BoardColumnEntity column) {
    showAddTaskBottomSheet(
      context,
      columnName: column.name,
      onSubmit: (title, description, priority, dueDate) =>
          _addTask(column.id, title, description, priority, dueDate),
    );
  }

  void _openRenameColumnSheet(BoardColumnEntity column) {
    showRenameColumnBottomSheet(
      context,
      currentName: column.name,
      onSave: (newName) => _renameColumn(column.id, newName),
    );
  }

  void _openReorderColumnsSheet() {
    showReorderColumnsBottomSheet(
      context,
      columns: _board.columns,
      onSave: _applyColumnOrder,
    );
  }

  void _confirmDeleteColumn(BoardColumnEntity column) {
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
              _deleteColumn(column.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openColumnOptions(BoardColumnEntity column) {
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
                _openRenameColumnSheet(column);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Reorder Columns'),
              onTap: () {
                Navigator.pop(context);
                _openReorderColumnsSheet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Column', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteColumn(column);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_board.name),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: _openBoardOptionsSheet),
          IconButton(icon: const Icon(Icons.add), onPressed: _openAddColumnSheet),
        ],
      ),
      body: NotificationListener<ScrollEndNotification>(
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
              for (final column in _board.columns)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: gap),
                  child: BoardColumnWidget(
                    column: column,
                    columnWidth: columnWidth,
                    onTaskTap: (task) => _openTaskDetail(column, task),
                    onDropTask: (data, index) => _moveTask(data, column.id, index),
                    onAddCard: () => _openAddTaskSheet(column),
                    onMoreOptions: () => _openColumnOptions(column),
                    onReorderColumns: _openReorderColumnsSheet,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: gap),
                child: SizedBox(
                  width: columnWidth,
                  child: _AddColumnCard(onTap: _openAddColumnSheet),
                ),
              ),
            ],
          ),
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
