import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entity/user_entity.dart';

enum AvatarAction { takePhoto, chooseFromGallery, removePhoto }

class ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final bool isUploadingAvatar;
  final ValueChanged<AvatarAction> onAvatarAction;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isUploadingAvatar,
    required this.onAvatarAction,
    required this.onEditProfile,
  });

  Future<void> _showAvatarOptions(BuildContext context) async {
    final action = await showModalBottomSheet<AvatarAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(sheetContext, AvatarAction.takePhoto),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(sheetContext, AvatarAction.chooseFromGallery),
            ),
            if (user.avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => Navigator.pop(sheetContext, AvatarAction.removePhoto),
              ),
          ],
        ),
      ),
    );

    if (action != null) onAvatarAction(action);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final avatarUrl = user.avatarUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingXl,
      ),
      color: colorScheme.primary.withValues(alpha: 0.06),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: colorScheme.primary,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (isUploadingAvatar)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black45,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                  child: InkWell(
                    onTap: isUploadingAvatar ? null : () => _showAvatarOptions(context),
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.camera_alt, size: 16, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            user.fullName,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingSm / 2),
          Text(
            user.email,
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          TextButton(onPressed: onEditProfile, child: const Text('Edit Profile')),
        ],
      ),
    );
  }
}
