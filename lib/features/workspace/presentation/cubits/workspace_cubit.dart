import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../boards/domain/entity/board_entity.dart';
import '../../domain/use_cases/add_members_use_case.dart';
import '../../domain/use_cases/create_workspace_use_case.dart';
import '../../domain/use_cases/delete_workspace_use_case.dart';
import '../../domain/use_cases/get_workspaces_use_case.dart';
import '../../domain/use_cases/remove_members_use_case.dart';
import '../../domain/use_cases/update_workspace_use_case.dart';
import 'workspace_state.dart';

class WorkspaceCubit extends Cubit<WorkspaceState> {
  final GetWorkspacesUseCase getWorkspacesUseCase;
  final CreateWorkspaceUseCase createWorkspaceUseCase;
  final UpdateWorkspaceUseCase updateWorkspaceUseCase;
  final DeleteWorkspaceUseCase deleteWorkspaceUseCase;
  final AddMemberUseCase addMemberUseCase;
  final RemoveMemberUseCase removeMemberUseCase;

  WorkspaceCubit({
    required this.getWorkspacesUseCase,
    required this.createWorkspaceUseCase,
    required this.updateWorkspaceUseCase,
    required this.deleteWorkspaceUseCase,
    required this.addMemberUseCase,
    required this.removeMemberUseCase,
  }) : super(const WorkspaceState());

  Future<void> getWorkspaces() async {
    emit(state.copyWith(status: WorkspaceStatus.loading));

    final result = await getWorkspacesUseCase();

    result.when(
      success: (workspaces) => emit(
        state.copyWith(status: WorkspaceStatus.success, workspaces: workspaces),
      ),
      error: (failure) => emit(
        state.copyWith(status: WorkspaceStatus.error, error: failure.message),
      ),
    );
  }

  Future<void> createWorkspace({
    required String name,
    required String userId,
  }) async {
    final result = await createWorkspaceUseCase(name: name, userId: userId);

    result.when(
      success: (workspace) {
        final updated = [...state.workspaces, workspace];
        emit(
          state.copyWith(
            status: WorkspaceStatus.success,
            workspaces: updated,
            action: WorkspaceAction.created,
          ),
        );
      },
      error: (failure) => emit(
        state.copyWith(status: WorkspaceStatus.error, error: failure.message),
      ),
    );
  }

  Future<void> updateWorkspace({required String id, required String name}) async {
    final result = await updateWorkspaceUseCase(id: id, name: name);

    result.when(
      success: (updated) {
        // Only the name comes back as authoritative from the update — merge
        // it into the existing entry so members/boards already held locally
        // aren't wiped out.
        final workspaces = state.workspaces.map((w) {
          return w.id == id ? w.copyWith(name: updated.name) : w;
        }).toList();
        emit(
          state.copyWith(status: WorkspaceStatus.success, workspaces: workspaces),
        );
      },
      error: (failure) => emit(
        state.copyWith(status: WorkspaceStatus.error, error: failure.message),
      ),
    );
  }

  /// Reflects a board created via BoardCubit into the owning workspace's
  /// local board list, so the UI shows it without a full workspace refetch.
  void addBoardToWorkspace(String workspaceId, BoardEntity board) {
    final workspaces = state.workspaces.map((w) {
      if (w.id != workspaceId) return w;
      return w.copyWith(boards: [...w.boards, board]);
    }).toList();
    emit(state.copyWith(workspaces: workspaces));
  }

  /// Reflects a board renamed via BoardCubit into the owning workspace's
  /// local board list.
  void updateBoardInWorkspace(String workspaceId, BoardEntity board) {
    final workspaces = state.workspaces.map((w) {
      if (w.id != workspaceId) return w;
      final boards = w.boards.map((b) => b.id == board.id ? board : b).toList();
      return w.copyWith(boards: boards);
    }).toList();
    emit(state.copyWith(workspaces: workspaces));
  }

  /// Reflects a board deleted via BoardCubit into the owning workspace's
  /// local board list.
  void removeBoardFromWorkspace(String workspaceId, String boardId) {
    final workspaces = state.workspaces.map((w) {
      if (w.id != workspaceId) return w;
      return w.copyWith(boards: w.boards.where((b) => b.id != boardId).toList());
    }).toList();
    emit(state.copyWith(workspaces: workspaces));
  }

  Future<void> deleteWorkspace({required String id}) async {
    final result = await deleteWorkspaceUseCase(id: id);

    result.when(
      success: (_) {
        final workspaces = state.workspaces.where((w) => w.id != id).toList();
        emit(
          state.copyWith(
            status: WorkspaceStatus.success,
            workspaces: workspaces,
            action: WorkspaceAction.deleted,
          ),
        );
      },
      error: (failure) => emit(
        state.copyWith(status: WorkspaceStatus.error, error: failure.message),
      ),
    );
  }

  Future<void> addMember({
    required String workspaceId,
    required String email,
  }) async {
    final result = await addMemberUseCase(workspaceId: workspaceId, email: email);

    result.when(
      success: (member) {
        final workspaces = state.workspaces.map((w) {
          if (w.id != workspaceId) return w;
          return w.copyWith(members: [...w.members, member]);
        }).toList();

        emit(
          state.copyWith(status: WorkspaceStatus.success, workspaces: workspaces),
        );
      },
      // Keep the current status/workspaces untouched so the list stays on
      // screen — only surface the error as a snackbar.
      error: (failure) => emit(state.copyWith(error: failure.message)),
    );
  }

  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    final result = await removeMemberUseCase(
      workspaceId: workspaceId,
      userId: userId,
    );

    result.when(
      success: (_) {
        getWorkspaces();
      },
      error: (failure) => emit(
        state.copyWith(status: WorkspaceStatus.error, error: failure.message),
      ),
    );
  }
}
