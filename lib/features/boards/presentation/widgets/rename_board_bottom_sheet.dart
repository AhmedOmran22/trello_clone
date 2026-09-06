import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../workspace/presentation/widgets/shared/bottom_sheet_drag_handle.dart';

/// Shows the Rename Board bottom sheet, pre-filled with [currentName].
/// Closes itself, then invokes [onSave] with the trimmed new name so the
/// caller can dispatch the real rename (via BoardCubit.updateBoard).
Future<void> showRenameBoardBottomSheet(
  BuildContext context, {
  required String currentName,
  void Function(String newName)? onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.borderRadiusXl),
      ),
    ),
    builder: (_) => RenameBoardBottomSheet(currentName: currentName, onSave: onSave),
  );
}

class RenameBoardBottomSheet extends StatefulWidget {
  final String currentName;
  final void Function(String newName)? onSave;

  const RenameBoardBottomSheet({super.key, required this.currentName, this.onSave});

  @override
  State<RenameBoardBottomSheet> createState() => _RenameBoardBottomSheetState();
}

class _RenameBoardBottomSheetState extends State<RenameBoardBottomSheet> {
  static const _maxNameLength = 50;

  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  bool get _isValid {
    final trimmed = _controller.text.trim();
    return trimmed.isNotEmpty && trimmed != widget.currentName;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_isValid) return;
    final newName = _controller.text.trim();
    Navigator.of(context).pop();
    widget.onSave?.call(newName);
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
                'Rename Board',
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
                decoration: const InputDecoration(hintText: 'Board name'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _handleSave(),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid ? _handleSave : null,
                  child: const Text('Save'),
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
