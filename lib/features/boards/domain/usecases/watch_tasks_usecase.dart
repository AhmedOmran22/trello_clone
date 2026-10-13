import '../entity/task_entity.dart';
import '../repo/board_repo.dart';

class WatchTasksUseCase {
  final BoardRepo repository;

  const WatchTasksUseCase(this.repository);

  Stream<List<TaskEntity>> call({required List<String> columnIds}) {
    return repository.watchTasks(columnIds: columnIds);
  }
}
