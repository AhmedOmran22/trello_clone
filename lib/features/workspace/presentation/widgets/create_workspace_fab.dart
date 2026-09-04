import 'package:flutter/material.dart';

class CreateWorkspaceFab extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateWorkspaceFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('Create Workspace'),
    );
  }
}
