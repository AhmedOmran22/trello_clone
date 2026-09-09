import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entity/task_entity.dart';
import '../repo/board_repo.dart';

class CreateTaskUseCase {
  final BoardRepo repository;

  const CreateTaskUseCase(this.repository);

  static const _validPriorities = {'low', 'medium', 'high', 'urgent'};

  Future<Result<TaskEntity>> call({
    required String columnId,
    required String title,
    String? description,
    required String priority,
    required int position,
    DateTime? dueDate,
    String? assigneeId,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return Result.error(const ServerFailure('Task title cannot be empty'));
    }

    final trimmedDescription = description?.trim();
    final normalizedDescription =
        (trimmedDescription == null || trimmedDescription.isEmpty) ? null : trimmedDescription;

    if (!_validPriorities.contains(priority)) {
      return Result.error(const ServerFailure('Invalid priority value'));
    }

    return repository.createTask(
      columnId: columnId,
      title: trimmedTitle,
      description: normalizedDescription,
      priority: priority,
      position: position,
      dueDate: dueDate,
      assigneeId: assigneeId,
    );
  }
}
