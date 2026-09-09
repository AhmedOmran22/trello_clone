import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entity/task_entity.dart';
import '../repo/board_repo.dart';

class UpdateTaskUseCase {
  final BoardRepo repository;

  const UpdateTaskUseCase(this.repository);

  static const _validPriorities = {'low', 'medium', 'high', 'urgent'};

  Future<Result<TaskEntity>> call({
    required String taskId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    String? assigneeId,
  }) async {
    var trimmedTitle = title;
    if (title != null) {
      trimmedTitle = title.trim();
      if (trimmedTitle.isEmpty) {
        return Result.error(const ServerFailure('Task title cannot be empty'));
      }
    }

    var normalizedDescription = description;
    if (description != null) {
      final trimmed = description.trim();
      normalizedDescription = trimmed.isEmpty ? null : trimmed;
    }

    if (priority != null && !_validPriorities.contains(priority)) {
      return Result.error(const ServerFailure('Invalid priority value'));
    }

    return repository.updateTask(
      taskId: taskId,
      title: trimmedTitle,
      description: normalizedDescription,
      priority: priority,
      dueDate: dueDate,
      assigneeId: assigneeId,
    );
  }
}
