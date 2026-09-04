import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/session/session_cubit.dart';

class NavBarItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavBarItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const List<NavBarItemData> navBarItems = [
  NavBarItemData(
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    label: 'Boards',
  ),
  NavBarItemData(
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
    label: 'Search',
  ),
  NavBarItemData(
    icon: Icons.notifications_outlined,
    activeIcon: Icons.notifications,
    label: 'Notifications',
  ),
  NavBarItemData(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Me'),
];

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(navBarItems.length, (index) {
              final isProfileTab = index == navBarItems.length - 1;
              final isActive = index == currentIndex;

              return Expanded(
                child: _NavBarTapTarget(
                  isActive: isActive,
                  onTap: () => onTap(index),
                  label: navBarItems[index].label,
                  child: isProfileTab
                      ? _ProfileNavIcon(isActive: isActive)
                      : _NavIcon(item: navBarItems[index], isActive: isActive),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarTapTarget extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final Widget child;
  final String label;

  const _NavBarTapTarget({
    required this.isActive,
    required this.onTap,
    required this.child,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurface.withValues(alpha: 0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            child,
            const SizedBox(height: 2),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final NavBarItemData item;
  final bool isActive;

  const _NavIcon({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurface.withValues(alpha: 0.6);

    return AnimatedScale(
      scale: isActive ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: Icon(
          isActive ? item.activeIcon : item.icon,
          key: ValueKey(isActive),
          color: isActive ? activeColor : inactiveColor,
          size: 24,
        ),
      ),
    );
  }
}

class _ProfileNavIcon extends StatelessWidget {
  final bool isActive;

  const _ProfileNavIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final user = context.watch<SessionCubit>().state.user;
    final avatarUrl = user?.avatarUrl;
    final fullName = user?.fullName ?? '';

    final avatar = CircleAvatar(
      radius: 14,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          : null,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isActive
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
      ),
      padding: const EdgeInsets.all(1),
      child: avatar,
    );
  }
}
