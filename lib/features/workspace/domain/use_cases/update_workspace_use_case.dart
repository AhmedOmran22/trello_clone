import '../../../../core/utils/result.dart';
import '../entity/workspace_entity.dart';
import '../repo/workspace_repo.dart';

class UpdateWorkspaceUseCase {
  final WorkspaceRepo repository;

  const UpdateWorkspaceUseCase(this.repository);

  Future<Result<WorkspaceEntity>> call({required String id, required String name}) {
    return repository.updateWorkspace(id: id, name: name);
  }
}
