import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  bool get isTaskAssigned => type == 'task_assigned';
  bool get isTaskMoved => type == 'task_moved';
  bool get isMemberAdded => type == 'member_added';

  @override
  List<Object?> get props => [id, userId, type, title, body, data, isRead, createdAt];
}