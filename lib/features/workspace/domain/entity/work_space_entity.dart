import 'workspace_member_entity.dart';

class WorkspaceEntity {
  final String id;
  final String name;
  final String ownerId;
  final String role;
  final DateTime createdAt;
  List<WorkspaceMemberEntity> members;

  WorkspaceEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.role,
    required this.createdAt,
    this.members = const [],
  });

  bool get isOwner => role == 'owner';
}
