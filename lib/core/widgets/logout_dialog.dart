import 'package:flutter/material.dart';

void showLogoutDialog(
    BuildContext context, void Function(BuildContext) onLogout) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      bool isLoading = false; // Local state variable inside dialog

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              Row(
                children: [
                  TextButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Inter',
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                  const Spacer(),
                  isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () async {
                            setState(() => isLoading = true);

                            try {
                              onLogout(context);
                            } catch (e) {
                              print("Logout failed: $e");
                              setState(() => isLoading = false);
                            } finally {
                              setState(() => isLoading = false);
                              Navigator.of(dialogContext).pop();
                            }
                          },
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
