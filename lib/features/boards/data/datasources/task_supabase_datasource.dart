import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/subabase_services.dart';
import '../models/task_model.dart';
import 'task_remote_datasource.dart';

class TaskSupabaseDatasource implements TaskRemoteDatasource {
  final SupabaseServices services;

  TaskSupabaseDatasource(this.services);

  @override
  Future<TaskModel> createTask({
    required String columnId,
    required String title,
    String? description,
    required String priority,
    required int position,
    DateTime? dueDate,
    String? assigneeId,
  }) async {
    try {
      final data = <String, dynamic>{
        'column_id': columnId,
        'title': title,
        'description': description,
        'priority': priority,
        'position': position,
        'due_date': dueDate?.toIso8601String(),
        'assignee_id': assigneeId,
      }..removeWhere((key, value) => value == null);

      final response = await services.insert(SupabaseTables.tasks, data);

      if (assigneeId != null) {
        final withAssignee = await services.client
            .from(SupabaseTables.tasks)
            .select('*, profiles(full_name, avatar_url)')
            .eq('id', response['id'] as String)
            .single();

        return TaskModel.fromJson(withAssignee);
      }

      return TaskModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? assigneeId,
    bool clearAssignee = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': ?title,
        'description': ?description,
        'priority': ?priority,
        'due_date': ?dueDate?.toIso8601String(),
        // A plain null assigneeId means "leave as is" (below), so clearing
        // the column needs its own explicit path.
        if (clearAssignee) 'assignee_id': null else 'assignee_id': ?assigneeId,
      };

      await services.update(SupabaseTables.tasks, taskId, data);

      final response = await services.client
          .from(SupabaseTables.tasks)
          .select('*, profiles(full_name, avatar_url)')
          .eq('id', taskId)
          .single();

      return TaskModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<void> moveTask({
    required String taskId,
    required String targetColumnId,
    required int newPosition,
  }) async {
    try {
      await services.update(SupabaseTables.tasks, taskId, {
        'column_id': targetColumnId,
        'position': newPosition,
      });
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<void> reorderTasks({required List<Map<String, dynamic>> tasks}) async {
    try {
      for (final task in tasks) {
        await services.update(SupabaseTables.tasks, task['id'] as String, {
          'position': task['position'],
        });
      }
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<void> deleteTask({required String taskId}) async {
    try {
      await services.delete(SupabaseTables.tasks, taskId);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  // ── Real-time Streams ──

  @override
  Stream<List<TaskModel>> watchTasks({required List<String> columnIds}) {
    return services.client
        .from(SupabaseTables.tasks)
        .stream(primaryKey: ['id'])
        .inFilter('column_id', columnIds)
        .map(
          (data) =>
              data.map((json) => TaskModel.fromJson(json)).toList()
                ..sort((a, b) => a.position.compareTo(b.position)),
        );
  }
}
