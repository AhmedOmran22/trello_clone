import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/route_names.dart';
import '../core/di/di_container.dart';
import '../core/session/session_cubit.dart';
import '../core/session/session_state.dart';
import '../core/utils/go_router_refresh_stream.dart';
import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/boards/presentation/bloc/board_bloc.dart';
import '../features/boards/presentation/cubits/board_cubit.dart';
import '../features/boards/presentation/screens/board_screen.dart';
import '../features/navbar/presentation/screens/navbar_screen.dart';
import '../features/workspace/presentation/cubits/workspace_cubit.dart';
import 'splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    refreshListenable: GoRouterRefreshStream(sl<SessionCubit>().stream),
    redirect: _authRedirect,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) =>
            BlocProvider(create: (_) => sl<AuthCubit>(), child: const LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<WorkspaceCubit>(
              create: (_) => sl<WorkspaceCubit>()..getWorkspaces(),
            ),
            BlocProvider<BoardCubit>(create: (_) => sl<BoardCubit>()),
          ],
          child: const NavbarScreen(),
        ),
      ),
      GoRoute(
        path: '${RouteNames.board}/:boardId',
        name: RouteNames.board,
        builder: (context, state) {
          final boardId = state.pathParameters['boardId']!;
          final boardName = state.extra as String? ?? 'Board';
          return BlocProvider<BoardBloc>(
            create: (_) => sl<BoardBloc>(param1: boardId),
            child: BoardScreen(boardId: boardId, boardName: boardName),
          );
        },
      ),
    ],
  );

  /// Redirects based on [SessionCubit] state.
  static String? _authRedirect(BuildContext context, GoRouterState state) {
    final sessionState = sl<SessionCubit>().state;

    final isOnAuthPage = state.matchedLocation == RouteNames.login;
    final isOnSplash = state.matchedLocation == RouteNames.splash;

    // Session hasn't been determined yet — stay on splash until
    // checkSession() resolves, then this redirect re-runs via
    // refreshListenable.
    if (sessionState.status == SessionStatus.initial ||
        sessionState.status == SessionStatus.loading) {
      return isOnSplash ? null : RouteNames.splash;
    }

    final isAuthenticated = sessionState.status == SessionStatus.authenticated;

    // Not logged in and trying to access protected page → go to login
    if (!isAuthenticated && !isOnAuthPage) {
      return RouteNames.login;
    }

    // Logged in but still on auth page or splash → go to home
    if (isAuthenticated && (isOnAuthPage || isOnSplash)) {
      return RouteNames.home;
    }

    // No redirect needed
    return null;
  }
}
