import 'package:equatable/equatable.dart';

import '../../domain/entity/search_result_entity.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<SearchResultEntity> results;
  final List<String> recentSearches;
  final String query;
  final String? error;

  const SearchState({
    this.status = SearchStatus.initial,
    this.results = const [],
    this.recentSearches = const [],
    this.query = '',
    this.error,
  });

  List<SearchResultEntity> get workspaceResults =>
      results.where((r) => r.type == SearchResultType.workspace).toList();

  List<SearchResultEntity> get boardResults =>
      results.where((r) => r.type == SearchResultType.board).toList();

  List<SearchResultEntity> get taskResults =>
      results.where((r) => r.type == SearchResultType.task).toList();

  bool get hasResults => results.isNotEmpty;

  SearchState copyWith({
    SearchStatus? status,
    List<SearchResultEntity>? results,
    List<String>? recentSearches,
    String? query,
    String? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, results, recentSearches, query, error];
}
