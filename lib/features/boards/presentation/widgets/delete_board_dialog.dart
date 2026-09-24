import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';

/// Shows the Delete Board confirmation dialog for [boardName].
/// [onConfirm] is invoked when the user confirms deletion so the caller can
/// dispatch the real delete (via BoardCubit.deleteBoard).
Future<void> showDeleteBoardDialog(
  BuildContext context, {
  required String boardName,
  VoidCallback? onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (_) => DeleteBoardDialog(boardName: boardName, onConfirm: onConfirm),
  );
}

class DeleteBoardDialog extends StatelessWidget {
  final String boardName;
  final VoidCallback? onConfirm;

  const DeleteBoardDialog({super.key, required this.boardName, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: context.colorScheme.error,
        size: 36,
      ),
      title: const Text('Delete Board'),
      content: RichText(
        text: TextSpan(
          style: context.textTheme.bodyMedium,
          children: [
            const TextSpan(text: 'Are you sure you want to delete '),
            TextSpan(
              text: boardName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text:
                  '? This will permanently delete all columns and tasks '
                  'inside it. This action cannot be undone.',
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
