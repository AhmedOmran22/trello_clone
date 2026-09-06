import '../../../../core/utils/result.dart';
import '../entity/board_entity.dart';

abstract class BoardRepo {
  Future<Result<BoardEntity>> createBoard({
    required String workspaceId,
    required String name,
  });

  Future<Result<BoardEntity>> updateBoard({required String id, required String name});

  Future<Result<void>> deleteBoard({required String id});
}
