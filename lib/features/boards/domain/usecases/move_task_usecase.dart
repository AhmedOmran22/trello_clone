import '../../../../core/utils/result.dart';
import '../repo/board_repo.dart';

class MoveTaskUseCase {
  final BoardRepo repository;

  const MoveTaskUseCase(this.repository);

  Future<Result<void>> call({
    required String taskId,
    required String targetColumnId,
    required int newPosition,
  }) {
    return repository.moveTask(
      taskId: taskId,
      targetColumnId: targetColumnId,
      newPosition: newPosition,
    );
  }
}
