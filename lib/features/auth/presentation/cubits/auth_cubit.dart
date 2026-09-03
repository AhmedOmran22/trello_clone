import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_case/login_use_case.dart';
import '../../domain/use_case/login_with_google_use_case.dart';
import '../../domain/use_case/register_use_case.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.loginWithGoogleUseCase,
  }) : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await loginUseCase(email: email, password: password);

    if (isClosed) return;

    result.when(
      success: (user) =>
          emit(state.copyWith(status: AuthStatus.success, user: user)),
      error: (failure) =>
          emit(state.copyWith(status: AuthStatus.error, error: failure.message)),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await registerUseCase(
      email: email,
      password: password,
      fullName: fullName,
    );

    if (isClosed) return;

    result.when(
      success: (user) =>
          emit(state.copyWith(status: AuthStatus.success, user: user)),
      error: (failure) =>
          emit(state.copyWith(status: AuthStatus.error, error: failure.message)),
    );
  }

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await loginWithGoogleUseCase();

    if (isClosed) return;

    result.when(
      success: (user) =>
          emit(state.copyWith(status: AuthStatus.success, user: user)),
      error: (failure) =>
          emit(state.copyWith(status: AuthStatus.error, error: failure.message)),
    );
  }
}
