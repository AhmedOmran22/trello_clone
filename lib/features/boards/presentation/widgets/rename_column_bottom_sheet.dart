import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

Future<void> showRenameColumnBottomSheet(
  BuildContext context, {
  required String currentName,
  void Function(String newName)? onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _RenameColumnBottomSheet(currentName: currentName, onSave: onSave),
  );
}

class _RenameColumnBottomSheet extends StatefulWidget {
  const _RenameColumnBottomSheet({required this.currentName, this.onSave});

  final String currentName;
  final void Function(String newName)? onSave;

  @override
  State<_RenameColumnBottomSheet> createState() => _RenameColumnBottomSheetState();
}

class _RenameColumnBottomSheetState extends State<_RenameColumnBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName)
      ..selection = TextSelection.collapsed(offset: widget.currentName.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty || name == widget.currentName) return;
    widget.onSave?.call(name);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final name = _controller.text.trim();
    final canSave = name.isNotEmpty && name != widget.currentName;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
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
              Text('Rename Column', style: context.textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 50,
                decoration: const InputDecoration(hintText: 'Column name'),
                onSubmitted: (_) {
                  if (canSave) _submit();
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canSave ? _submit : null,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
