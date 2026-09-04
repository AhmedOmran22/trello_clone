import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'board_tile.dart';
import 'workspace_header.dart';

class WorkspaceSection extends StatelessWidget {
  final String name;
  final List<String> boards;
  final Color accentColor;

  const WorkspaceSection({
    super.key,
    required this.name,
    required this.boards,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WorkspaceHeader(name: name),
        const SizedBox(height: AppTheme.spacingSm),
        for (final board in boards)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: BoardTile(name: board, accentColor: accentColor),
          ),
      ],
    );
  }
}
