import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/context_extensions.dart';
import '../../../../../core/session/session_cubit.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../boards/domain/entity/board_entity.dart';
import '../../../../boards/presentation/cubits/board_cubit.dart';
import '../../../../boards/presentation/widgets/delete_board_dialog.dart';
import '../../../../boards/presentation/widgets/rename_board_bottom_sheet.dart';
import '../../../domain/entity/workspace_entity.dart';
import '../../cubits/workspace_cubit.dart';
import '../board/add_board_tile.dart';
import '../board/board_tile.dart';
import '../board/create_board_bottom_sheet.dart';
import '../shared/bottom_sheet_drag_handle.dart';
import 'workspace_header.dart';
import 'workspace_settings_bottom_sheet.dart';

/// Cycled by board index — boards have no stored color, this just keeps
/// tiles visually distinct.
const _boardAccentColors = [
  Colors.blue,
  Colors.teal,
  Colors.deepOrange,
  Colors.purple,
  Colors.green,
  Colors.pink,
];

class WorkspaceSection extends StatefulWidget {
  final WorkspaceEntity workspace;

  const WorkspaceSection({super.key, required this.workspace});

  @override
  State<WorkspaceSection> createState() => _WorkspaceSectionState();
}

class _WorkspaceSectionState extends State<WorkspaceSection> {
  bool _isExpanded = true;

  void _openCreateBoardSheet() {
    final workspace = widget.workspace;
    final boardCubit = context.read<BoardCubit>();

    showCreateBoardBottomSheet(
      context,
      workspaceName: workspace.name,
      onSubmit: (name) {
        boardCubit.createBoard(workspaceId: workspace.id, name: name);
      },
    );
  }

  void _openSettingsSheet() {
    final workspace = widget.workspace;
    final currentUser = context.read<SessionCubit>().state.user!;
    final workspaceCubit = context.read<WorkspaceCubit>();

    showWorkspaceSettingsBottomSheet(
      context,
      workspace: workspace,
      currentUserId: currentUser.id,
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
      onAddBoard: _openCreateBoardSheet,
      onBoardOptionsTap: _openBoardOptions,
      onLeave: () {
        workspaceCubit.removeMember(
          workspaceId: workspace.id,
          userId: currentUser.id,
        );
        Navigator.pop(context);
      },
    );
  }

  void _openBoardOptions(BoardEntity board) {
    final boardCubit = context.read<BoardCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusXl),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppTheme.spacingSm),
            const Center(child: BottomSheetDragHandle()),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename Board'),
              onTap: () {
                Navigator.pop(sheetContext);
                showRenameBoardBottomSheet(
                  context,
                  currentName: board.name,
                  onSave: (newName) {
                    boardCubit.updateBoard(
                      id: board.id,
                      name: newName,
                      workspaceId: board.workspaceId,
                    );
                  },
                );
              },
            ),
            if (widget.workspace.isOwner)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: sheetContext.colorScheme.error,
                ),
                title: Text(
                  'Delete Board',
                  style: TextStyle(color: sheetContext.colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showDeleteBoardDialog(
                    context,
                    boardName: board.name,
                    onConfirm: () {
                      boardCubit.deleteBoard(
                        id: board.id,
                        workspaceId: board.workspaceId,
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: AppTheme.spacingSm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boards = widget.workspace.boards;

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
            child: Column(
              children: [
                for (var i = 0; i < boards.length; i++) ...[
                  BoardTile(
                    name: boards[i].name,
                    accentColor: _boardAccentColors[i % _boardAccentColors.length],
                    onLongPress: () => _openBoardOptions(boards[i]),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                ],
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
