import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../boards/presentation/cubits/board_cubit.dart';
import '../../../boards/presentation/cubits/board_state.dart';
import '../../domain/entity/workspace_entity.dart';
import '../cubits/workspace_cubit.dart';
import '../cubits/workspace_state.dart';
import '../widgets/workspace/create_workspace_bottom_sheet.dart';
import '../widgets/workspace/create_workspace_fab.dart';
import '../widgets/workspace/workspace_section.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  void _openCreateWorkspaceSheet() {
    final userId = context.read<SessionCubit>().state.user!.id;
    final workspaceCubit = context.read<WorkspaceCubit>();

    showCreateWorkspaceBottomSheet(
      context,
      onSubmit: (name) {
        workspaceCubit.createWorkspace(name: name, userId: userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WorkspaceCubit, WorkspaceState>(
          listenWhen: (previous, current) =>
              current.error != null && current.error != previous.error,
          listener: (context, state) => context.showErrorSnackBar(state.error!),
        ),
        BlocListener<WorkspaceCubit, WorkspaceState>(
          listenWhen: (previous, current) =>
              current.action != WorkspaceAction.none &&
              current.action != previous.action,
          listener: (context, state) {
            switch (state.action) {
              case WorkspaceAction.created:
                context.showSnackBar('Workspace created successfully');
              case WorkspaceAction.deleted:
                context.showSnackBar('Workspace deleted successfully');
              case WorkspaceAction.updated:
              case WorkspaceAction.none:
                break;
            }
          },
        ),
        BlocListener<BoardCubit, BoardState>(
          listenWhen: (previous, current) =>
              current.error != null && current.error != previous.error,
          listener: (context, state) => context.showErrorSnackBar(state.error!),
        ),
        BlocListener<BoardCubit, BoardState>(
          listenWhen: (previous, current) =>
              current.action != BoardAction.none && current.action != previous.action,
          listener: (context, state) {
            final workspaceCubit = context.read<WorkspaceCubit>();
            switch (state.action) {
              case BoardAction.created:
                workspaceCubit.addBoardToWorkspace(state.workspaceId!, state.board!);
                context.showSnackBar('Board created successfully');
              case BoardAction.updated:
                workspaceCubit.updateBoardInWorkspace(state.workspaceId!, state.board!);
              case BoardAction.deleted:
                workspaceCubit.removeBoardFromWorkspace(
                  state.workspaceId!,
                  state.boardId!,
                );
                context.showSnackBar('Board deleted successfully');
              case BoardAction.none:
                break;
            }
          },
        ),
      ],
      child: Scaffold(
        body: BlocBuilder<WorkspaceCubit, WorkspaceState>(
          builder: (context, state) {
            // Once workspaces are already on screen, a re-fetch (pull-to-refresh,
            // or after adding/removing a member) should not blank the list —
            // only show the full-screen spinner on the very first load.
            if (state.workspaces.isNotEmpty &&
                (state.status == WorkspaceStatus.loading ||
                    state.status == WorkspaceStatus.success)) {
              return _WorkspaceList(workspaces: state.workspaces);
            }

            switch (state.status) {
              case WorkspaceStatus.initial:
              case WorkspaceStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case WorkspaceStatus.error:
                return _ErrorView(
                  message: state.error ?? 'Something went wrong',
                  onRetry: () => context.read<WorkspaceCubit>().getWorkspaces(),
                );
              case WorkspaceStatus.success:
                return _EmptyView(onCreate: _openCreateWorkspaceSheet);
            }
          },
        ),
        floatingActionButton: CreateWorkspaceFab(
          onPressed: _openCreateWorkspaceSheet,
        ),
      ),
    );
  }
}

class _WorkspaceList extends StatelessWidget {
  final List<WorkspaceEntity> workspaces;

  const _WorkspaceList({required this.workspaces});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<WorkspaceCubit>().getWorkspaces(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: workspaces.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppTheme.spacingLg),
        itemBuilder: (context, index) =>
            WorkspaceSection(workspace: workspaces[index]),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text('No workspaces yet', style: context.textTheme.titleMedium),
            const SizedBox(height: AppTheme.spacingSm / 2),
            Text(
              'Create your first workspace to get started',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create Workspace'),
            ),
          ],
        ),
      ),
    );
  }
}
