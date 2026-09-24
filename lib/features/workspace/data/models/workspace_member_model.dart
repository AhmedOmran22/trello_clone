import '../../domain/entity/workspace_member_entity.dart';

class WorkspaceMemberModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;

  const WorkspaceMemberModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>;
    return WorkspaceMemberModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: profile['full_name'] as String,
      email: profile['email'] as String,
      role: json['role'] as String,
      avatarUrl: profile['avatar_url'] as String?,
    );
  }

  WorkspaceMemberEntity toEntity() {
    return WorkspaceMemberEntity(
      id: id,
      userId: userId,
      fullName: fullName,
      email: email,
      role: role,
      avatarUrl: avatarUrl,
    );
  }
}