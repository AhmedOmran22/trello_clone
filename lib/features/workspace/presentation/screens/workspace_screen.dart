import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/create_workspace_fab.dart';
import '../widgets/workspace_section.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: const [
          WorkspaceSection(
            name: 'Mobile Team',
            boards: ['Sprint Board', 'Bug Tracker', 'Release Plan'],
            accentColor: Colors.blue,
          ),
          SizedBox(height: AppTheme.spacingLg),
          WorkspaceSection(
            name: 'Marketing',
            boards: ['Campaign Q4', 'Social Media'],
            accentColor: Colors.green,
          ),
          SizedBox(height: AppTheme.spacingLg),
          WorkspaceSection(
            name: 'Personal',
            boards: ['Side Project', 'Learning Goals', 'Reading List'],
            accentColor: Colors.purple,
          ),
          SizedBox(height: AppTheme.spacingLg),
        ],
      ),
      floatingActionButton: CreateWorkspaceFab(onPressed: () {}),
    );
  }
}
