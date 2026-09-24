import 'package:equatable/equatable.dart';

import '../../domain/entity/board_column_entity.dart';
import '../../domain/entity/task_entity.dart';

sealed class BoardEvent extends Equatable {
  const BoardEvent();

  @override
  List<Object?> get props => [];
}

// ── Board ──

class BoardLoadRequested extends BoardEvent {
  final String boardId;

  const BoardLoadRequested(this.boardId);

  @override
  List<Object?> get props => [boardId];
}

// ── Columns ──

class ColumnCreated extends BoardEvent {
  final String name;

  const ColumnCreated(this.name);

  @override
  List<Object?> get props => [name];
}

class ColumnRenamed extends BoardEvent {
  final String columnId;
  final String name;

  const ColumnRenamed({required this.columnId, required this.name});

  @override
  List<Object?> get props => [columnId, name];
}

class ColumnsReordered extends BoardEvent {
  final List<BoardColumnEntity> columns;

  const ColumnsReordered(this.columns);

  @override
  List<Object?> get props => [columns];
}

class ColumnDeleted extends BoardEvent {
  final String columnId;

  const ColumnDeleted(this.columnId);

  @override
  List<Object?> get props => [columnId];
}

// ── Tasks ──

class TaskCreated extends BoardEvent {
  final String columnId;
  final String title;
  final String? description;
  final String priority;
  final DateTime? dueDate;
  final String? assigneeId;

  const TaskCreated({
    required this.columnId,
    required this.title,
    this.description,
    required this.priority,
    this.dueDate,
    this.assigneeId,
  });

  @override
  List<Object?> get props => [columnId, title, description, priority, dueDate, assigneeId];
}

class TaskUpdated extends BoardEvent {
  final String taskId;
  final String? title;
  final String? description;
  final String? priority;
  final DateTime? dueDate;
  final String? assigneeId;

  const TaskUpdated({
    required this.taskId,
    this.title,
    this.description,
    this.priority,
    this.dueDate,
    this.assigneeId,
  });

  @override
  List<Object?> get props => [taskId, title, description, priority, dueDate, assigneeId];
}

class TaskMoved extends BoardEvent {
  final String taskId;
  final String fromColumnId;
  final String targetColumnId;
  final int newPosition;

  const TaskMoved({
    required this.taskId,
    required this.fromColumnId,
    required this.targetColumnId,
    required this.newPosition,
  });

  @override
  List<Object?> get props => [taskId, fromColumnId, targetColumnId, newPosition];
}

class TasksReordered extends BoardEvent {
  final String columnId;
  final List<TaskEntity> tasks;

  const TasksReordered({required this.columnId, required this.tasks});

  @override
  List<Object?> get props => [columnId, tasks];
}

class TaskDeleted extends BoardEvent {
  final String taskId;
  final String columnId;

  const TaskDeleted({required this.taskId, required this.columnId});

  @override
  List<Object?> get props => [taskId, columnId];
}

// ── Real-time ──

class RealtimeColumnsUpdated extends BoardEvent {
  final List<BoardColumnEntity> columns;

  const RealtimeColumnsUpdated(this.columns);

  @override
  List<Object?> get props => [columns];
}

class RealtimeTasksUpdated extends BoardEvent {
  final List<TaskEntity> tasks;

  const RealtimeTasksUpdated(this.tasks);

  @override
  List<Object?> get props => [tasks];
}
