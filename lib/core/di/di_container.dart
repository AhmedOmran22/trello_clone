import 'package:get_it/get_it.dart';

import '../../features/auth/data/data_source/auth_remote_data_source.dart';
import '../../features/auth/data/data_source/auth_supabase_datasource.dart';
import '../../features/auth/data/repos/auth_repo_impl.dart';
import '../../features/auth/domain/repo/auth_repo.dart';
import '../../features/auth/domain/use_case/login_use_case.dart';
import '../../features/auth/domain/use_case/login_with_google_use_case.dart';
import '../../features/auth/domain/use_case/register_use_case.dart';
import '../../features/auth/domain/use_case/get_current_user_use_case.dart';
import '../../features/auth/domain/use_case/logout_use_case.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../services/subabase_services.dart';
import '../session/session_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core ──
  sl.registerLazySingleton<SupabaseServices>(() => SupabaseServices());

  // ── Auth ──
  _initAuth();

  // ── Session ──
  _initSession();
}

void _initAuth() {
  // Datasource
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthSupabaseDatasource(sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      loginWithGoogleUseCase: sl(),
    ),
  );
}

void _initSession() {
  sl.registerLazySingleton(
    () => SessionCubit(
      getCurrentUserUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );
}