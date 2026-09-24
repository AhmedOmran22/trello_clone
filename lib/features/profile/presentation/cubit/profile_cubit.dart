import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/session/session_state.dart';
import '../../../auth/domain/entity/user_entity.dart';
import '../../domain/repo/profile_repo.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;
  final ProfileRepo profileRepo;
  final SessionCubit sessionCubit;

  late final StreamSubscription<SessionState> _sessionSubscription;

  ProfileCubit({
    required this.updateProfileUseCase,
    required this.uploadAvatarUseCase,
    required this.profileRepo,
    required this.sessionCubit,
  }) : super(const ProfileState()) {
    loadProfile();
    _sessionSubscription = sessionCubit.stream.listen(_onSessionChanged);
  }

  void loadProfile() {
    final user = sessionCubit.state.user;
    if (user == null) return;

    emit(state.copyWith(status: ProfileStatus.success, user: user));
  }

  // This cubit is a singleton, so without this it would keep showing the
  // previous account after a logout → login as someone else.
  void _onSessionChanged(SessionState session) {
    final user = session.user;
    if (user == state.user) return;

    emit(
      ProfileState(
        status: user == null ? ProfileStatus.initial : ProfileStatus.success,
        user: user,
      ),
    );
  }

  Future<void> updateProfile({required String fullName}) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await updateProfileUseCase(fullName: fullName);

    result.when(
      success: (user) {
        // Logged out (or switched account) while saving — don't resurrect the session.
        if (sessionCubit.state.user?.id != user.id) return;

        sessionCubit.setUser(user);
        emit(state.copyWith(status: ProfileStatus.success, user: user));
      },
      error: (failure) =>
          emit(state.copyWith(status: ProfileStatus.error, error: failure.message)),
    );
  }

  Future<void> uploadAvatar({required String filePath}) async {
    final userId = sessionCubit.state.user?.id;
    if (userId == null) return;

    emit(state.copyWith(isUploadingAvatar: true));

    final result = await uploadAvatarUseCase(userId: userId, filePath: filePath);

    result.when(
      success: (avatarUrl) => _applyAvatar(userId, avatarUrl),
      error: _emitAvatarFailure,
    );
  }

  Future<void> removeAvatar() async {
    final userId = sessionCubit.state.user?.id;
    if (userId == null) return;

    emit(state.copyWith(isUploadingAvatar: true));

    final result = await profileRepo.removeAvatar(userId: userId);

    result.when(
      success: (_) => _applyAvatar(userId, null),
      error: _emitAvatarFailure,
    );
  }

  void _applyAvatar(String userId, String? avatarUrl) {
    // Build from the *current* session user, not one captured before the request,
    // so a name edit made while the upload was running isn't overwritten.
    final current = sessionCubit.state.user;
    if (current == null || current.id != userId) return;

    final updated = UserEntity(
      id: current.id,
      email: current.email,
      fullName: current.fullName,
      avatarUrl: avatarUrl,
    );

    sessionCubit.setUser(updated);
    emit(
      state.copyWith(
        status: ProfileStatus.success,
        user: updated,
        isUploadingAvatar: false,
      ),
    );
  }

  void _emitAvatarFailure(Failure failure) {
    emit(
      state.copyWith(
        status: ProfileStatus.error,
        error: failure.message,
        isUploadingAvatar: false,
      ),
    );
  }

  @override
  Future<void> close() {
    _sessionSubscription.cancel();
    return super.close();
  }
}
