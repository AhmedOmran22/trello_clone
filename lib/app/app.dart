import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/di_container.dart';
import '../core/services/push_notification_service.dart';
import '../core/session/session_cubit.dart';
import '../core/session/session_state.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../core/theme/theme_state.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';

class TrelloCloneApp extends StatelessWidget {
  const TrelloCloneApp({super.key, required this.routerConfig});
  final RouterConfig<Object> routerConfig;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(
          lazy: false,
          create: (_) => sl<SessionCubit>()..checkSession(),
        ),
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
      ],
      child: BlocListener<SessionCubit, SessionState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          // In-app notification listening is started separately, once the
          // home route's own NotificationCubit exists (see router.dart) —
          // it isn't reachable from up here yet.
          if (state.status == SessionStatus.authenticated) {
            PushNotificationService().initialize();
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Trello Clone',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              routerConfig: routerConfig,
            );
          },
        ),
      ),
    );
  }
}
