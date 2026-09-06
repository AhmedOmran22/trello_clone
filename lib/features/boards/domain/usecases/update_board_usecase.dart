import '../../../../core/utils/result.dart';
import '../entity/board_entity.dart';
import '../repo/board_repo.dart';

class UpdateBoardUseCase {
  final BoardRepo repository;

  const UpdateBoardUseCase(this.repository);

  Future<Result<BoardEntity>> call({required String id, required String name}) {
    return repository.updateBoard(id: id, name: name);
  }
}
