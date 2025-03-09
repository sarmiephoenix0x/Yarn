import 'package:flutter/material.dart';

import 'bottom_sheets/anonymous_option_sheet.dart';

class AnonymousSwitch extends StatelessWidget {
  final bool isAnonymous;
  final BuildContext context;
  final void Function(bool) setIsAnonymous;

  const AnonymousSwitch({
    super.key,
    required this.isAnonymous,
    required this.context,
    required this.setIsAnonymous,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Privacy'),
      subtitle: Text(
        isAnonymous ? 'Yarn as Anonymous' : 'Yarn with Identity',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      trailing: IconButton(
        icon: Icon(
          isAnonymous
              ? Icons.visibility_off
              : Icons.visibility, // Change icon based on privacy state
        ),
        onPressed: () => showAnonymousOptionSheet(context, setIsAnonymous),
      ),
      onTap: () => showAnonymousOptionSheet(
          context, setIsAnonymous), // Show dialog on tap
    );
  }
}
