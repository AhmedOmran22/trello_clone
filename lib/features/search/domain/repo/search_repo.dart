import '../../../../core/utils/result.dart';
import '../entity/search_result_entity.dart';

abstract class SearchRepo {
  Future<Result<List<SearchResultEntity>>> search({required String query});
}
