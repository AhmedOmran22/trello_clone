import '../../../../core/utils/result.dart';
import '../entity/workspace_entity.dart';
import '../repo/workspace_repo.dart';

class GetWorkspacesUseCase {
  final WorkspaceRepo repository;

  const GetWorkspacesUseCase(this.repository);

  Future<Result<List<WorkspaceEntity>>> call() {
    return repository.getWorkspaces();
  }
}
