import 'package:equatable/equatable.dart';

import '../../domain/entity/board_entity.dart';

enum BoardStatus { initial, loading, success, error }

/// Describes which write operation produced the current state, so listeners
/// (e.g. WorkspaceScreen) know whether to add/replace/remove the board from
/// the workspace it belongs to.
enum BoardAction { none, created, updated, deleted }

class BoardState extends Equatable {
  final BoardStatus status;
  final BoardAction action;
  final String? error;

  /// The workspace the last action applies to, so listeners can locate it
  /// without the cubit needing to own the full workspace/board list itself.
  final String? workspaceId;

  /// The resulting board for create/update actions.
  final BoardEntity? board;

  /// The id of the deleted board (delete doesn't return a board).
  final String? boardId;

  const BoardState({
    this.status = BoardStatus.initial,
    this.action = BoardAction.none,
    this.error,
    this.workspaceId,
    this.board,
    this.boardId,
  });

  BoardState copyWith({
    BoardStatus? status,
    BoardAction? action,
    String? error,
    String? workspaceId,
    BoardEntity? board,
    String? boardId,
  }) {
    return BoardState(
      status: status ?? this.status,
      action: action ?? BoardAction.none,
      error: error,
      workspaceId: workspaceId,
      board: board,
      boardId: boardId,
    );
  }

  @override
  List<Object?> get props => [status, action, error, workspaceId, board, boardId];
}
