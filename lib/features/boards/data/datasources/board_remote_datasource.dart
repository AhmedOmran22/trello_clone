import '../../../workspace/data/models/workspace_member_model.dart';
import '../models/board_model.dart';

abstract class BoardRemoteDatasource {
  Future<BoardModel> createBoard({required String workspaceId, required String name});

  Future<BoardModel> updateBoard({required String id, required String name});

  Future<void> deleteBoard({required String id});

  // ── Board Fetching ──
  Future<BoardModel> getBoard({required String boardId});

  // ── Workspace Members (for task assignment) ──
  Future<List<WorkspaceMemberModel>> getWorkspaceMembers({required String workspaceId});
}
