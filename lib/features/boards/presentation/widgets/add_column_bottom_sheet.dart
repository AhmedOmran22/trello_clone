import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';

Future<void> showAddColumnBottomSheet(
  BuildContext context, {
  void Function(String name)? onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AddColumnBottomSheet(onSubmit: onSubmit),
  );
}

class _AddColumnBottomSheet extends StatefulWidget {
  const _AddColumnBottomSheet({this.onSubmit});

  final void Function(String name)? onSubmit;

  @override
  State<_AddColumnBottomSheet> createState() => _AddColumnBottomSheetState();
}

class _AddColumnBottomSheetState extends State<_AddColumnBottomSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onSubmit?.call(name);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Add Column', style: context.textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 50,
                decoration: const InputDecoration(hintText: 'Column name'),
                onSubmitted: (_) => _submit(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _controller.text.trim().isEmpty ? null : _submit,
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
