import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/domain/entity/user_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/edit_profile_bottom_sheet.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/theme_selector_bottom_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _comingSoon = 'Coming soon';

  String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System default',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  void _openEditProfile(BuildContext context, UserEntity user) {
    showEditProfileBottomSheet(context, currentName: user.fullName);
  }

  Future<void> _handleAvatarAction(BuildContext context, AvatarAction action) async {
    final cubit = context.read<ProfileCubit>();

    switch (action) {
      case AvatarAction.takePhoto:
        await _pickAndUpload(context, cubit, ImageSource.camera);
      case AvatarAction.chooseFromGallery:
        await _pickAndUpload(context, cubit, ImageSource.gallery);
      case AvatarAction.removePhoto:
        await cubit.removeAvatar();
    }
  }

  Future<void> _pickAndUpload(
    BuildContext context,
    ProfileCubit cubit,
    ImageSource source,
  ) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return; // user cancelled

      await cubit.uploadAvatar(filePath: picked.path);
    } on PlatformException {
      if (!context.mounted) return;
      context.showErrorSnackBar(
        source == ImageSource.camera
            ? 'Could not open the camera. Check the app permissions.'
            : 'Could not open your photos. Check the app permissions.',
      );
    }
  }

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

    if (confirmed == true && context.mounted) {
      context.read<SessionCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = context.colorScheme.error;
    final themeMode = context.select((ThemeCubit cubit) => cubit.state.themeMode);

    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          current.error != null && current.error != previous.error,
      listener: (context, state) => context.showErrorSnackBar(state.error!),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(
                  user: user,
                  isUploadingAvatar: state.isUploadingAvatar,
                  onAvatarAction: (action) => _handleAvatarAction(context, action),
                  onEditProfile: () => _openEditProfile(context, user),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                _ProfileSection(
                  title: 'Account',
                  children: [
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: 'Name and photo',
                      onTap: () => _openEditProfile(context, user),
                    ),
                    ProfileMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      subtitle: 'Update your password',
                      onTap: () => context.showSnackBar(_comingSoon),
                    ),
                  ],
                ),
                _ProfileSection(
                  title: 'Preferences',
                  children: [
                    ProfileMenuItem(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      subtitle: _themeLabel(themeMode),
                      onTap: () => showThemeSelectorBottomSheet(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () => context.showSnackBar(_comingSoon),
                    ),
                  ],
                ),
                _ProfileSection(
                  title: 'About',
                  children: [
                    ProfileMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => context.showSnackBar(_comingSoon),
                    ),
                    ProfileMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => context.showSnackBar(_comingSoon),
                    ),
                    ProfileMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'Version 1.0.0',
                      onTap: () => context.showSnackBar(_comingSoon),
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
                      color: errorColor,
                      onTap: () => context.showSnackBar(_comingSoon),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLg),
              ],
            ),
          );
        },
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
