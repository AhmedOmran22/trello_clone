import 'package:equatable/equatable.dart';

import '../../../workspace/domain/entity/workspace_member_entity.dart';
import '../../domain/entity/board_column_entity.dart';

sealed class BoardState extends Equatable {
  const BoardState();

  @override
  List<Object?> get props => [];
}

class BoardInitial extends BoardState {
  const BoardInitial();
}

class BoardLoading extends BoardState {
  const BoardLoading();
}

class BoardLoaded extends BoardState {
  final String boardId;
  final String boardName;
  final String workspaceId;
  final List<BoardColumnEntity> columns;

  /// Fetched once when the board loads — members don't change during a
  /// board session, so re-opening the board is what picks up a new one.
  final List<WorkspaceMemberEntity> members;

  /// Message for the most recent failed write (create/rename/move/...), so
  /// the screen can surface it as a snackbar without leaving [BoardLoaded].
  /// Cleared on the next emission unless explicitly passed again.
  final String? actionError;

  const BoardLoaded({
    required this.boardId,
    required this.boardName,
    required this.workspaceId,
    required this.columns,
    this.members = const [],
    this.actionError,
  });

  BoardLoaded copyWith({
    String? boardId,
    String? boardName,
    String? workspaceId,
    List<BoardColumnEntity>? columns,
    List<WorkspaceMemberEntity>? members,
    String? actionError,
  }) {
    return BoardLoaded(
      boardId: boardId ?? this.boardId,
      boardName: boardName ?? this.boardName,
      workspaceId: workspaceId ?? this.workspaceId,
      columns: columns ?? this.columns,
      members: members ?? this.members,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [
    boardId,
    boardName,
    workspaceId,
    columns,
    members,
    actionError,
  ];
}

class BoardError extends BoardState {
  final String message;
  final bool isNetworkError;

  const BoardError({required this.message, this.isNetworkError = false});

  @override
  List<Object?> get props => [message, isNetworkError];
}
