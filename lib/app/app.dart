import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class TrelloCloneApp extends StatelessWidget {
  const TrelloCloneApp({super.key, required this.routerConfig});
  final RouterConfig<Object> routerConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Trello Clone',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: routerConfig,
    );
  }
}
