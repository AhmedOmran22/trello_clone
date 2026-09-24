import 'package:get_it/get_it.dart';

import '../../features/auth/data/data_source/auth_remote_data_source.dart';
import '../../features/auth/data/data_source/auth_supabase_datasource.dart';
import '../../features/auth/data/repos/auth_repo_impl.dart';
import '../../features/auth/domain/repo/auth_repo.dart';
import '../../features/auth/domain/use_case/login_with_google_use_case.dart';
import '../../features/auth/domain/use_case/get_current_user_use_case.dart';
import '../../features/auth/domain/use_case/logout_use_case.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/boards/data/datasources/board_remote_datasource.dart';
import '../../features/boards/data/datasources/board_supabase_datasource.dart';
import '../../features/boards/data/repo/board_repository_impl.dart';
import '../../features/boards/domain/repo/board_repo.dart';
import '../../features/boards/domain/usecases/create_board_usecase.dart';
import '../../features/boards/domain/usecases/create_column_usecase.dart';
import '../../features/boards/domain/usecases/create_task_usecase.dart';
import '../../features/boards/domain/usecases/delete_board_usecase.dart';
import '../../features/boards/domain/usecases/delete_column_usecase.dart';
import '../../features/boards/domain/usecases/delete_task_usecase.dart';
import '../../features/boards/domain/usecases/get_board_usecase.dart';
import '../../features/boards/domain/usecases/move_task_usecase.dart';
import '../../features/boards/domain/usecases/rename_column_usecase.dart';
import '../../features/boards/domain/usecases/reorder_columns_usecase.dart';
import '../../features/boards/domain/usecases/reorder_tasks_usecase.dart';
import '../../features/boards/domain/usecases/update_board_usecase.dart';
import '../../features/boards/domain/usecases/update_task_usecase.dart';
import '../../features/boards/presentation/bloc/board_bloc.dart';
import '../../features/boards/presentation/cubits/board_cubit.dart';
import '../../features/notifications/data/datasource/notification_remote_datasource.dart';
import '../../features/notifications/data/datasource/notification_supabase_data_source.dart';
import '../../features/notifications/data/repos/notification_repo_impl.dart';
import '../../features/notifications/domain/repo/notification_repo.dart';
import '../../features/notifications/presentation/cubits/notification_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/datasources/profile_supabase_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repo/profile_repo.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/upload_avatar_usecase.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
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
import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core ──
  sl.registerLazySingleton<SupabaseServices>(() => SupabaseServices());

  // ── Theme ──
  sl.registerLazySingleton(() => ThemeCubit());
  // Loaded before runApp so the first frame already uses the saved theme
  // instead of flashing the system one.
  await sl<ThemeCubit>().loadTheme();

  // ── Auth ──
  _initAuth();

  // ── Session ──
  _initSession();

  // ── Workspace ──
  _initWorkspace();

  // ── Boards ──
  _initBoard();

  // ── Notifications ──
  _initNotifications();

  // ── Profile ──
  _initProfile();
}

void _initAuth() {
  // Datasource
  sl.registerLazySingleton<AuthRemoteDatasource>(() => AuthSupabaseDatasource(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => AuthCubit(loginWithGoogleUseCase: sl(), sessionCubit: sl()),
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

void _initBoard() {
  // Datasource
  sl.registerLazySingleton<BoardRemoteDatasource>(
    () => BoardSupabaseDatasource(sl()),
  );

  // Repository
  sl.registerLazySingleton<BoardRepo>(() => BoardRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => CreateBoardUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBoardUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBoardUseCase(sl()));
  sl.registerLazySingleton(() => GetBoardUseCase(sl()));
  sl.registerLazySingleton(() => CreateColumnUseCase(sl()));
  sl.registerLazySingleton(() => RenameColumnUseCase(sl()));
  sl.registerLazySingleton(() => ReorderColumnsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteColumnUseCase(sl()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => MoveTaskUseCase(sl()));
  sl.registerLazySingleton(() => ReorderTasksUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => BoardCubit(
      createBoardUseCase: sl(),
      updateBoardUseCase: sl(),
      deleteBoardUseCase: sl(),
    ),
  );

  // Bloc (per-board instance, parameterized by boardId)
  sl.registerFactoryParam<BoardBloc, String, void>(
    (boardId, _) => BoardBloc(
      boardId: boardId,
      boardRepo: sl(),
      getBoardUseCase: sl(),
      createColumnUseCase: sl(),
      renameColumnUseCase: sl(),
      reorderColumnsUseCase: sl(),
      deleteColumnUseCase: sl(),
      createTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      moveTaskUseCase: sl(),
      reorderTasksUseCase: sl(),
      deleteTaskUseCase: sl(),
    ),
  );
}

void _initNotifications() {
  // Datasource
  sl.registerLazySingleton<NotificationRemoteDatasource>(
    () => NotificationSupabaseDatasource(sl()),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepo>(() => NotificationRepositoryImpl(sl()));

  // Cubit
  sl.registerFactory(() => NotificationCubit(repository: sl()));
}

void _initProfile() {
  // Datasource
  sl.registerLazySingleton<ProfileRemoteDatasource>(
    () => ProfileSupabaseDatasource(sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepo>(() => ProfileRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));

  // Cubit — a singleton so profile state survives switching bottom-nav tabs
  sl.registerLazySingleton(
    () => ProfileCubit(
      updateProfileUseCase: sl(),
      uploadAvatarUseCase: sl(),
      profileRepo: sl(),
      sessionCubit: sl(),
    ),
  );
}
