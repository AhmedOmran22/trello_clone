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