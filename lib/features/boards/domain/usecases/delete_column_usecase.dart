import '../../../../core/utils/result.dart';
import '../repo/board_repo.dart';

class DeleteColumnUseCase {
  final BoardRepo repository;

  const DeleteColumnUseCase(this.repository);

  Future<Result<void>> call({required String columnId}) {
    return repository.deleteColumn(columnId: columnId);
  }
}
