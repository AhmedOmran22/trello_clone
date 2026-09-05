import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import 'bottom_sheet_drag_handle.dart';

/// Shows the Create Workspace bottom sheet.
/// [onSubmit] is invoked with the trimmed workspace name; the caller is
/// responsible for closing the sheet once the operation is dispatched.
Future<void> showCreateWorkspaceBottomSheet(
  BuildContext context, {
  void Function(String name)? onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.borderRadiusXl),
      ),
    ),
    builder: (_) => CreateWorkspaceBottomSheet(onSubmit: onSubmit),
  );
}

class CreateWorkspaceBottomSheet extends StatefulWidget {
  final void Function(String name)? onSubmit;

  const CreateWorkspaceBottomSheet({super.key, this.onSubmit});

  @override
  State<CreateWorkspaceBottomSheet> createState() =>
      _CreateWorkspaceBottomSheetState();
}

class _CreateWorkspaceBottomSheetState
    extends State<CreateWorkspaceBottomSheet> {
  static const _maxNameLength = 50;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool get _isValid => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (!_isValid) return;
    final name = _controller.text.trim();
    Navigator.of(context).pop();
    widget.onSubmit?.call(name);
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
                'Create Workspace',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                maxLength: _maxNameLength,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'Workspace name'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _handleCreate(),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid ? _handleCreate : null,
                  child: const Text('Create'),
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm / 2),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
