import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'add_board_tile.dart';
import 'board_tile.dart';
import 'create_board_bottom_sheet.dart';
import 'member_list_tile.dart';
import 'workspace_header.dart';
import 'workspace_settings_bottom_sheet.dart';

/// Mockup member directory keyed by workspace name.
/// TODO: replace with real member data from a Cubit once available.
const _mockMembersByWorkspace = <String, List<MockMember>>{
  'Mobile Team': [
    MockMember(
      id: 'ahmed-omran',
      fullName: 'Ahmed Omran',
      email: 'ahmed@test.com',
      role: 'owner',
    ),
    MockMember(
      id: 'sara-ali',
      fullName: 'Sara Ali',
      email: 'sara@test.com',
      role: 'member',
    ),
    MockMember(
      id: 'mohamed-hassan',
      fullName: 'Mohamed Hassan',
      email: 'mohamed@test.com',
      role: 'member',
    ),
  ],
  'Marketing': [
    MockMember(
      id: 'ahmed-omran',
      fullName: 'Ahmed Omran',
      email: 'ahmed@test.com',
      role: 'member',
    ),
    MockMember(
      id: 'nour-ibrahim',
      fullName: 'Nour Ibrahim',
      email: 'nour@test.com',
      role: 'owner',
    ),
  ],
  'Personal': [
    MockMember(
      id: 'ahmed-omran',
      fullName: 'Ahmed Omran',
      email: 'ahmed@test.com',
      role: 'owner',
    ),
  ],
};

const _currentUserId = 'ahmed-omran';

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

  void _openSettingsSheet() {
    final members = _mockMembersByWorkspace[widget.name] ?? const [];
    final currentUserRole = members
        .firstWhere(
          (member) => member.id == _currentUserId,
          orElse: () => const MockMember(
            id: _currentUserId,
            fullName: 'Ahmed Omran',
            email: 'ahmed@test.com',
            role: 'member',
          ),
        )
        .role;

    showWorkspaceSettingsBottomSheet(
      context,
      workspaceId: widget.name,
      workspaceName: widget.name,
      currentUserRole: currentUserRole,
      currentUserId: _currentUserId,
      members: members,
    );
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
          onOpenSettings: _openSettingsSheet,
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
