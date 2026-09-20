import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

Future<void> showEditProfileBottomSheet(
  BuildContext context, {
  required String currentName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EditProfileBottomSheet(currentName: currentName),
  );
}

class _EditProfileBottomSheet extends StatefulWidget {
  const _EditProfileBottomSheet({required this.currentName});

  final String currentName;

  @override
  State<_EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  late final _controller = TextEditingController(text: widget.currentName);

  // ProfileCubit is app-wide, so its status may still hold an earlier save's
  // result — only react to it once this sheet has actually submitted.
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSave {
    final name = _controller.text.trim();
    return name.isNotEmpty && name != widget.currentName;
  }

  void _submit() {
    if (!_canSave) return;
    setState(() => _submitted = true);
    context.read<ProfileCubit>().updateProfile(fullName: _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          _submitted &&
          previous.status == ProfileStatus.loading &&
          current.status == ProfileStatus.success,
      listener: (context, state) => Navigator.pop(context),
      builder: (context, state) {
        final isSaving = _submitted && state.status == ProfileStatus.loading;
        final error = _submitted && state.status == ProfileStatus.error
            ? state.error
            : null;

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
                  Text('Edit Profile', style: context.textTheme.titleLarge),
                  const SizedBox(height: AppTheme.spacingMd),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    enabled: !isSaving,
                    maxLength: 50,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      hintText: 'Your name',
                    ),
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) => setState(() => _submitted = false),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      error,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacingSm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canSave && !isSaving ? _submit : null,
                      child: isSaving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.colorScheme.onPrimary,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
