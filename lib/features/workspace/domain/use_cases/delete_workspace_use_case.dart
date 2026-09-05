import '../../../../core/utils/result.dart';
import '../repo/workspace_repo.dart';

class DeleteWorkspaceUseCase {
  final WorkspaceRepo repository;

  const DeleteWorkspaceUseCase(this.repository);

  Future<Result<void>> call({required String id}) {
    return repository.deleteWorkspace(id: id);
  }
}
