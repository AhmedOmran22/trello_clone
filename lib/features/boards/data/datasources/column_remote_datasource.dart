import '../models/board_column_model.dart';

abstract class ColumnRemoteDatasource {
  Future<BoardColumnModel> createColumn({
    required String boardId,
    required String name,
    required int position,
  });

  Future<BoardColumnModel> renameColumn({required String columnId, required String name});

  Future<void> reorderColumns({required List<Map<String, dynamic>> columns});

  Future<void> deleteColumn({required String columnId});

  // ── Real-time Streams ──
  Stream<List<BoardColumnModel>> watchColumns({required String boardId});
}
