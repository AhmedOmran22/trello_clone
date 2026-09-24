import '../../domain/entity/task_entity.dart';

class TaskModel {
  final String id;
  final String columnId;
  final String title;
  final String? description;
  final String priority;
  final int position;
  final DateTime? dueDate;
  final String? assigneeId;
  final String? assigneeName;
  final String? assigneeAvatarUrl;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.columnId,
    required this.title,
    this.description,
    required this.priority,
    required this.position,
    this.dueDate,
    this.assigneeId,
    this.assigneeName,
    this.assigneeAvatarUrl,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final assignee = json['profiles'] as Map<String, dynamic>?;

    return TaskModel(
      id: json['id'] as String,
      columnId: json['column_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: json['priority'] as String,
      position: json['position'] as int,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      assigneeId: json['assignee_id'] as String?,
      assigneeName: assignee?['full_name'] as String?,
      assigneeAvatarUrl: assignee?['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'column_id': columnId,
      'title': title,
      'description': description,
      'priority': priority,
      'position': position,
      'due_date': dueDate?.toIso8601String(),
      'assignee_id': assigneeId,
    };
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      columnId: columnId,
      title: title,
      description: description,
      priority: priority,
      position: position,
      dueDate: dueDate,
      assigneeId: assigneeId,
      assigneeName: assigneeName,
      assigneeAvatarUrl: assigneeAvatarUrl,
      createdAt: createdAt,
    );
  }
}