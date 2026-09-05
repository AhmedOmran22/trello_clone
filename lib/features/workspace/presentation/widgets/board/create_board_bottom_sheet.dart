import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

/// Shows the Create Board bottom sheet for [workspaceName].
/// UI only — [onSubmit] is invoked with the trimmed board name so the
/// caller can wire up real board creation later.
Future<void> showCreateBoardBottomSheet(
  BuildContext context, {
  required String workspaceName,
  void Function(String boardName)? onSubmit,
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
        CreateBoardBottomSheet(workspaceName: workspaceName, onSubmit: onSubmit),
  );
}

class CreateBoardBottomSheet extends StatefulWidget {
  final String workspaceName;
  final void Function(String boardName)? onSubmit;

  const CreateBoardBottomSheet({
    super.key,
    required this.workspaceName,
    this.onSubmit,
  });

  @override
  State<CreateBoardBottomSheet> createState() =>
      _CreateBoardBottomSheetState();
}

class _CreateBoardBottomSheetState extends State<CreateBoardBottomSheet> {
  static const _maxBoardNameLength = 50;

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
    widget.onSubmit?.call(_controller.text.trim());
    Navigator.of(context).pop();
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
              Text(
                'Create Board',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm / 2),
              Text(
                'Create board in ${widget.workspaceName}',
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                maxLength: _maxBoardNameLength,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'Board name'),
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
