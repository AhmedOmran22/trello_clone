import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import 'bottom_sheet_drag_handle.dart';

/// Shows the Add Member bottom sheet for [workspaceName].
/// Closes itself, then invokes [onAdd] with the trimmed email so the caller
/// can dispatch the real invite (e.g. via WorkspaceCubit.addMember).
Future<void> showAddMemberBottomSheet(
  BuildContext context, {
  required String workspaceName,
  void Function(String email)? onAdd,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.borderRadiusXl),
      ),
    ),
    builder: (_) =>
        AddMemberBottomSheet(workspaceName: workspaceName, onAdd: onAdd),
  );
}

class AddMemberBottomSheet extends StatefulWidget {
  final String workspaceName;
  final void Function(String email)? onAdd;

  const AddMemberBottomSheet({
    super.key,
    required this.workspaceName,
    this.onAdd,
  });

  @override
  State<AddMemberBottomSheet> createState() => _AddMemberBottomSheetState();
}

class _AddMemberBottomSheetState extends State<AddMemberBottomSheet> {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool get _isValidEmail => _emailRegex.hasMatch(_controller.text.trim());

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (!_isValidEmail) return;
    final email = _controller.text.trim();
    Navigator.of(context).pop();
    widget.onAdd?.call(email);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: BottomSheetDragHandle()),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Add Member',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm / 2),
              Text(
                'Add a member to ${widget.workspaceName}',
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'Enter email address'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _handleAdd(),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValidEmail ? _handleAdd : null,
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
