import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/subabase_services.dart';
import '../models/board_column_model.dart';
import '../models/board_model.dart';
import '../models/task_model.dart';
import 'board_remote_datasource.dart';

class BoardSupabaseDatasource implements BoardRemoteDatasource {
  final SupabaseServices services;

  BoardSupabaseDatasource(this.services);

  @override
  Future<BoardModel> createBoard({
    required String workspaceId,
    required String name,
  }) async {
    try {
      final response = await services.insert(SupabaseTables.boards, {
        'workspace_id': workspaceId,
        'name': name,
      });

      return BoardModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<BoardModel> updateBoard({required String id, required String name}) async {
    try {
      final response = await services.update(SupabaseTables.boards, id, {
        'name': name,
      });

      return BoardModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<void> deleteBoard({required String id}) async {
    try {
      await services.delete(SupabaseTables.boards, id);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  // ── Board Fetching ──

  @override
  Future<BoardModel> getBoard({required String boardId}) async {
    try {
      final response = await services.client
          .from(SupabaseTables.boards)
          .select(
            '*, board_columns(*, tasks(*, profiles(full_name, email, avatar_url)))',
          )
          .eq('id', boardId)
          .single();

      return BoardModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  // ── Columns ──

  @override
  Future<BoardColumnModel> createColumn({
    required String boardId,
    required String name,
    required int position,
  }) async {
    try {
      final response = await services.insert(SupabaseTables.boardColumns, {
        'board_id': boardId,
        'name': name,
        'position': position,
      });

      return BoardColumnModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<BoardColumnModel> renameColumn({
    required String columnId,
    required String name,
  }) async {
    try {
      final response = await services.update(SupabaseTables.boardColumns, columnId, {
        'name': name,
      });

      return BoardColumnModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<void> reorderColumns({required List<Map<String, dynamic>> columns}) async {
    try {
      for (final column in columns) {
        await services.update(SupabaseTables.boardColumns, column['id'] as String, {
          'position': column['position'],
        });
      }
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<void> deleteColumn({required String columnId}) async {
    try {
      await services.delete(SupabaseTables.boardColumns, columnId);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  // ── Tasks ──

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
  }) async {
    try {
      final data = <String, dynamic>{
        'title': ?title,
        'description': ?description,
        'priority': ?priority,
        'due_date': ?dueDate?.toIso8601String(),
        'assignee_id': ?assigneeId,
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
  Stream<List<BoardColumnModel>> watchColumns({required String boardId}) {
    return services.client
        .from(SupabaseTables.boardColumns)
        .stream(primaryKey: ['id'])
        .eq('board_id', boardId)
        .map(
          (data) =>
              data.map((json) => BoardColumnModel.fromJson(json)).toList()
                ..sort((a, b) => a.position.compareTo(b.position)),
        );
  }

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
