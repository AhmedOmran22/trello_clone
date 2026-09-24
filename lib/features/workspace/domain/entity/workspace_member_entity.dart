import 'package:equatable/equatable.dart';

class WorkspaceMemberEntity extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;

  const WorkspaceMemberEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  bool get isOwner => role == 'owner';

  @override
  List<Object?> get props => [id, userId, fullName, email, role, avatarUrl];
}