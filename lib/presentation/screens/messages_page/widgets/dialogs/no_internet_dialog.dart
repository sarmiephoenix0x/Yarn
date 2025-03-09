import 'package:flutter/material.dart';

void showNoConnectionDialog(BuildContext context, bool isDialogOpen) {
  isDialogOpen = true; // Set the flag to true when the dialog is shown
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => AlertDialog(
      title: Text("No Internet Connection"),
      content: Text("You're currently offline. Viewing saved chats."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            isDialogOpen = false; // Reset the flag when the dialog is dismissed
          },
          child: Text("Close"),
        ),
      ],
    ),
  ).then((_) {
    isDialogOpen = false; // Ensure the flag is reset when the dialog is closed
  });
}
