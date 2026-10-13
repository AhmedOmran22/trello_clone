import '../../../../core/utils/result.dart';
import '../entity/workspace_member_entity.dart';
import '../repo/workspace_repo.dart';

class GetWorkspaceMembersUseCase {
  final WorkspaceRepo repository;

  const GetWorkspaceMembersUseCase(this.repository);

  Future<Result<List<WorkspaceMemberEntity>>> call({required String workspaceId}) {
    return repository.getMembers(workspaceId: workspaceId);
  }
}
