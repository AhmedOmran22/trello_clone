import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/session_cubit.dart';
import '../../domain/use_case/login_with_google_use_case.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final SessionCubit sessionCubit;

  AuthCubit({required this.loginWithGoogleUseCase, required this.sessionCubit})
    : super(const AuthState());

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await loginWithGoogleUseCase();

    if (isClosed) return;

    result.when(
      success: (user) {
        sessionCubit.setUser(user);
        emit(state.copyWith(status: AuthStatus.success, user: user));
      },
      error: (failure) =>
          emit(state.copyWith(status: AuthStatus.error, error: failure.message)),
    );
  }
}
