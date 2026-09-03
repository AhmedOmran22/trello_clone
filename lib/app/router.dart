import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/route_names.dart';
import '../core/di/di_container.dart';
import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.login,
    redirect: _authRedirect,
    routes: [
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) =>
            BlocProvider(create: (_) => sl<AuthCubit>(), child: const LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const RegisterScreen(),
        ),
      ),
    ],
  );

  /// Redirects based on auth state
  static String? _authRedirect(BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthenticated = session != null;

    final isOnAuthPage =
        state.matchedLocation == RouteNames.login ||
        state.matchedLocation == RouteNames.register;

    // Not logged in and trying to access protected page → go to login
    if (!isAuthenticated && !isOnAuthPage) {
      return RouteNames.login;
    }

    // Logged in but still on auth page → go to workspaces
    if (isAuthenticated && isOnAuthPage) {
      return RouteNames.workspaces;
    }

    // No redirect needed
    return null;
  }
}
