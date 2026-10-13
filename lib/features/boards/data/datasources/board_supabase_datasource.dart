import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/subabase_services.dart';
import '../../../workspace/data/models/workspace_member_model.dart';
import '../models/board_model.dart';
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

  // ── Workspace Members (for task assignment) ──

  @override
  Future<List<WorkspaceMemberModel>> getWorkspaceMembers({
    required String workspaceId,
  }) async {
    try {
      final response = await services.client
          .from(SupabaseTables.workspaceMembers)
          .select('id, user_id, role, profiles(full_name, email, avatar_url)')
          .eq('workspace_id', workspaceId);

      return response.map((json) => WorkspaceMemberModel.fromJson(json)).toList();
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }
}
