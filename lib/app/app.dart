import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/di_container.dart';
import '../core/session/session_cubit.dart';
import '../core/theme/app_theme.dart';

class TrelloCloneApp extends StatelessWidget {
  const TrelloCloneApp({super.key, required this.routerConfig});
  final RouterConfig<Object> routerConfig;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionCubit>(
      lazy: false,
      create: (_) => sl<SessionCubit>()..checkSession(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Trello Clone',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: routerConfig,
      ),
    );
  }
}
