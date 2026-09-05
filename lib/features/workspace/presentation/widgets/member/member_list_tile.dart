import 'package:flutter/material.dart';

import '../../../../../core/constants/context_extensions.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entity/workspace_member_entity.dart';

class MemberListTile extends StatelessWidget {
  final WorkspaceMemberEntity member;
  final bool canRemove;
  final VoidCallback? onRemove;

  const MemberListTile({
    super.key,
    required this.member,
    this.canRemove = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm / 2),
      child: Row(
        children: [
          _Avatar(member: member),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  member.email,
                  style: context.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _RoleBadge(isOwner: member.isOwner),
          if (canRemove) ...[
            const SizedBox(width: AppTheme.spacingSm / 2),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close),
              iconSize: 18,
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Remove member',
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final WorkspaceMemberEntity member;

  const _Avatar({required this.member});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = member.avatarUrl != null && member.avatarUrl!.isNotEmpty;
    return CircleAvatar(
      radius: 20,
      backgroundColor: context.colorScheme.primary.withValues(alpha: 0.15),
      backgroundImage: hasAvatar ? NetworkImage(member.avatarUrl!) : null,
      child: hasAvatar
          ? null
          : Text(
              member.fullName.isNotEmpty
                  ? member.fullName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isOwner;

  const _RoleBadge({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isOwner
        ? context.colorScheme.primary.withValues(alpha: 0.12)
        : context.colorScheme.onSurface.withValues(alpha: 0.08);
    final textColor = isOwner
        ? context.colorScheme.primary
        : context.colorScheme.onSurface.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXl),
      ),
      child: Text(
        isOwner ? 'Owner' : 'Member',
        style: context.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
