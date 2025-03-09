import 'package:flutter/material.dart';

void showSignInErrorDialog(Object error, BuildContext context,
    void Function(bool) setIsGoogleLoading) {
  setIsGoogleLoading(false);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign-in Error'),
      content: Text('Failed to sign in: $error'),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
