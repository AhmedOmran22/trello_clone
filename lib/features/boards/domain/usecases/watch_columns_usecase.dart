import '../entity/board_column_entity.dart';
import '../repo/board_repo.dart';

class WatchColumnsUseCase {
  final BoardRepo repository;

  const WatchColumnsUseCase(this.repository);

  Stream<List<BoardColumnEntity>> call({required String boardId}) {
    return repository.watchColumns(boardId: boardId);
  }
}
