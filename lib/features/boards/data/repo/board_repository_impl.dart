import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/board_column_entity.dart';
import '../../domain/entity/board_entity.dart';
import '../../domain/entity/task_entity.dart';
import '../../domain/repo/board_repo.dart';
import '../datasources/board_remote_datasource.dart';

class BoardRepositoryImpl implements BoardRepo {
  final BoardRemoteDatasource datasource;

  BoardRepositoryImpl(this.datasource);

  @override
  Future<Result<BoardEntity>> createBoard({
    required String workspaceId,
    required String name,
  }) async {
    try {
      final model = await datasource.createBoard(workspaceId: workspaceId, name: name);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<BoardEntity>> updateBoard({
    required String id,
    required String name,
  }) async {
    try {
      final model = await datasource.updateBoard(id: id, name: name);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteBoard({required String id}) async {
    try {
      await datasource.deleteBoard(id: id);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  // ── Board Fetching ──

  @override
  Future<Result<BoardEntity>> getBoard({required String boardId}) async {
    try {
      final model = await datasource.getBoard(boardId: boardId);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
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
      final model = await datasource.createColumn(
        boardId: boardId,
        name: name,
        position: position,
      );
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<BoardColumnEntity>> renameColumn({
    required String columnId,
    required String name,
  }) async {
    try {
      final model = await datasource.renameColumn(columnId: columnId, name: name);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> reorderColumns({required List<BoardColumnEntity> columns}) async {
    try {
      await datasource.reorderColumns(
        columns: columns.map((c) => {'id': c.id, 'position': c.position}).toList(),
      );
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteColumn({required String columnId}) async {
    try {
      await datasource.deleteColumn(columnId: columnId);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
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
      final model = await datasource.createTask(
        columnId: columnId,
        title: title,
        description: description,
        priority: priority,
        position: position,
        dueDate: dueDate,
        assigneeId: assigneeId,
      );
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
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
  }) async {
    try {
      final model = await datasource.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        assigneeId: assigneeId,
      );
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> moveTask({
    required String taskId,
    required String targetColumnId,
    required int newPosition,
  }) async {
    try {
      await datasource.moveTask(
        taskId: taskId,
        targetColumnId: targetColumnId,
        newPosition: newPosition,
      );
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> reorderTasks({
    required String columnId,
    required List<TaskEntity> tasks,
  }) async {
    try {
      await datasource.reorderTasks(
        tasks: tasks.map((t) => {'id': t.id, 'position': t.position}).toList(),
      );
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteTask({required String taskId}) async {
    try {
      await datasource.deleteTask(taskId: taskId);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  // ── Real-time Streams ──

  @override
  Stream<List<BoardColumnEntity>> watchColumns({required String boardId}) {
    return datasource
        .watchColumns(boardId: boardId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<TaskEntity>> watchTasks({required List<String> columnIds}) {
    return datasource
        .watchTasks(columnIds: columnIds)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}
