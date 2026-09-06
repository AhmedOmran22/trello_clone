import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_board_usecase.dart';
import '../../domain/usecases/delete_board_usecase.dart';
import '../../domain/usecases/update_board_usecase.dart';
import 'board_state.dart';

class BoardCubit extends Cubit<BoardState> {
  final CreateBoardUseCase createBoardUseCase;
  final UpdateBoardUseCase updateBoardUseCase;
  final DeleteBoardUseCase deleteBoardUseCase;

  BoardCubit({
    required this.createBoardUseCase,
    required this.updateBoardUseCase,
    required this.deleteBoardUseCase,
  }) : super(const BoardState());

  Future<void> createBoard({
    required String workspaceId,
    required String name,
  }) async {
    emit(state.copyWith(status: BoardStatus.loading));

    final result = await createBoardUseCase(workspaceId: workspaceId, name: name);

    result.when(
      success: (board) => emit(
        state.copyWith(
          status: BoardStatus.success,
          action: BoardAction.created,
          workspaceId: workspaceId,
          board: board,
        ),
      ),
      error: (failure) => emit(
        state.copyWith(status: BoardStatus.error, error: failure.message),
      ),
    );
  }

  Future<void> updateBoard({
    required String id,
    required String name,
    required String workspaceId,
  }) async {
    final result = await updateBoardUseCase(id: id, name: name);

    result.when(
      success: (board) => emit(
        state.copyWith(
          status: BoardStatus.success,
          action: BoardAction.updated,
          workspaceId: workspaceId,
          board: board,
        ),
      ),
      error: (failure) => emit(
        state.copyWith(status: BoardStatus.error, error: failure.message),
      ),
    );
  }

  Future<void> deleteBoard({
    required String id,
    required String workspaceId,
  }) async {
    final result = await deleteBoardUseCase(id: id);

    result.when(
      success: (_) => emit(
        state.copyWith(
          status: BoardStatus.success,
          action: BoardAction.deleted,
          workspaceId: workspaceId,
          boardId: id,
        ),
      ),
      error: (failure) => emit(
        state.copyWith(status: BoardStatus.error, error: failure.message),
      ),
    );
  }
}
