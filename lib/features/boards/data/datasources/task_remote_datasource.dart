import '../models/task_model.dart';

abstract class TaskRemoteDatasource {
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
    bool clearAssignee = false,
  });

  Future<void> moveTask({
    required String taskId,
    required String targetColumnId,
    required int newPosition,
  });

  Future<void> reorderTasks({required List<Map<String, dynamic>> tasks});

  Future<void> deleteTask({required String taskId});

  // ── Real-time Streams ──
  Stream<List<TaskModel>> watchTasks({required List<String> columnIds});
}
