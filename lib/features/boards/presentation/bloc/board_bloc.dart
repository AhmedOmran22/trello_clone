import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entity/board_column_entity.dart';
import '../../domain/entity/task_entity.dart';
import '../../domain/repo/board_repo.dart';
import '../../domain/usecases/create_column_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_column_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_board_usecase.dart';
import '../../domain/usecases/move_task_usecase.dart';
import '../../domain/usecases/rename_column_usecase.dart';
import '../../domain/usecases/reorder_columns_usecase.dart';
import '../../domain/usecases/reorder_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'board_event.dart';
import 'board_state.dart';
class BoardBloc extends Bloc<BoardEvent, BoardState> {
  final String boardId;
  final BoardRepo boardRepo;
  final GetBoardUseCase getBoardUseCase;
  final CreateColumnUseCase createColumnUseCase;
  final RenameColumnUseCase renameColumnUseCase;
  final ReorderColumnsUseCase reorderColumnsUseCase;
  final DeleteColumnUseCase deleteColumnUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final MoveTaskUseCase moveTaskUseCase;
  final ReorderTasksUseCase reorderTasksUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  StreamSubscription<List<BoardColumnEntity>>? _columnsSubscription;
  StreamSubscription<List<TaskEntity>>? _tasksSubscription;

  List<BoardColumnEntity> _columnsMeta = [];
  Map<String, List<TaskEntity>> _tasksByColumn = {};
  List<String> _watchedColumnIds = [];

  BoardBloc({
    required this.boardId,
    required this.boardRepo,
    required this.getBoardUseCase,
    required this.createColumnUseCase,
    required this.renameColumnUseCase,
    required this.reorderColumnsUseCase,
    required this.deleteColumnUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.moveTaskUseCase,
    required this.reorderTasksUseCase,
    required this.deleteTaskUseCase,
  }) : super(const BoardInitial()) {
    on<BoardLoadRequested>(_onBoardLoadRequested);
    on<ColumnCreated>(_onColumnCreated);
    on<ColumnRenamed>(_onColumnRenamed);
    on<ColumnsReordered>(_onColumnsReordered);
    on<ColumnDeleted>(_onColumnDeleted);
    on<TaskCreated>(_onTaskCreated);
    on<TaskUpdated>(_onTaskUpdated);
    on<TaskMoved>(_onTaskMoved);
    on<TasksReordered>(_onTasksReordered);
    on<TaskDeleted>(_onTaskDeleted);
    on<RealtimeColumnsUpdated>(_onRealtimeColumnsUpdated);
    on<RealtimeTasksUpdated>(_onRealtimeTasksUpdated);

    add(BoardLoadRequested(boardId));
  }

  BoardLoaded? get _loaded => state is BoardLoaded ? state as BoardLoaded : null;

  List<BoardColumnEntity> _mergedColumns() {
    final merged = _columnsMeta
        .map((c) => c.copyWith(tasks: _tasksByColumn[c.id] ?? const []))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return merged;
  }

  void _emitMerged(Emitter<BoardState> emit, {String? actionError}) {
    final loaded = _loaded;
    if (loaded != null) {
      emit(loaded.copyWith(columns: _mergedColumns(), actionError: actionError));
    }
  }

  // ── Board load + realtime subscriptions ──

  Future<void> _onBoardLoadRequested(
    BoardLoadRequested event,
    Emitter<BoardState> emit,
  ) async {
    emit(const BoardLoading());

    final result = await getBoardUseCase(boardId: event.boardId);

    await result.when(
      success: (board) async {
        _columnsMeta = board.columns.map((c) => c.copyWith(tasks: const [])).toList();
        _tasksByColumn = {for (final c in board.columns) c.id: c.tasks};

        emit(
          BoardLoaded(boardId: board.id, boardName: board.name, columns: _mergedColumns()),
        );

        await _subscribeToColumns(board.id);
      },
      error: (failure) async {
        emit(BoardError(message: failure.message, isNetworkError: failure is NetworkFailure));
      },
    );
  }

