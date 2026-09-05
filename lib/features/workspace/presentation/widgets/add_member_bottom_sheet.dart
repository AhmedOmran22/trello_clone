import 'package:flutter/material.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import 'bottom_sheet_drag_handle.dart';

/// Shows the Add Member bottom sheet for [workspaceName].
/// UI only — [onAdd] is invoked with the trimmed email so the caller can
/// wire up real member invitation later.
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

  bool _isLoading = false;
  String? _errorText;

  bool get _isValidEmail => _emailRegex.hasMatch(_controller.text.trim());

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (!_isValidEmail || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    widget.onAdd?.call(_controller.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);
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
                onChanged: (_) => setState(() => _errorText = null),
                onSubmitted: (_) => _handleAdd(),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isValidEmail && !_isLoading) ? _handleAdd : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Add'),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  _errorText!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
