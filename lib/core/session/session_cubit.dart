import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/domain/entity/user_entity.dart';
import '../../features/auth/domain/use_case/get_current_user_use_case.dart';
import '../../features/auth/domain/use_case/logout_use_case.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  SessionCubit({required this.getCurrentUserUseCase, required this.logoutUseCase})
    : super(const SessionState());

  /// Called once on app startup to check saved session
  Future<void> checkSession() async {
    emit(state.copyWith(status: SessionStatus.loading));

    final result = await getCurrentUserUseCase();

    result.when(
      success: (user) =>
          emit(state.copyWith(status: SessionStatus.authenticated, user: user)),
      error: (_) => emit(state.copyWith(status: SessionStatus.unauthenticated)),
    );
  }

  /// Called from AuthCubit after login/register success
  void setUser(UserEntity user) {
    emit(state.copyWith(status: SessionStatus.authenticated, user: user));
  }

  /// Called from profile screen or anywhere logout is triggered
  Future<void> logout() async {
    final result = await logoutUseCase();

    result.when(
      success: (_) =>
          emit(const SessionState(status: SessionStatus.unauthenticated)),
      error: (_) => emit(const SessionState(status: SessionStatus.unauthenticated)),
    );
  }
}
