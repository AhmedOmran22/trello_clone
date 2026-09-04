import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'add_board_tile.dart';
import 'board_tile.dart';
import 'create_board_bottom_sheet.dart';
import 'workspace_header.dart';

class WorkspaceSection extends StatefulWidget {
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
  State<WorkspaceSection> createState() => _WorkspaceSectionState();
}

class _WorkspaceSectionState extends State<WorkspaceSection> {
  bool _isExpanded = true;

  void _openCreateBoardSheet() {
    showCreateBoardBottomSheet(context, workspaceName: widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WorkspaceHeader(
          name: widget.name,
          isExpanded: _isExpanded,
          onToggle: () => setState(() => _isExpanded = !_isExpanded),
          onAddBoard: _openCreateBoardSheet,
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingSm),
            child: Column(
              children: [
                for (final board in widget.boards)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                    child: BoardTile(name: board, accentColor: widget.accentColor),
                  ),
                AddBoardTile(onTap: _openCreateBoardSheet),
              ],
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
