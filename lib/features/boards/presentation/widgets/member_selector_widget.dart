import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../workspace/domain/entity/workspace_member_entity.dart';

/// Tappable "Assignee" field — shows the current selection and opens a
/// bottom sheet to change it. Reused by the add-task and task-detail sheets.
class MemberSelectorWidget extends StatelessWidget {
  const MemberSelectorWidget({
    super.key,
    required this.members,
    this.selectedUserId,
    this.onSelected,
    this.label = 'Assignee',
  });

  final List<WorkspaceMemberEntity> members;
  final String? selectedUserId;
  final void Function(String? userId)? onSelected;
  final String label;

  WorkspaceMemberEntity? _selectedMember() {
    final userId = selectedUserId;
    if (userId == null) return null;
    for (final member in members) {
      if (member.userId == userId) return member;
    }
    return null;
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MemberPickerSheet(
        members: members,
        selectedUserId: selectedUserId,
        label: label,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedMember();
    final subtleColor = context.colorScheme.onSurface.withValues(alpha: 0.5);

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      onTap: () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        ),
        child: Row(
          children: [
            if (selected != null)
              _MemberAvatar(member: selected, radius: 12)
            else
              Icon(Icons.person_outline, size: 20, color: subtleColor),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                selected?.fullName ?? 'Unassigned',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: selected == null ? subtleColor : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20, color: subtleColor),
          ],
        ),
      ),
    );
  }
}

class _MemberPickerSheet extends StatelessWidget {
  const _MemberPickerSheet({
    required this.members,
    required this.selectedUserId,
    required this.label,
    this.onSelected,
  });

  final List<WorkspaceMemberEntity> members;
  final String? selectedUserId;
  final String label;
  final void Function(String? userId)? onSelected;

  void _select(BuildContext context, String? userId) {
    onSelected?.call(userId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              child: Text(label, style: context.textTheme.titleLarge),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            ListTile(
              leading: Icon(
                Icons.person_outline,
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              title: const Text('Unassigned'),
              trailing: selectedUserId == null
                  ? Icon(Icons.check, color: context.colorScheme.primary)
                  : null,
              onTap: () => _select(context, null),
            ),
            const Divider(height: 1),
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Text(
                  'No workspace members to assign.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isSelected = member.userId == selectedUserId;
                    return ListTile(
                      leading: _MemberAvatar(member: member, radius: 16),
                      title: Text(member.fullName),
                      subtitle: Text(member.email),
                      trailing: isSelected
                          ? Icon(Icons.check, color: context.colorScheme.primary)
                          : null,
                      onTap: () => _select(context, member.userId),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, required this.radius});

  final WorkspaceMemberEntity member;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = member.avatarUrl;

    return CircleAvatar(
      radius: radius,
      backgroundColor: context.colorScheme.primary,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? Text(
              member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.8,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}
