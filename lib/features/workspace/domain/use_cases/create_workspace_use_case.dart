import '../../../../core/utils/result.dart';
import '../entity/work_space_entity.dart';
import '../repo/workspace_repo.dart';

class CreateWorkspaceUseCase {
  final WorkspaceRepo repository;

  const CreateWorkspaceUseCase(this.repository);

  Future<Result<WorkspaceEntity>> call({
    required String name,
    required String userId,
  }) {
    return repository.createWorkspace(name: name, userId: userId);
  }
}
