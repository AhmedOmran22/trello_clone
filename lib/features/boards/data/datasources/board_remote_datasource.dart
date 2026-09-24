import '../models/board_column_model.dart';
import '../models/board_model.dart';
import '../models/task_model.dart';

abstract class BoardRemoteDatasource {
  Future<BoardModel> createBoard({required String workspaceId, required String name});

  Future<BoardModel> updateBoard({required String id, required String name});

  Future<void> deleteBoard({required String id});

  // ── Board Fetching ──
  Future<BoardModel> getBoard({required String boardId});

  // ── Columns ──
  Future<BoardColumnModel> createColumn({
    required String boardId,
    required String name,
    required int position,
  });

  Future<BoardColumnModel> renameColumn({required String columnId, required String name});

  Future<void> reorderColumns({required List<Map<String, dynamic>> columns});

  Future<void> deleteColumn({required String columnId});

  // ── Tasks ──
  Future<TaskModel> createTask({
    required String columnId,
    required String title,
    String? description,
    required String priority,
    required int position,
    DateTime? dueDate,
    String? assigneeId,
  });

  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? assigneeId,
  });

  Future<void> moveTask({
    required String taskId,
    required String targetColumnId,
    required int newPosition,
  });

  Future<void> reorderTasks({required List<Map<String, dynamic>> tasks});

  Future<void> deleteTask({required String taskId});

  // ── Real-time Streams ──
  Stream<List<BoardColumnModel>> watchColumns({required String boardId});

  Stream<List<TaskModel>> watchTasks({required List<String> columnIds});
}
