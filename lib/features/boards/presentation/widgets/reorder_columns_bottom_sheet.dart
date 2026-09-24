import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/board_column_entity.dart';

Future<void> showReorderColumnsBottomSheet(
  BuildContext context, {
  required List<BoardColumnEntity> columns,
  void Function(List<BoardColumnEntity> newOrder)? onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ReorderColumnsBottomSheet(columns: columns, onSave: onSave),
  );
}

class _ReorderColumnsBottomSheet extends StatefulWidget {
  const _ReorderColumnsBottomSheet({required this.columns, this.onSave});

  final List<BoardColumnEntity> columns;
  final void Function(List<BoardColumnEntity> newOrder)? onSave;

  @override
  State<_ReorderColumnsBottomSheet> createState() => _ReorderColumnsBottomSheetState();
}

class _ReorderColumnsBottomSheetState extends State<_ReorderColumnsBottomSheet> {
  late List<BoardColumnEntity> _columns;

  @override
  void initState() {
    super.initState();
    _columns = List.of(widget.columns);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final column = _columns.removeAt(oldIndex);
      _columns.insert(newIndex, column);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.screenHeight * 0.7,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingSm),
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
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Text('Reorder Columns', style: context.textTheme.titleLarge),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                itemCount: _columns.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final column = _columns[index];
                  return ListTile(
                    key: ValueKey(column.id),
                    leading: const Icon(Icons.drag_handle),
                    title: Text(column.name),
                    trailing: Text(
                      '${column.tasks.length}',
                      style: context.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave?.call(_columns);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
