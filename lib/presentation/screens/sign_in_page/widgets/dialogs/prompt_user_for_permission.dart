import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void promptUserForPermission(
    PlatformException e,
    BuildContext context,
    void Function(BuildContext) handlePermissionGranted,
    void Function(BuildContext) handlePermissionDenied) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Permission Required'),
      content: Text('Please grant permission to continue: ${e.message}'),
      actions: [
        TextButton(
          child: const Text('Grant Permission'),
          onPressed: () {
            Navigator.pop(context);
            handlePermissionGranted(context);
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
            handlePermissionDenied(context);
          },
        ),
      ],
    ),
  );
}
