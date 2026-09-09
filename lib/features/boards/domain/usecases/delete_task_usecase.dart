import '../../../../core/utils/result.dart';
import '../repo/board_repo.dart';

class DeleteTaskUseCase {
  final BoardRepo repository;

  const DeleteTaskUseCase(this.repository);

  Future<Result<void>> call({required String taskId}) {
    return repository.deleteTask(taskId: taskId);
  }
}
