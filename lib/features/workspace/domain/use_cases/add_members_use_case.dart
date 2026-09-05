import '../../../../core/utils/result.dart';
import '../repo/workspace_repo.dart';

class AddMemberUseCase {
  final WorkspaceRepo repository;

  const AddMemberUseCase(this.repository);

  Future<Result<void>> call({
    required String workspaceId,
    required String email,
  }) {
    return repository.addMember(
      workspaceId: workspaceId,
      email: email,
    );
  }
}