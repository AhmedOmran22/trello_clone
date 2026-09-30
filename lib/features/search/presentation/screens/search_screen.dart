import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/search_result_entity.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/empty_search.dart';
import '../widgets/recent_searches.dart';
import '../widgets/search_result_tile.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key, this.onCloseSearch});

  /// Called when a workspace result is tapped — workspaces have no detail
  /// screen yet, so this just lets the caller close/reset the search UI.
  final VoidCallback? onCloseSearch;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        switch (state.status) {
          case SearchStatus.initial:
            return state.recentSearches.isEmpty
                ? const EmptySearch()
                : RecentSearches(
                    searches: state.recentSearches,
                    onSelect: (term) =>
                        context.read<SearchCubit>().searchFromRecent(term),
                    onClear: () => context.read<SearchCubit>().clearRecentSearches(),
                  );

          case SearchStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case SearchStatus.error:
            return _ErrorView(
              message: state.error ?? 'Something went wrong',
              onRetry: () => context.read<SearchCubit>().retry(),
            );

          case SearchStatus.loaded:
            if (!state.hasResults) return const _NoResultsView();
            return _SearchResultsList(state: state, onCloseSearch: onCloseSearch);
        }
      },
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.state, this.onCloseSearch});

  final SearchState state;
  final VoidCallback? onCloseSearch;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      children: [
        if (state.workspaceResults.isNotEmpty)
          _ResultSection(
            title: 'Workspaces',
            results: state.workspaceResults,
            onWorkspaceTap: onCloseSearch,
          ),
        if (state.boardResults.isNotEmpty)
          _ResultSection(title: 'Boards', results: state.boardResults),
        if (state.taskResults.isNotEmpty)
          _ResultSection(title: 'Tasks', results: state.taskResults),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.title, required this.results, this.onWorkspaceTap});

  final String title;
  final List<SearchResultEntity> results;
  final VoidCallback? onWorkspaceTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            AppTheme.spacingMd,
            AppTheme.spacingMd,
            AppTheme.spacingSm,
          ),
          child: Text(
            title,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        for (var i = 0; i < results.length; i++) ...[
          SearchResultTile(result: results[i], onWorkspaceTap: onWorkspaceTap),
          if (i != results.length - 1)
            const Divider(height: 1, indent: AppTheme.spacingLg),
        ],
      ],
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text('No results found', style: context.textTheme.titleMedium),
            const SizedBox(height: AppTheme.spacingSm / 2),
            Text(
              'Try a different search term',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
            const SizedBox(height: AppTheme.spacingMd),
            Text(message, textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
