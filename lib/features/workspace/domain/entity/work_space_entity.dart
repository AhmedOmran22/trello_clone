import 'package:equatable/equatable.dart';

class WorkspaceEntity extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final String role;
  final DateTime createdAt;

  const WorkspaceEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.role,
    required this.createdAt,
  });

  bool get isOwner => role == 'owner';

  @override
  List<Object?> get props => [id, name, ownerId, role, createdAt];
}
