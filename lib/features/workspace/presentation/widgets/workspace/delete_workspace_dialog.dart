import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';

/// Shows the Delete Workspace confirmation dialog for [workspaceName].
/// UI only — [onConfirm] is invoked when the user confirms deletion so the
/// caller can wire up the real delete logic later.
Future<void> showDeleteWorkspaceDialog(
  BuildContext context, {
  required String workspaceName,
  VoidCallback? onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (_) =>
        DeleteWorkspaceDialog(workspaceName: workspaceName, onConfirm: onConfirm),
  );
}

class DeleteWorkspaceDialog extends StatelessWidget {
  final String workspaceName;
  final VoidCallback? onConfirm;

  const DeleteWorkspaceDialog({
    super.key,
    required this.workspaceName,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: context.colorScheme.error,
        size: 36,
      ),
      title: const Text('Delete Workspace'),
      content: RichText(
        text: TextSpan(
          style: context.textTheme.bodyMedium,
          children: [
            const TextSpan(text: 'Are you sure you want to delete '),
            TextSpan(
              text: workspaceName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text:
                  '? This will permanently delete all boards, columns, and '
                  'tasks inside it. This action cannot be undone.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.error,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
