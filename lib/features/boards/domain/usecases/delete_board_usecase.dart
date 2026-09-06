import '../../../../core/utils/result.dart';
import '../repo/board_repo.dart';

class DeleteBoardUseCase {
  final BoardRepo repository;

  const DeleteBoardUseCase(this.repository);

  Future<Result<void>> call({required String id}) {
    return repository.deleteBoard(id: id);
  }
}
