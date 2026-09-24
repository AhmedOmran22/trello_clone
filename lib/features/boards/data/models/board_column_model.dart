import 'task_model.dart';
import '../../domain/entity/board_column_entity.dart';

class BoardColumnModel {
  final String id;
  final String boardId;
  final String name;
  final int position;
  final DateTime createdAt;
  final List<TaskModel> tasks;

  const BoardColumnModel({
    required this.id,
    required this.boardId,
    required this.name,
    required this.position,
    required this.createdAt,
    this.tasks = const [],
  });

  factory BoardColumnModel.fromJson(Map<String, dynamic> json) {
    final tasksList = json['tasks'] as List<dynamic>? ?? [];

    return BoardColumnModel(
      id: json['id'] as String,
      boardId: json['board_id'] as String,
      name: json['name'] as String,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      tasks: tasksList
          .map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board_id': boardId,
      'name': name,
      'position': position,
    };
  }

  BoardColumnEntity toEntity() {
    return BoardColumnEntity(
      id: id,
      boardId: boardId,
      name: name,
      position: position,
      createdAt: createdAt,
      tasks: tasks.map((t) => t.toEntity()).toList(),
    );
  }
}