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
import '../../features/workspace/data/data_source/work_space_remote_data_source.dart';
import '../../features/workspace/data/data_source/workspace_supabase_data_source.dart';
import '../../features/workspace/data/repo/workspace_repo_impl.dart';
import '../../features/workspace/domain/repo/workspace_repo.dart';
import '../../features/workspace/domain/use_cases/add_members_use_case.dart';
import '../../features/workspace/domain/use_cases/create_workspace_use_case.dart';
import '../../features/workspace/domain/use_cases/delete_workspace_use_case.dart';
import '../../features/workspace/domain/use_cases/get_workspaces_use_case.dart';
import '../../features/workspace/domain/use_cases/remove_members_use_case.dart';
import '../../features/workspace/domain/use_cases/update_workspace_use_case.dart';
import '../../features/workspace/presentation/cubits/workspace_cubit.dart';
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

  // ── Workspace ──
  _initWorkspace();
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
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      loginWithGoogleUseCase: sl(),
      sessionCubit: sl(),
    ),
  );
}

void _initSession() {
  sl.registerLazySingleton(
    () => SessionCubit(getCurrentUserUseCase: sl(), logoutUseCase: sl()),
  );
}

void _initWorkspace() {
  // Datasource
  sl.registerLazySingleton<WorkspaceRemoteDatasource>(
    () => WorkspaceSupabaseDatasource(sl()),
  );

  // Repository
  sl.registerLazySingleton<WorkspaceRepo>(() => WorkspaceRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetWorkspacesUseCase(sl()));
  sl.registerLazySingleton(() => CreateWorkspaceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWorkspaceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWorkspaceUseCase(sl()));
  sl.registerLazySingleton(() => AddMemberUseCase(sl()));
  sl.registerLazySingleton(() => RemoveMemberUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => WorkspaceCubit(
      getWorkspacesUseCase: sl(),
      createWorkspaceUseCase: sl(),
      updateWorkspaceUseCase: sl(),
      deleteWorkspaceUseCase: sl(),
      addMemberUseCase: sl(),
      removeMemberUseCase: sl(),
    ),
  );
}
