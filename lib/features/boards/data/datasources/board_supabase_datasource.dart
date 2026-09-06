import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/subabase_services.dart';
import '../models/board_model.dart';
import 'board_remote_datasource.dart';

class BoardSupabaseDatasource implements BoardRemoteDatasource {
  final SupabaseServices services;

  BoardSupabaseDatasource(this.services);

  @override
  Future<BoardModel> createBoard({
    required String workspaceId,
    required String name,
  }) async {
    try {
      final response = await services.insert(SupabaseTables.boards, {
        'workspace_id': workspaceId,
        'name': name,
      });

      return BoardModel.fromJson(response);
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BoardModel> updateBoard({required String id, required String name}) async {
    try {
      final response = await services.update(SupabaseTables.boards, id, {
        'name': name,
      });

      return BoardModel.fromJson(response);
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteBoard({required String id}) async {
    try {
      await services.delete(SupabaseTables.boards, id);
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }
}
