import '../../../../core/utils/result.dart';
import '../entity/search_result_entity.dart';
import '../repo/search_repo.dart';

class SearchUseCase {
  final SearchRepo repository;

  const SearchUseCase(this.repository);

  Future<Result<List<SearchResultEntity>>> call({required String query}) async {
    final trimmed = query.trim();

    // Don't search on an empty query or a single character — too noisy,
    // and not worth a round trip.
    if (trimmed.length < 2) return Result.success(const []);

    return repository.search(query: trimmed);
  }
}