  Future<void> _subscribeToColumns(String boardId) async {
    await _columnsSubscription?.cancel();
    _columnsSubscription = boardRepo.watchColumns(boardId: boardId).listen((columns) {
      if (isClosed) return;
      add(RealtimeColumnsUpdated(columns));
    });
  }

  Future<void> _subscribeToTasks(List<String> columnIds) async {
    await _tasksSubscription?.cancel();
    if (columnIds.isEmpty) {
      _tasksByColumn = {};
      return;
    }
    _tasksSubscription = boardRepo.watchTasks(columnIds: columnIds).listen((tasks) {
      if (isClosed) return;
      add(RealtimeTasksUpdated(tasks));
    });
  }

  Future<void> _onRealtimeColumnsUpdated(
    RealtimeColumnsUpdated event,
    Emitter<BoardState> emit,
  ) async {
    _columnsMeta = event.columns;

    final newColumnIds = event.columns.map((c) => c.id).toList()..sort();
    if (!_sameIds(newColumnIds, _watchedColumnIds)) {
      _watchedColumnIds = newColumnIds;
      await _subscribeToTasks(newColumnIds);
    }

    _emitMerged(emit);
  }

  Future<void> _onRealtimeTasksUpdated(
    RealtimeTasksUpdated event,
    Emitter<BoardState> emit,
  ) async {
    final grouped = <String, List<TaskEntity>>{};
    for (final task in event.tasks) {
      grouped.putIfAbsent(task.columnId, () => []).add(task);
    }
    for (final tasks in grouped.values) {
      tasks.sort((a, b) => a.position.compareTo(b.position));
    }
    _tasksByColumn = grouped;

    _emitMerged(emit);
  }

