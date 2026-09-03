import 'package:get_it/get_it.dart';

import '../../features/auth/data/data_source/auth_remote_data_source.dart';
import '../../features/auth/data/data_source/auth_supabase_datasource.dart';
import '../../features/auth/data/repos/auth_repo_impl.dart';
import '../../features/auth/domain/repo/auth_repo.dart';
import '../../features/auth/domain/use_case/get_current_user_use_case.dart'
    show GetCurrentUserUseCase;
import '../../features/auth/domain/use_case/login_use_case.dart';
import '../../features/auth/domain/use_case/login_with_google_use_case.dart';
import '../../features/auth/domain/use_case/logout_use_case.dart';
import '../../features/auth/domain/use_case/register_use_case.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../services/subabase_services.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core ──
  sl.registerLazySingleton<SupabaseServices>(() => SupabaseServices());

  // ── Auth ──
  _initAuth();
}

void _initAuth() {
  // Datasource
  sl.registerLazySingleton<AuthRemoteDatasource>(() => AuthSupabaseDatasource(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      loginWithGoogleUseCase: sl(),
    ),
  );
}
