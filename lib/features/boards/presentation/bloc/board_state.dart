import 'package:equatable/equatable.dart';

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
  final List<BoardColumnEntity> columns;

  /// Message for the most recent failed write (create/rename/move/...), so
  /// the screen can surface it as a snackbar without leaving [BoardLoaded].
  /// Cleared on the next emission unless explicitly passed again.
  final String? actionError;

  const BoardLoaded({
    required this.boardId,
    required this.boardName,
    required this.columns,
    this.actionError,
  });

  BoardLoaded copyWith({
    String? boardId,
    String? boardName,
    List<BoardColumnEntity>? columns,
    String? actionError,
  }) {
    return BoardLoaded(
      boardId: boardId ?? this.boardId,
      boardName: boardName ?? this.boardName,
      columns: columns ?? this.columns,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [boardId, boardName, columns, actionError];
}

class BoardError extends BoardState {
  final String message;
  final bool isNetworkError;

  const BoardError({required this.message, this.isNetworkError = false});

  @override
  List<Object?> get props => [message, isNetworkError];
}
