import 'package:flutter_bloc/flutter_bloc.dart';

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
        emit(state.copyWith(status: WorkspaceStatus.success, workspaces: updated));
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
        final workspaces = state.workspaces.map((w) {
          return w.id == id ? updated : w;
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

  Future<void> deleteWorkspace({required String id}) async {
    final result = await deleteWorkspaceUseCase(id: id);

    result.when(
      success: (_) {
        final workspaces = state.workspaces.where((w) => w.id != id).toList();
        emit(
          state.copyWith(status: WorkspaceStatus.success, workspaces: workspaces),
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
      success: (_) {
        // Refresh workspaces to get updated member count
        getWorkspaces();
      },
      error: (failure) => emit(
        state.copyWith(status: WorkspaceStatus.error, error: failure.message),
      ),
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
