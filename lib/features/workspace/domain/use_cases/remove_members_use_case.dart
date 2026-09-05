import '../../../../core/utils/result.dart';
import '../repo/workspace_repo.dart';

class RemoveMemberUseCase {
  final WorkspaceRepo repository;

  const RemoveMemberUseCase(this.repository);

  Future<Result<void>> call({required String workspaceId, required String userId}) {
    return repository.removeMember(workspaceId: workspaceId, userId: userId);
  }
}
