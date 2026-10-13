import 'package:get_it/get_it.dart';

import 'di.dart';

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

  // ── Search ──
  _initSearch();
}

void _initAuth() {
  // Datasource
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthSupabaseDatasource(sl()),
  );

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
  sl.registerLazySingleton(() => GetWorkspaceMembersUseCase(sl()));

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
  // Datasources
  sl.registerLazySingleton<BoardRemoteDatasource>(
    () => BoardSupabaseDatasource(sl()),
  );
  sl.registerLazySingleton<ColumnRemoteDatasource>(
    () => ColumnSupabaseDatasource(sl()),
  );
  sl.registerLazySingleton<TaskRemoteDatasource>(
    () => TaskSupabaseDatasource(sl()),
  );

  // Repository
  sl.registerLazySingleton<BoardRepo>(
    () => BoardRepositoryImpl(
      boardDatasource: sl(),
      columnDatasource: sl(),
      taskDatasource: sl(),
    ),
  );

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
  sl.registerLazySingleton(() => WatchColumnsUseCase(sl()));
  sl.registerLazySingleton(() => WatchTasksUseCase(sl()));

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
      getWorkspaceMembersUseCase: sl(),
      watchColumnsUseCase: sl(),
      watchTasksUseCase: sl(),
    ),
  );
}

void _initNotifications() {
  // Datasource
  sl.registerLazySingleton<NotificationRemoteDatasource>(
    () => NotificationSupabaseDatasource(sl()),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepo>(
    () => NotificationRepositoryImpl(sl()),
  );

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

void _initSearch() {
  // Datasource
  sl.registerLazySingleton<SearchRemoteDatasource>(
    () => SearchSupabaseDatasource(sl()),
  );

  // Repository
  sl.registerLazySingleton<SearchRepo>(() => SearchRepositoryImpl(sl()));

  // Use Case
  sl.registerLazySingleton(() => SearchUseCase(sl()));

  // Cubit
  sl.registerFactory(() => SearchCubit(searchUseCase: sl()));
}
