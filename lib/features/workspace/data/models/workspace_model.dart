import '../../domain/entity/work_space_entity.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String ownerId;
  final String role;
  final DateTime createdAt;

  const WorkspaceModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.role,
    required this.createdAt,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['workspaces']['id'] as String,
      name: json['workspaces']['name'] as String,
      ownerId: json['workspaces']['owner_id'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['workspaces']['created_at'] as String),
    );
  }

  factory WorkspaceModel.fromWorkspaceJson(Map<String, dynamic> json, String role) {
    return WorkspaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner_id'] as String,
      role: role,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'owner_id': ownerId};
  }

  WorkspaceEntity toEntity() {
    return WorkspaceEntity(
      id: id,
      name: name,
      ownerId: ownerId,
      role: role,
      createdAt: createdAt,
    );
  }
}
