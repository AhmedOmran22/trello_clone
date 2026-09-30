import '../models/search_result_model.dart';

abstract class SearchRemoteDatasource {
  Future<List<SearchResultModel>> search({required String query});
}
