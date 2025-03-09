import 'package:flutter/material.dart';

void showTimeoutDialog(
    BuildContext context, Future<void> Function(BuildContext) refresh) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Request Timed Out'),
        content: const Text(
          'The operation took too long to complete. Please try again later.',
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Retry', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.of(context).pop();
              refresh(context);
            },
          ),
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
