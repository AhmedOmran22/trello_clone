import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entity/board_column_entity.dart';
import '../repo/board_repo.dart';

class CreateColumnUseCase {
  final BoardRepo repository;

  const CreateColumnUseCase(this.repository);

  Future<Result<BoardColumnEntity>> call({
    required String boardId,
    required String name,
    required int position,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return Result.error(const ServerFailure('Column name cannot be empty'));
    }

    return repository.createColumn(boardId: boardId, name: trimmedName, position: position);
  }
}
