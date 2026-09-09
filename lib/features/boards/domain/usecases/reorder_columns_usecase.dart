import '../../../../core/utils/result.dart';
import '../entity/board_column_entity.dart';
import '../repo/board_repo.dart';

class ReorderColumnsUseCase {
  final BoardRepo repository;

  const ReorderColumnsUseCase(this.repository);

  Future<Result<void>> call({required List<BoardColumnEntity> columns}) {
    final reindexed = columns
        .asMap()
        .entries
        .map((e) => e.value.copyWith(position: e.key))
        .toList();

    return repository.reorderColumns(columns: reindexed);
  }
}
