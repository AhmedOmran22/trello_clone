import '../../../../core/utils/result.dart';
import '../entity/workspace_entity.dart';
import '../entity/workspace_member_entity.dart';

abstract class WorkspaceRepo {
  Future<Result<List<WorkspaceEntity>>> getWorkspaces();

  Future<Result<WorkspaceEntity>> createWorkspace({required String name , required String userId});

  Future<Result<WorkspaceEntity>> updateWorkspace({
    required String id,
    required String name,
  });

  Future<Result<void>> deleteWorkspace({required String id});

  Future<Result<WorkspaceMemberEntity>> addMember({
    required String workspaceId,
    required String email,
  });

  Future<Result<void>> removeMember({
    required String workspaceId,
    required String userId,
  });
}
