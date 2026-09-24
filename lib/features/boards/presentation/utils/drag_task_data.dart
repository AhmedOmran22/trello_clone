import '../../domain/entity/task_entity.dart';

class DragTaskData {
  const DragTaskData({required this.task, required this.sourceColumnId});

  final TaskEntity task;
  final String sourceColumnId;
}
