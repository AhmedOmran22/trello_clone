import 'package:equatable/equatable.dart';

import '../../../auth/domain/entity/user_entity.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserEntity? user;
  final String? error;

  /// Tracked apart from [status] so a name edit and an avatar upload can run
  /// without one flipping the other's loading UI.
  final bool isUploadingAvatar;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.error,
    this.isUploadingAvatar = false,
  });

  /// [error] is cleared unless passed again, so it only lives for one emission.
  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    String? error,
    bool? isUploadingAvatar,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
    );
  }

  @override
  List<Object?> get props => [status, user, error, isUploadingAvatar];
}
