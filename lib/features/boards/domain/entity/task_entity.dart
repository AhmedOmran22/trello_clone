import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
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

  const TaskEntity({
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

  TaskEntity copyWith({
    String? id,
    String? columnId,
    String? title,
    String? description,
    String? priority,
    int? position,
    DateTime? dueDate,
    String? assigneeId,
    String? assigneeName,
    String? assigneeAvatarUrl,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      columnId: columnId ?? this.columnId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      position: position ?? this.position,
      dueDate: dueDate ?? this.dueDate,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeAvatarUrl: assigneeAvatarUrl ?? this.assigneeAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now());

  bool get isAssigned => assigneeId != null;

  bool get isUrgent => priority == 'urgent';
  bool get isHigh => priority == 'high';

  @override
  List<Object?> get props => [
        id,
        columnId,
        title,
        description,
        priority,
        position,
        dueDate,
        assigneeId,
        assigneeName,
        assigneeAvatarUrl,
        createdAt,
      ];
}