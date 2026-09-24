import '../../../../core/utils/result.dart';
import '../entity/board_column_entity.dart';
import '../entity/board_entity.dart';
import '../entity/task_entity.dart';

abstract class BoardRepo {
  Future<Result<BoardEntity>> createBoard({
    required String workspaceId,
    required String name,
  });

  Future<Result<BoardEntity>> updateBoard({required String id, required String name});

  Future<Result<void>> deleteBoard({required String id});

  // ── Board Fetching ──
  Future<Result<BoardEntity>> getBoard({required String boardId});

  // ── Columns ──
  Future<Result<BoardColumnEntity>> createColumn({
    required String boardId,
    required String name,
    required int position,
  });

  Future<Result<BoardColumnEntity>> renameColumn({
    required String columnId,
    required String name,
  });

  Future<Result<void>> reorderColumns({required List<BoardColumnEntity> columns});

  Future<Result<void>> deleteColumn({required String columnId});

  // ── Tasks ──
  Future<Result<TaskEntity>> createTask({
    required String columnId,
    required String title,
    String? description,
    required String priority,
    required int position,
    DateTime? dueDate,
    String? assigneeId,
  });

  Future<Result<TaskEntity>> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? assigneeId,
  });

  Future<Result<void>> moveTask({
    required String taskId,
    required String targetColumnId,
    required int newPosition,
  });

  Future<Result<void>> reorderTasks({
    required String columnId,
    required List<TaskEntity> tasks,
  });

  Future<Result<void>> deleteTask({required String taskId});

  // ── Real-time Streams ──
  Stream<List<BoardColumnEntity>> watchColumns({required String boardId});

  Stream<List<TaskEntity>> watchTasks({required List<String> columnIds});
}
