import '../models/board_model.dart';

abstract class BoardRemoteDatasource {
  Future<BoardModel> createBoard({required String workspaceId, required String name});

  Future<BoardModel> updateBoard({required String id, required String name});

  Future<void> deleteBoard({required String id});
}
