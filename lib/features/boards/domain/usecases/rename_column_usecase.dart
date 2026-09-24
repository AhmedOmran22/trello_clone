import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entity/board_column_entity.dart';
import '../repo/board_repo.dart';

class RenameColumnUseCase {
  final BoardRepo repository;

  const RenameColumnUseCase(this.repository);

  Future<Result<BoardColumnEntity>> call({
    required String columnId,
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return Result.error(const ServerFailure('Column name cannot be empty'));
    }

    return repository.renameColumn(columnId: columnId, name: trimmedName);
  }
}
