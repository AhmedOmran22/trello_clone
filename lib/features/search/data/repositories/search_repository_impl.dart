import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/search_result_entity.dart';
import '../../domain/repo/search_repo.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepo {
  final SearchRemoteDatasource datasource;

  SearchRepositoryImpl(this.datasource);

  @override
  Future<Result<List<SearchResultEntity>>> search({required String query}) async {
    try {
      final models = await datasource.search(query: query);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Result.error(mapExceptionToFailure(e));
    }
  }
}
