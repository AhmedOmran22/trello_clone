import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/app_theme.dart';

Future<void> showThemeSelectorBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    builder: (_) => const _ThemeSelectorBottomSheet(),
  );
}

class _ThemeOption {
  const _ThemeOption(this.mode, this.label, this.icon);

  final ThemeMode mode;
  final String label;
  final IconData icon;
}

class _ThemeSelectorBottomSheet extends StatelessWidget {
  const _ThemeSelectorBottomSheet();

  static const _options = [
    _ThemeOption(ThemeMode.system, 'System default', Icons.smartphone),
    _ThemeOption(ThemeMode.light, 'Light', Icons.light_mode),
    _ThemeOption(ThemeMode.dark, 'Dark', Icons.dark_mode),
  ];

  @override
  Widget build(BuildContext context) {
    final current = context.select((ThemeCubit cubit) => cubit.state.themeMode);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text('Choose Theme', style: context.textTheme.titleLarge),
            const SizedBox(height: AppTheme.spacingSm),
            RadioGroup<ThemeMode>(
              groupValue: current,
              onChanged: (mode) {
                if (mode == null) return;
                context.read<ThemeCubit>().setTheme(mode);
                Navigator.pop(context);
              },
              child: Column(
                children: [
                  for (final option in _options)
                    RadioListTile<ThemeMode>(
                      value: option.mode,
                      selected: option.mode == current,
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(option.icon),
                      title: Text(option.label),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
