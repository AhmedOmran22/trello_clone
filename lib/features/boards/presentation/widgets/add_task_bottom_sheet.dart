import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../utils/date_formatter.dart';

Future<void> showAddTaskBottomSheet(
  BuildContext context, {
  required String columnName,
  void Function(String title, String? description, String priority, DateTime? dueDate)?
      onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AddTaskBottomSheet(columnName: columnName, onSubmit: onSubmit),
  );
}

class _AddTaskBottomSheet extends StatefulWidget {
  const _AddTaskBottomSheet({required this.columnName, this.onSubmit});

  final String columnName;
  final void Function(String title, String? description, String priority, DateTime? dueDate)?
      onSubmit;

  @override
  State<_AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<_AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'medium';
  DateTime? _dueDate;

  static const _priorities = ['low', 'medium', 'high', 'urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return AppColors.priorityUrgent;
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
      default:
        return AppColors.priorityLow;
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final description = _descriptionController.text.trim();
    widget.onSubmit?.call(
      title,
      description.isEmpty ? null : description,
      _priority,
      _dueDate,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
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
              Text('Add Task', style: context.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Adding to ${widget.columnName}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Task title'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Add description...'),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text('Priority', style: context.textTheme.bodyMedium),
              const SizedBox(height: AppTheme.spacingSm),
              Wrap(
                spacing: 8,
                children: _priorities.map((priority) {
                  final selected = _priority == priority;
                  final color = _priorityColor(priority);
                  return ChoiceChip(
                    label: Text(priority[0].toUpperCase() + priority.substring(1)),
                    selected: selected,
                    onSelected: (_) => setState(() => _priority = priority),
                    selectedColor: color,
                    labelStyle: TextStyle(
                      color: selected
                          ? (priority == 'high' ? Colors.black87 : Colors.white)
                          : context.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: color.withValues(alpha: 0.15),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              InkWell(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
                onTap: _pickDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(_dueDate == null ? 'No due date' : DateFormatter.long(_dueDate!)),
                      const Spacer(),
                      if (_dueDate != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _dueDate = null),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _titleController.text.trim().isEmpty ? null : _submit,
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
