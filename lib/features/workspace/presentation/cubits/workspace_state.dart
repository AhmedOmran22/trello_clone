import 'package:equatable/equatable.dart';

import '../../domain/entity/workspace_entity.dart';

enum WorkspaceStatus { initial, loading, success, error }

/// Describes which write operation produced the current state, so listeners
/// can show the right feedback without inferring it from list-length diffs
/// (which can't tell "created" apart from the initial fetch populating the
/// list for the first time).
enum WorkspaceAction { none, created, updated, deleted }

class WorkspaceState extends Equatable {
  final WorkspaceStatus status;
  final List<WorkspaceEntity> workspaces;
  final String? error;
  final WorkspaceAction action;

  const WorkspaceState({
    this.status = WorkspaceStatus.initial,
    this.workspaces = const [],
    this.error,
    this.action = WorkspaceAction.none,
  });

  WorkspaceState copyWith({
    WorkspaceStatus? status,
    List<WorkspaceEntity>? workspaces,
    String? error,
    WorkspaceAction? action,
  }) {
    return WorkspaceState(
      status: status ?? this.status,
      workspaces: workspaces ?? this.workspaces,
      error: error,
      action: action ?? WorkspaceAction.none,
    );
  }

  @override
  List<Object?> get props => [status, workspaces, error, action];
}