  bool _sameIds(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ── Columns ──

  Future<void> _onColumnCreated(ColumnCreated event, Emitter<BoardState> emit) async {
    final loaded = _loaded;
    if (loaded == null) return;

    final previous = List<BoardColumnEntity>.from(_columnsMeta);
    final tempId = '_temp_col_${DateTime.now().microsecondsSinceEpoch}';
    _columnsMeta = [
      ..._columnsMeta,
      BoardColumnEntity(
        id: tempId,
        boardId: loaded.boardId,
        name: event.name.trim(),
        position: _columnsMeta.length,
        createdAt: DateTime.now(),
      ),
    ];
    _emitMerged(emit);

    final result = await createColumnUseCase(
      boardId: loaded.boardId,
      name: event.name,
      position: previous.length,
    );

    String? errorMessage;
    result.when(
      success: (column) {
        _columnsMeta = [for (final c in _columnsMeta) if (c.id == tempId) column else c];
      },
      error: (failure) {
        _columnsMeta = previous;
        errorMessage = failure.message;
      },
    );
    _emitMerged(emit, actionError: errorMessage);
  }

  Future<void> _onColumnRenamed(ColumnRenamed event, Emitter<BoardState> emit) async {
    if (_loaded == null) return;

    final previous = List<BoardColumnEntity>.from(_columnsMeta);
    _columnsMeta = [
      for (final c in _columnsMeta)
        if (c.id == event.columnId) c.copyWith(name: event.name.trim()) else c,
    ];
    _emitMerged(emit);

    final result = await renameColumnUseCase(columnId: event.columnId, name: event.name);

    result.when(
      success: (column) {
        _columnsMeta = [for (final c in _columnsMeta) if (c.id == column.id) column else c];
      },
      error: (_) {
        _columnsMeta = previous;
      },
    );
    _emitMerged(emit);
  }

  Future<void> _onColumnsReordered(ColumnsReordered event, Emitter<BoardState> emit) async {
    if (_loaded == null) return;

    final previous = List<BoardColumnEntity>.from(_columnsMeta);
    _columnsMeta = event.columns
        .asMap()
        .entries
        .map((e) => e.value.copyWith(position: e.key))
        .toList();
    _emitMerged(emit);

    final result = await reorderColumnsUseCase(columns: event.columns);

    result.when(
      success: (_) {},
      error: (_) {
        _columnsMeta = previous;
        _emitMerged(emit);
      },
    );
  }

  Future<void> _onColumnDeleted(ColumnDeleted event, Emitter<BoardState> emit) async {
    if (_loaded == null) return;

    final previousColumns = List<BoardColumnEntity>.from(_columnsMeta);
    final previousTasks = Map<String, List<TaskEntity>>.from(_tasksByColumn);

    _columnsMeta = _columnsMeta.where((c) => c.id != event.columnId).toList();
    _tasksByColumn = Map.of(_tasksByColumn)..remove(event.columnId);
    _emitMerged(emit);

    final result = await deleteColumnUseCase(columnId: event.columnId);

    result.when(
      success: (_) {},
      error: (_) {
        _columnsMeta = previousColumns;
        _tasksByColumn = previousTasks;
        _emitMerged(emit);
      },
    );
  }

  // ── Tasks ──

  Future<void> _onTaskCreated(TaskCreated event, Emitter<BoardState> emit) async {
    if (_loaded == null) return;

    final previous = Map<String, List<TaskEntity>>.from(_tasksByColumn);
    final existing = _tasksByColumn[event.columnId] ?? const [];
    final tempId = '_temp_task_${DateTime.now().microsecondsSinceEpoch}';
    final optimisticTask = TaskEntity(
      id: tempId,
      columnId: event.columnId,
      title: event.title.trim(),
      description: event.description,
      priority: event.priority,
      position: existing.length,
      dueDate: event.dueDate,
      assigneeId: event.assigneeId,
      createdAt: DateTime.now(),
    );
    _tasksByColumn = {..._tasksByColumn, event.columnId: [...existing, optimisticTask]};
    _emitMerged(emit);

    final result = await createTaskUseCase(
      columnId: event.columnId,
      title: event.title,
      description: event.description,
      priority: event.priority,
      position: existing.length,
      dueDate: event.dueDate,
      assigneeId: event.assigneeId,
    );

    String? errorMessage;
    result.when(
      success: (task) {
        final tasks = _tasksByColumn[event.columnId] ?? const [];
        _tasksByColumn = {
          ..._tasksByColumn,
          event.columnId: [for (final t in tasks) if (t.id == tempId) task else t],
        };
      },
      error: (failure) {
        _tasksByColumn = previous;
        errorMessage = failure.message;
      },
    );
    _emitMerged(emit, actionError: errorMessage);
  }

  Future<void> _onTaskUpdated(TaskUpdated event, Emitter<BoardState> emit) async {
    if (_loaded == null) return;

    final previous = Map<String, List<TaskEntity>>.from(_tasksByColumn);
    final ownerColumnId = _tasksByColumn.entries
        .firstWhere(
          (entry) => entry.value.any((t) => t.id == event.taskId),
          orElse: () => const MapEntry('', <TaskEntity>[]),
        )
        .key;
    if (ownerColumnId.isEmpty) return;

    _tasksByColumn = {
      ..._tasksByColumn,
      ownerColumnId: [
        for (final t in _tasksByColumn[ownerColumnId]!)
          if (t.id == event.taskId)
            t.copyWith(
              title: event.title?.trim(),
              description: event.description,
              priority: event.priority,
              dueDate: event.dueDate,
              assigneeId: event.assigneeId,
            )
          else
            t,
      ],
    };
    _emitMerged(emit);

    final result = await updateTaskUseCase(
      taskId: event.taskId,
      title: event.title,
      description: event.description,
      priority: event.priority,
      dueDate: event.dueDate,
      assigneeId: event.assigneeId,
    );

    result.when(
      success: (task) {
        _tasksByColumn = {
          ..._tasksByColumn,
          task.columnId: [
            for (final t in _tasksByColumn[task.columnId] ?? const [])
              if (t.id == task.id) task else t,
          ],
        };
      },
      error: (_) {
        _tasksByColumn = previous;
      },
    );
    _emitMerged(emit);
  }

  Future<void> _onTaskMoved(TaskMoved event, Emitter<BoardState> emit) async {
    if (_loaded == null) return;

    final previous = Map<String, List<TaskEntity>>.from(_tasksByColumn);

    final sourceTasks = List<TaskEntity>.from(_tasksByColumn[event.fromColumnId] ?? const []);
    final movingIndex = sourceTasks.indexWhere((t) => t.id == event.taskId);
    if (movingIndex == -1) return;
    final movingTask = sourceTasks.removeAt(movingIndex);

    final sameColumn = event.fromColumnId == event.targetColumnId;
    final destTasks = sameColumn
        ? sourceTasks
        : List<TaskEntity>.from(_tasksByColumn[event.targetColumnId] ?? const []);

    final insertIndex = event.newPosition.clamp(0, destTasks.length);
    destTasks.insert(insertIndex, movingTask.copyWith(columnId: event.targetColumnId));

    final reindexedDest = [
      for (var i = 0; i < destTasks.length; i++) destTasks[i].copyWith(position: i),
    ];
    final reindexedSource = sameColumn
        ? reindexedDest
        : [for (var i = 0; i < sourceTasks.length; i++) sourceTasks[i].copyWith(position: i)];

    final updatedTasks = Map<String, List<TaskEntity>>.from(_tasksByColumn);
    if (sameColumn) {
      updatedTasks[event.targetColumnId] = reindexedDest;
    } else {
      updatedTasks[event.fromColumnId] = reindexedSource;
      updatedTasks[event.targetColumnId] = reindexedDest;
    }
    _tasksByColumn = updatedTasks;
    _emitMerged(emit);

    final movedEntity = reindexedDest.firstWhere((t) => t.id == event.taskId);
    final moveResult = await moveTaskUseCase(
      taskId: event.taskId,
      targetColumnId: event.targetColumnId,
      newPosition: movedEntity.position,
    );

    if (moveResult.isError) {
      _tasksByColumn = previous;
      _emitMerged(emit);
      return;
    }

    if (!sameColumn) {
      await reorderTasksUseCase(columnId: event.fromColumnId, tasks: reindexedSource);
    }
    await reorderTasksUseCase(columnId: event.targetColumnId, tasks: reindexedDest);
  }

  Future<void> _onTasksReordered(TasksReordered event, Emitter<BoardState> emit) async {
    if (_loaded == null) return;

    final previous = Map<String, List<TaskEntity>>.from(_tasksByColumn);
    final reindexed = [
      for (var i = 0; i < event.tasks.length; i++) event.tasks[i].copyWith(position: i),
    ];
    _tasksByColumn = {..._tasksByColumn, event.columnId: reindexed};
    _emitMerged(emit);

    final result = await reorderTasksUseCase(columnId: event.columnId, tasks: event.tasks);

    result.when(
      success: (_) {},
      error: (_) {
        _tasksByColumn = previous;
        _emitMerged(emit);
      },
    );
  }

  Future<void> _onTaskDeleted(TaskDeleted event, Emitter<BoardState> emit) async {
    if (_loaded == null) return;

    final previous = Map<String, List<TaskEntity>>.from(_tasksByColumn);
    final remaining = (_tasksByColumn[event.columnId] ?? const [])
        .where((t) => t.id != event.taskId)
        .toList();
    _tasksByColumn = {..._tasksByColumn, event.columnId: remaining};
    _emitMerged(emit);

    final result = await deleteTaskUseCase(taskId: event.taskId);

    result.when(
      success: (_) {},
      error: (_) {
        _tasksByColumn = previous;
        _emitMerged(emit);
      },
    );
  }

  @override
  Future<void> close() async {
    await _columnsSubscription?.cancel();
    await _tasksSubscription?.cancel();
    return super.close();
  }
}
