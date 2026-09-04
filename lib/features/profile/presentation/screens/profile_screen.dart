import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entity/user_entity.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.user, required this.onLogout});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: dialogContext.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = context.colorScheme.error;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(user: user),
          const SizedBox(height: AppTheme.spacingLg),
          _ProfileSection(
            title: 'Account',
            children: [
              ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Name, email, avatar',
              ),
              ProfileMenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
              ),
            ],
          ),
          _ProfileSection(
            title: 'Preferences',
            children: [
              const ProfileMenuItem(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: 'System default',
                trailing: Chip(
                  label: Text('System'),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const ProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notifications',
              ),
              const ProfileMenuItem(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English',
              ),
            ],
          ),
          _ProfileSection(
            title: 'About',
            children: [
              const ProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
              ),
              const ProfileMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
              ),
              const ProfileMenuItem(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
              ),
            ],
          ),
          _ProfileSection(
            children: [
              ProfileMenuItem(
                icon: Icons.logout,
                title: 'Log Out',
                color: errorColor,
                onTap: () => _confirmLogout(context),
              ),
              ProfileMenuItem(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                color: errorColor,
                onTap: () => context.showSnackBar('Coming soon'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _ProfileSection({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                0,
                AppTheme.spacingLg,
                AppTheme.spacingSm,
              ),
              child: Text(
                title!,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, indent: AppTheme.spacingLg),
          ],
        ],
      ),
    );
  }
}
