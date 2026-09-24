import '../../../../core/utils/result.dart';
import '../entity/workspace_member_entity.dart';
import '../repo/workspace_repo.dart';

class AddMemberUseCase {
  final WorkspaceRepo repository;

  const AddMemberUseCase(this.repository);

  Future<Result<WorkspaceMemberEntity>> call({
    required String workspaceId,
    required String email,
  }) {
    return repository.addMember(
      workspaceId: workspaceId,
      email: email,
    );
  }
}