import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/subabase_services.dart';
import '../models/search_result_model.dart';
import 'search_remote_datasource.dart';

class SearchSupabaseDatasource implements SearchRemoteDatasource {
  final SupabaseServices services;

  SearchSupabaseDatasource(this.services);

  @override
  Future<List<SearchResultModel>> search({required String query}) async {
    try {
      final userId = services.client.auth.currentUser!.id;
      final searchPattern = '%$query%';

      // Tasks have no direct workspace_id, and PostgREST can't filter a
      // search across three tables in one call — so we scope every query to
      // the caller's own workspaces ourselves rather than relying on RLS
      // alone to narrow the result set.
      final memberResponse = await services.client
          .from(SupabaseTables.workspaceMembers)
          .select('workspace_id')
          .eq('user_id', userId);

      final workspaceIds = memberResponse.map((row) => row['workspace_id'] as String).toList();

      if (workspaceIds.isEmpty) return [];

      final results = await Future.wait([
        services.client
            .from(SupabaseTables.workspaces)
            .select()
            .inFilter('id', workspaceIds)
            .ilike('name', searchPattern)
            .limit(5),
        services.client
            .from(SupabaseTables.boards)
            .select('*, workspaces(name)')
            .inFilter('workspace_id', workspaceIds)
            .ilike('name', searchPattern)
            .limit(10),
        services.client
            .from(SupabaseTables.tasks)
            .select(
              '*, board_columns!inner(name, board_id, boards!inner(name, workspace_id))',
            )
            .ilike('title', searchPattern)
            .limit(20),
      ]);

      final workspaces = results[0]
          .map((json) => SearchResultModel.fromWorkspaceJson(json))
          .toList();

      final boards = results[1].map((json) => SearchResultModel.fromBoardJson(json)).toList();

      // The tasks query can't filter by workspace directly (no workspace_id
      // column on tasks), so the workspace check happens here instead.
      final tasks = results[2]
          .where((json) {
            final board = (json['board_columns'] as Map<String, dynamic>?)?['boards']
                as Map<String, dynamic>?;
            return board != null && workspaceIds.contains(board['workspace_id']);
          })
          .map((json) => SearchResultModel.fromTaskJson(json))
          .toList();

      return [...workspaces, ...boards, ...tasks];
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }
}
