import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../workspace/domain/entity/workspace_member_entity.dart';
import '../../domain/entity/board_column_entity.dart';
import '../../domain/entity/board_entity.dart';
import '../../domain/entity/task_entity.dart';
import '../../domain/repo/board_repo.dart';
import '../datasources/board_remote_datasource.dart';
import '../datasources/column_remote_datasource.dart';
import '../datasources/task_remote_datasource.dart';

class BoardRepositoryImpl implements BoardRepo {
  final BoardRemoteDatasource boardDatasource;
  final ColumnRemoteDatasource columnDatasource;
  final TaskRemoteDatasource taskDatasource;

  BoardRepositoryImpl({
    required this.boardDatasource,
    required this.columnDatasource,
    required this.taskDatasource,
  });

  @override
  Future<Result<BoardEntity>> createBoard({
    required String workspaceId,
    required String name,
  }) async {
    try {
      final model = await boardDatasource.createBoard(workspaceId: workspaceId, name: name);
      return Result.success(model.toEntity());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<BoardEntity>> updateBoard({
    required String id,
    required String name,
  }) async {
    try {
      final model = await boardDatasource.updateBoard(id: id, name: name);
      return Result.success(model.toEntity());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> deleteBoard({required String id}) async {
    try {
      await boardDatasource.deleteBoard(id: id);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  // ── Board Fetching ──

  @override
  Future<Result<BoardEntity>> getBoard({required String boardId}) async {
    try {
      final model = await boardDatasource.getBoard(boardId: boardId);
      return Result.success(model.toEntity());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  // ── Columns ──

  @override
  Future<Result<BoardColumnEntity>> createColumn({
    required String boardId,
    required String name,
    required int position,
  }) async {
    try {
      final model = await columnDatasource.createColumn(
        boardId: boardId,
        name: name,
        position: position,
      );
      return Result.success(model.toEntity());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<BoardColumnEntity>> renameColumn({
    required String columnId,
    required String name,
  }) async {
    try {
      final model = await columnDatasource.renameColumn(columnId: columnId, name: name);
      return Result.success(model.toEntity());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> reorderColumns({required List<BoardColumnEntity> columns}) async {
    try {
      await columnDatasource.reorderColumns(
        columns: columns.map((c) => {'id': c.id, 'position': c.position}).toList(),
      );
      return Result.success(null);
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> deleteColumn({required String columnId}) async {
    try {
      await columnDatasource.deleteColumn(columnId: columnId);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  // ── Tasks ──

  @override
  Future<Result<TaskEntity>> createTask({
    required String columnId,
    required String title,
    String? description,
    required String priority,
    required int position,
    DateTime? dueDate,
    String? assigneeId,
  }) async {
    try {
      final model = await taskDatasource.createTask(
        columnId: columnId,
        title: title,
        description: description,
        priority: priority,
        position: position,
        dueDate: dueDate,
        assigneeId: assigneeId,
      );
      return Result.success(model.toEntity());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<TaskEntity>> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? assigneeId,
    bool clearAssignee = false,
  }) async {
    try {
      final model = await taskDatasource.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        assigneeId: assigneeId,
        clearAssignee: clearAssignee,
      );
      return Result.success(model.toEntity());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> moveTask({
    required String taskId,
    required String targetColumnId,
    required int newPosition,
  }) async {
    try {
      await taskDatasource.moveTask(
        taskId: taskId,
        targetColumnId: targetColumnId,
        newPosition: newPosition,
      );
      return Result.success(null);
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> reorderTasks({
    required String columnId,
    required List<TaskEntity> tasks,
  }) async {
    try {
      await taskDatasource.reorderTasks(
        tasks: tasks.map((t) => {'id': t.id, 'position': t.position}).toList(),
      );
      return Result.success(null);
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> deleteTask({required String taskId}) async {
    try {
      await taskDatasource.deleteTask(taskId: taskId);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }

  // ── Real-time Streams ──

  @override
  Stream<List<BoardColumnEntity>> watchColumns({required String boardId}) {
    return columnDatasource
        .watchColumns(boardId: boardId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<TaskEntity>> watchTasks({required List<String> columnIds}) {
    return taskDatasource
        .watchTasks(columnIds: columnIds)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  // ── Workspace Members (for task assignment) ──

  @override
  Future<Result<List<WorkspaceMemberEntity>>> getWorkspaceMembers({
    required String workspaceId,
  }) async {
    try {
      final models = await boardDatasource.getWorkspaceMembers(workspaceId: workspaceId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }
}
