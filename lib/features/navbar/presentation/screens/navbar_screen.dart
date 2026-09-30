import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../notifications/presentation/cubits/notification_cubit.dart';
import '../../../notifications/presentation/cubits/notification_state.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
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

  static const int _notificationsTabIndex = 2;

  static const List<String> _appBarTitles = [
    'WorkSpaces',
    'Search',
    'Notifications',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(_appBarTitles[_currentIndex]),
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
          children: const [
            WorkspaceScreen(),
            SearchScreen(),
            NotificationsScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
