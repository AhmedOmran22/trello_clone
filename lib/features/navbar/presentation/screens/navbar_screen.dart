import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../notifications/presentation/cubits/notification_cubit.dart';
import '../../../notifications/presentation/cubits/notification_state.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../search/presentation/cubit/search_cubit.dart';
import '../../../search/presentation/cubit/search_state.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../workspace/presentation/screens/workspace_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class NavbarScreen extends StatefulWidget {
  const NavbarScreen({super.key});

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();

  static const int _searchTabIndex = 1;
  static const int _notificationsTabIndex = 2;

  static const List<String> _appBarTitles = [
    'WorkSpaces',
    'Search',
    'Notifications',
    'Profile',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Rebuilds the AppBar so the suffix clear icon reflects the new text.
    setState(() {});
    context.read<SearchCubit>().onQueryChanged(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    context.read<SearchCubit>().clearSearch();
  }

  Widget _buildTitle() {
    if (_currentIndex != _searchTabIndex) {
      return Text(_appBarTitles[_currentIndex]);
    }

    final foreground = Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;

    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search workspaces, boards, tasks...',
        hintStyle: TextStyle(color: foreground.withValues(alpha: 0.6)),
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: foreground.withValues(alpha: 0.8)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: foreground.withValues(alpha: 0.8)),
                onPressed: _clearSearch,
              )
            : null,
      ),
      style: TextStyle(color: foreground, fontSize: 16),
      cursorColor: foreground,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) setState(() => _currentIndex = 0);
      },
      child: BlocListener<SearchCubit, SearchState>(
        // Keeps the AppBar's field in sync with changes that didn't come from
        // typing in it (tapping a recent search, clearing from the cubit).
        listenWhen: (previous, current) =>
            current.query != previous.query && current.query != _searchController.text,
        listener: (context, state) => setState(() => _searchController.text = state.query),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: _buildTitle(),
            actions: _currentIndex == _notificationsTabIndex
                ? [
                    BlocBuilder<NotificationCubit, NotificationState>(
                      builder: (context, state) {
                        if (state.unreadCount == 0) return const SizedBox.shrink();
                        return TextButton(
                          onPressed: () =>
                              context.read<NotificationCubit>().markAllAsRead(),
                          child: const Text('Mark all as read'),
                        );
                      },
                    ),
                  ]
                : null,
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              const WorkspaceScreen(),
              SearchScreen(onCloseSearch: () => setState(() => _currentIndex = 0)),
              const NotificationsScreen(),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }
}
