import '../../../../core/utils/result.dart';
import '../entity/board_entity.dart';
import '../repo/board_repo.dart';

class GetBoardUseCase {
  final BoardRepo repository;

  const GetBoardUseCase(this.repository);

  Future<Result<BoardEntity>> call({required String boardId}) {
    return repository.getBoard(boardId: boardId);
  }
}
