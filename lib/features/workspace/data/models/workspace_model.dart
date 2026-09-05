import '../../domain/entity/work_space_entity.dart';
import 'workspace_member_model.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String ownerId;
  final String role;
  final DateTime createdAt;
  final List<WorkspaceMemberModel> members;

  const WorkspaceModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.role,
    required this.createdAt,
    this.members = const [],
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    final workspace = json['workspaces'] as Map<String, dynamic>;
    final membersList = workspace['workspace_members'] as List<dynamic>? ?? [];

    return WorkspaceModel(
      id: workspace['id'] as String,
      name: workspace['name'] as String,
      ownerId: workspace['owner_id'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(workspace['created_at'] as String),

      members: membersList
          .map((m) => WorkspaceMemberModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  factory WorkspaceModel.fromWorkspaceJson(Map<String, dynamic> json, String role) {
    return WorkspaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner_id'] as String,
      role: role,
      createdAt: DateTime.parse(json['created_at'] as String),
      members: [],
    );
  }

  WorkspaceEntity toEntity() {
    return WorkspaceEntity(
      id: id,
      name: name,
      ownerId: ownerId,
      role: role,
      createdAt: createdAt,
      members: members.map((m) => m.toEntity()).toList(),
    );
  }
}
