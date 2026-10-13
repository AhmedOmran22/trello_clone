import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/subabase_services.dart';
import '../models/board_column_model.dart';
import 'column_remote_datasource.dart';

class ColumnSupabaseDatasource implements ColumnRemoteDatasource {
  final SupabaseServices services;

  ColumnSupabaseDatasource(this.services);

  @override
  Future<BoardColumnModel> createColumn({
    required String boardId,
    required String name,
    required int position,
  }) async {
    try {
      final response = await services.insert(SupabaseTables.boardColumns, {
        'board_id': boardId,
        'name': name,
        'position': position,
      });

      return BoardColumnModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<BoardColumnModel> renameColumn({
    required String columnId,
    required String name,
  }) async {
    try {
      final response = await services.update(SupabaseTables.boardColumns, columnId, {
        'name': name,
      });

      return BoardColumnModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<void> reorderColumns({required List<Map<String, dynamic>> columns}) async {
    try {
      for (final column in columns) {
        await services.update(SupabaseTables.boardColumns, column['id'] as String, {
          'position': column['position'],
        });
      }
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<void> deleteColumn({required String columnId}) async {
    try {
      await services.delete(SupabaseTables.boardColumns, columnId);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  // ── Real-time Streams ──

  @override
  Stream<List<BoardColumnModel>> watchColumns({required String boardId}) {
    return services.client
        .from(SupabaseTables.boardColumns)
        .stream(primaryKey: ['id'])
        .eq('board_id', boardId)
        .map(
          (data) =>
              data.map((json) => BoardColumnModel.fromJson(json)).toList()
                ..sort((a, b) => a.position.compareTo(b.position)),
        );
  }
}
