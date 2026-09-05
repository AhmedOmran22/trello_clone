import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/work_space_entity.dart';
import '../cubits/workspace_cubit.dart';
import 'add_board_tile.dart';
import 'create_board_bottom_sheet.dart';
import 'workspace_header.dart';
import 'workspace_settings_bottom_sheet.dart';

class WorkspaceSection extends StatefulWidget {
  final WorkspaceEntity workspace;

  const WorkspaceSection({super.key, required this.workspace});

  @override
  State<WorkspaceSection> createState() => _WorkspaceSectionState();
}

class _WorkspaceSectionState extends State<WorkspaceSection> {
  bool _isExpanded = true;

  void _openCreateBoardSheet() {
    showCreateBoardBottomSheet(context, workspaceName: widget.workspace.name);
  }

  void _openSettingsSheet() {
    final workspace = widget.workspace;
    final currentUser = context.read<SessionCubit>().state.user!;
    final workspaceCubit = context.read<WorkspaceCubit>();

    showWorkspaceSettingsBottomSheet(
      context,
      workspaceId: workspace.id,
      workspaceName: workspace.name,
      currentUserRole: workspace.role,
      currentUserId: currentUser.id,
      members: workspace.members,
      onRename: (newName) {
        workspaceCubit.updateWorkspace(id: workspace.id, name: newName);
        Navigator.pop(context);
      },
      onDelete: () {
        workspaceCubit.deleteWorkspace(id: workspace.id);
        Navigator.pop(context);
      },
      onAddMember: (email) {
        workspaceCubit.addMember(workspaceId: workspace.id, email: email);
      },
      onRemoveMember: (userId) {
        workspaceCubit.removeMember(workspaceId: workspace.id, userId: userId);
      },
      onLeave: () {
        workspaceCubit.removeMember(
          workspaceId: workspace.id,
          userId: currentUser.id,
        );
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WorkspaceHeader(
          name: widget.workspace.name,
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
            child: AddBoardTile(onTap: _openCreateBoardSheet),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
