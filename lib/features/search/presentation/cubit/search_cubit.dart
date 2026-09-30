import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/search_usecase.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchUseCase searchUseCase;
  Timer? _debounceTimer;

  SearchCubit({required this.searchUseCase}) : super(const SearchState());

  void onQueryChanged(String query) {
    emit(state.copyWith(query: query));

    _debounceTimer?.cancel();

    if (query.trim().length < 2) {
      emit(state.copyWith(status: SearchStatus.initial, results: const []));
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    emit(state.copyWith(status: SearchStatus.loading));

    final result = await searchUseCase(query: query);

    result.when(
      success: (results) {
        emit(state.copyWith(status: SearchStatus.loaded, results: results));
        _addToRecent(query);
      },
      error: (failure) =>
          emit(state.copyWith(status: SearchStatus.error, error: failure.message)),
    );
  }

  void _addToRecent(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ...state.recentSearches.where((s) => s != trimmed),
    ].take(5).toList();

    emit(state.copyWith(recentSearches: updated));
  }

  void searchFromRecent(String query) {
    emit(state.copyWith(query: query));
    _performSearch(query);
  }

  /// Re-runs the last query immediately (no debounce) — used by the error
  /// view's Retry button, where the user has already explicitly asked to
  /// try again.
  void retry() {
    final query = state.query;
    if (query.trim().length < 2) return;
    _performSearch(query);
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    // Reset the query/results, but keep the recent-searches history — that
    // has its own explicit clearRecentSearches() below.
    emit(SearchState(recentSearches: state.recentSearches));
  }

  void clearRecentSearches() {
    emit(state.copyWith(recentSearches: const []));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
