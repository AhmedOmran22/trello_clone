import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/context_extensions.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../boards/domain/entity/board_entity.dart';
import '../../../../boards/presentation/widgets/board_list_tile.dart';
import '../../../domain/entity/workspace_entity.dart';
import '../../../domain/entity/workspace_member_entity.dart';
import '../../cubits/workspace_cubit.dart';
import '../../cubits/workspace_state.dart';
import '../member/add_member_bottom_sheet.dart';
import '../member/member_list_tile.dart';
import '../shared/bottom_sheet_drag_handle.dart';
import 'delete_workspace_dialog.dart';
import 'rename_workspace_bottom_sheet.dart';

/// Cycled by board index — mirrors the palette used for board tiles on the
/// workspace screen so boards are recognizable in both places.
const _boardAccentColors = [
  Colors.blue,
  Colors.teal,
  Colors.deepOrange,
  Colors.purple,
  Colors.green,
  Colors.pink,
];

/// Shows the Workspace Settings bottom sheet.
/// UI only — all callbacks are optional so the caller can wire up real
/// data/state management later. Members are read live from [WorkspaceCubit]
/// so the list updates in place as members are added/removed.
Future<void> showWorkspaceSettingsBottomSheet(
  BuildContext context, {
  required WorkspaceEntity workspace,
  required String currentUserId,
  void Function(String email)? onAddMember,
  void Function(String userId)? onRemoveMember,
  void Function(String newName)? onRename,
  VoidCallback? onDelete,
  VoidCallback? onLeave,
  VoidCallback? onAddBoard,
  void Function(BoardEntity board)? onBoardOptionsTap,
}) {
  final workspaceCubit = context.read<WorkspaceCubit>();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.borderRadiusXl),
      ),
    ),
    builder: (_) => BlocProvider.value(
      value: workspaceCubit,
      child: WorkspaceSettingsBottomSheet(
        workspace: workspace,
        currentUserId: currentUserId,
        onAddMember: onAddMember,
        onRemoveMember: onRemoveMember,
        onRename: onRename,
        onDelete: onDelete,
        onLeave: onLeave,
        onAddBoard: onAddBoard,
        onBoardOptionsTap: onBoardOptionsTap,
      ),
    ),
  );
}

class WorkspaceSettingsBottomSheet extends StatelessWidget {
  final WorkspaceEntity workspace;
  final String currentUserId;
  final void Function(String email)? onAddMember;
  final void Function(String userId)? onRemoveMember;
  final void Function(String newName)? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onLeave;
  final VoidCallback? onAddBoard;
  final void Function(BoardEntity board)? onBoardOptionsTap;

  const WorkspaceSettingsBottomSheet({
    super.key,
    required this.workspace,
    required this.currentUserId,
    this.onAddMember,
    this.onRemoveMember,
    this.onRename,
    this.onDelete,
    this.onLeave,
    this.onAddBoard,
    this.onBoardOptionsTap,
  });

  bool get _isOwner => workspace.isOwner;

  void _openAddMemberSheet(BuildContext context) {
    showAddMemberBottomSheet(
      context,
      workspaceName: workspace.name,
      onAdd: onAddMember,
    );
  }

  void _openRenameSheet(BuildContext context) {
    showRenameWorkspaceBottomSheet(
      context,
      currentName: workspace.name,
      onSave: onRename,
    );
  }

  void _openDeleteDialog(BuildContext context) {
    showDeleteWorkspaceDialog(
      context,
      workspaceName: workspace.name,
      onConfirm: onDelete,
    );
  }

  Future<void> _confirmRemoveMember(
    BuildContext context,
    WorkspaceMemberEntity member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Remove ${member.fullName} from ${workspace.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: dialogContext.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onRemoveMember?.call(member.userId);
    }
  }

  Future<void> _confirmLeaveWorkspace(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Workspace'),
        content: Text(
          'Are you sure you want to leave ${workspace.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: dialogContext.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onLeave?.call();
    }
  }

