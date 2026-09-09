import '../../../../core/utils/result.dart';
import '../entity/task_entity.dart';
import '../repo/board_repo.dart';

class ReorderTasksUseCase {
  final BoardRepo repository;

  const ReorderTasksUseCase(this.repository);

  Future<Result<void>> call({required String columnId, required List<TaskEntity> tasks}) {
    final reindexed = tasks
        .asMap()
        .entries
        .map((e) => e.value.copyWith(position: e.key))
        .toList();

    return repository.reorderTasks(columnId: columnId, tasks: reindexed);
  }
}
