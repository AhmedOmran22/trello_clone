import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          _CreateWorkspaceButton(onTap: () {}),
          const SizedBox(height: AppTheme.spacingLg),
          const _WorkspaceSection(
            name: 'Mobile Team',
            boards: ['Sprint Board', 'Bug Tracker', 'Release Plan'],
            accentColor: Colors.blue,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          const _WorkspaceSection(
            name: 'Marketing',
            boards: ['Campaign Q4', 'Social Media'],
            accentColor: Colors.green,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          const _WorkspaceSection(
            name: 'Personal',
            boards: ['Side Project', 'Learning Goals', 'Reading List'],
            accentColor: Colors.purple,
          ),
          const SizedBox(height: AppTheme.spacingLg),
        ],
      ),
    );
  }
}

class _CreateWorkspaceButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateWorkspaceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add),
        label: const Text('Create Workspace'),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.colorScheme.primary,
          side: BorderSide(color: context.colorScheme.primary),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceSection extends StatelessWidget {
  final String name;
  final List<String> boards;
  final Color accentColor;

  const _WorkspaceSection({
    required this.name,
    required this.boards,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WorkspaceHeader(name: name),
        const SizedBox(height: AppTheme.spacingSm),
        for (final board in boards)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: _BoardTile(name: board, accentColor: accentColor),
          ),
      ],
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  final String name;

  const _WorkspaceHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(
            Icons.expand_more,
            size: 20,
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}

class _BoardTile extends StatelessWidget {
  final String name;
  final Color accentColor;

  const _BoardTile({required this.name, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
            border: Border(left: BorderSide(color: accentColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(name, style: context.textTheme.bodyLarge),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
