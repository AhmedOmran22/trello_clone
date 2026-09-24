import '../models/workspace_member_model.dart';
import '../models/workspace_model.dart';

abstract class WorkspaceRemoteDatasource {
  Future<List<WorkspaceModel>> getWorkspaces();

  Future<WorkspaceModel> createWorkspace({
    required String name,
    required String userId,
  });

  Future<WorkspaceModel> updateWorkspace({required String id, required String name});

  Future<void> deleteWorkspace({required String id});

  Future<WorkspaceMemberModel> addMember({
    required String workspaceId,
    required String email,
  });

  Future<void> removeMember({required String workspaceId, required String userId});
}
