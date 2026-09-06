import '../../../../core/utils/result.dart';
import '../entity/board_entity.dart';
import '../repo/board_repo.dart';

class CreateBoardUseCase {
  final BoardRepo repository;

  const CreateBoardUseCase(this.repository);

  Future<Result<BoardEntity>> call({
    required String workspaceId,
    required String name,
  }) {
    return repository.createBoard(workspaceId: workspaceId, name: name);
  }
}
