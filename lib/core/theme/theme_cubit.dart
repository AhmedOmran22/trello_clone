import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const _prefsKey = 'theme_mode';

  ThemeCubit() : super(const ThemeState());

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);

    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    emit(ThemeState(themeMode: mode));
  }

  Future<void> setTheme(ThemeMode mode) async {
    // Apply first so the switch is instant; persisting is best-effort after.
    emit(ThemeState(themeMode: mode));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}
