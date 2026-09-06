import 'package:equatable/equatable.dart';

import 'task_entity.dart';

class BoardColumnEntity extends Equatable {
  final String id;
  final String boardId;
  final String name;
  final int position;
  final DateTime createdAt;
  final List<TaskEntity> tasks;

  const BoardColumnEntity({
    required this.id,
    required this.boardId,
    required this.name,
    required this.position,
    required this.createdAt,
    this.tasks = const [],
  });

  @override
  List<Object?> get props => [id, boardId, name, position, createdAt, tasks];
}
