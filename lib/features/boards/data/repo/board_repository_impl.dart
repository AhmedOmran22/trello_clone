import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/board_entity.dart';
import '../../domain/repo/board_repo.dart';
import '../datasources/board_remote_datasource.dart';

class BoardRepositoryImpl implements BoardRepo {
  final BoardRemoteDatasource datasource;

  BoardRepositoryImpl(this.datasource);

  @override
  Future<Result<BoardEntity>> createBoard({
    required String workspaceId,
    required String name,
  }) async {
    try {
      final model = await datasource.createBoard(workspaceId: workspaceId, name: name);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<BoardEntity>> updateBoard({
    required String id,
    required String name,
  }) async {
    try {
      final model = await datasource.updateBoard(id: id, name: name);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteBoard({required String id}) async {
    try {
      await datasource.deleteBoard(id: id);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }
}
