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

  const BoardLoaded({
    required this.boardId,
    required this.boardName,
    required this.columns,
  });

  BoardLoaded copyWith({
    String? boardId,
    String? boardName,
    List<BoardColumnEntity>? columns,
  }) {
    return BoardLoaded(
      boardId: boardId ?? this.boardId,
      boardName: boardName ?? this.boardName,
      columns: columns ?? this.columns,
    );
  }

  @override
  List<Object?> get props => [boardId, boardName, columns];
}

class BoardError extends BoardState {
  final String message;

  const BoardError({required this.message});

  @override
  List<Object?> get props => [message];
}
