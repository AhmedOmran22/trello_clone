import 'package:equatable/equatable.dart';

import '../../../boards/domain/entity/board_entity.dart';
import 'workspace_member_entity.dart';

class WorkspaceEntity extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final String role;
  final DateTime createdAt;
  final List<WorkspaceMemberEntity> members;
  final List<BoardEntity> boards;

  const WorkspaceEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.role,
    required this.createdAt,
    this.members = const [],
    this.boards = const [],
  });

  bool get isOwner => role == 'owner';

  WorkspaceEntity copyWith({
    String? name,
    List<WorkspaceMemberEntity>? members,
    List<BoardEntity>? boards,
  }) {
    return WorkspaceEntity(
      id: id,
      name: name ?? this.name,
      ownerId: ownerId,
      role: role,
      createdAt: createdAt,
      members: members ?? this.members,
      boards: boards ?? this.boards,
    );
  }

  @override
  List<Object?> get props => [id, name, ownerId, role, createdAt, members, boards];
}