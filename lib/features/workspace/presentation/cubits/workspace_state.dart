import 'package:equatable/equatable.dart';

import '../../domain/entity/work_space_entity.dart';

enum WorkspaceStatus { initial, loading, success, error }

class WorkspaceState extends Equatable {
  final WorkspaceStatus status;
  final List<WorkspaceEntity> workspaces;
  final String? error;

  const WorkspaceState({
    this.status = WorkspaceStatus.initial,
    this.workspaces = const [],
    this.error,
  });

  WorkspaceState copyWith({
    WorkspaceStatus? status,
    List<WorkspaceEntity>? workspaces,
    String? error,
  }) {
    return WorkspaceState(
      status: status ?? this.status,
      workspaces: workspaces ?? this.workspaces,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, workspaces, error];
}