  List<WorkspaceMemberEntity> _membersOf(WorkspaceState state) {
    for (final w in state.workspaces) {
      if (w.id == workspace.id) return w.members;
    }
    return const [];
  }

  List<BoardEntity> _boardsOf(WorkspaceState state) {
    for (final w in state.workspaces) {
      if (w.id == workspace.id) return w.boards;
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return BlocBuilder<WorkspaceCubit, WorkspaceState>(
          buildWhen: (previous, current) =>
              _membersOf(previous) != _membersOf(current) ||
              _boardsOf(previous) != _boardsOf(current),
          builder: (context, state) {
            final members = _membersOf(state);
            final boards = _boardsOf(state);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              child: ListView(
                controller: scrollController,
                children: [
                  const SizedBox(height: AppTheme.spacingSm),
                  const Center(child: BottomSheetDragHandle()),
                  const SizedBox(height: AppTheme.spacingMd),
                  _Header(
                    workspaceName: workspace.name,
                    isOwner: _isOwner,
                    memberCount: members.length,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  _SectionHeader(title: 'Members', count: members.length),
                  const SizedBox(height: AppTheme.spacingSm),
                  for (final member in members)
                    MemberListTile(
                      member: member,
                      canRemove: _isOwner && !member.isOwner,
                      onRemove: () => _confirmRemoveMember(context, member),
                    ),
                  if (_isOwner) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openAddMemberSheet(context),
                        icon: const Icon(Icons.person_add_outlined),
                        label: const Text('Add Member'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacingLg),
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingSm),
                  _SectionHeader(title: 'Boards', count: boards.length),
                  const SizedBox(height: AppTheme.spacingSm),
                  if (boards.isEmpty)
                    Text('No boards yet', style: context.textTheme.bodySmall)
                  else
                    for (var i = 0; i < boards.length; i++)
                      BoardListTile(
                        name: boards[i].name,
                        accentColor: _boardAccentColors[i % _boardAccentColors.length],
                        onOptionsTap: () => onBoardOptionsTap?.call(boards[i]),
                      ),
                  const SizedBox(height: AppTheme.spacingSm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAddBoard,
                      icon: const Icon(Icons.dashboard_customize_outlined),
                      label: const Text('Add Board'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingSm),
                  const _SectionHeader(title: 'Settings'),
                  const SizedBox(height: AppTheme.spacingSm),
                  if (_isOwner)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Rename Workspace'),
                      onTap: () => _openRenameSheet(context),
                    ),
                  if (!_isOwner)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.exit_to_app,
                        color: context.colorScheme.error,
                      ),
                      title: Text(
                        'Leave Workspace',
                        style: TextStyle(color: context.colorScheme.error),
                      ),
                      onTap: () => _confirmLeaveWorkspace(context),
                    ),
                  if (_isOwner)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline,
                        color: context.colorScheme.error,
                      ),
                      title: Text(
                        'Delete Workspace',
                        style: TextStyle(color: context.colorScheme.error),
                      ),
                      onTap: () => _openDeleteDialog(context),
                    ),
                  const SizedBox(height: AppTheme.spacingLg),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String workspaceName;
  final bool isOwner;
  final int memberCount;

  const _Header({
    required this.workspaceName,
    required this.isOwner,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                workspaceName,
                style: context.textTheme.headlineMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            _RoleChip(isOwner: isOwner),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm / 2),
        Text(
          '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final bool isOwner;

  const _RoleChip({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isOwner
        ? context.colorScheme.primary.withValues(alpha: 0.12)
        : context.colorScheme.secondary.withValues(alpha: 0.12);
    final textColor = isOwner
        ? context.colorScheme.primary
        : context.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXl),
      ),
      child: Text(
        isOwner ? 'Owner' : 'Member',
        style: context.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;

  const _SectionHeader({required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: context.textTheme.labelLarge),
        if (count != null) ...[
          const SizedBox(width: AppTheme.spacingSm / 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: context.colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusXl),
            ),
            child: Text(
              '$count',
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
