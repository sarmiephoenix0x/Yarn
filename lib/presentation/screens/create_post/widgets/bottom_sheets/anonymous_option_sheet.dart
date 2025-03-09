import 'package:flutter/material.dart';

void showAnonymousOptionSheet(
    BuildContext context, void Function(bool) setIsAnonymous) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
            title: const Text(
          'Choose Privacy Option',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        ListTile(
          title: const Text('Anyone'),
          onTap: () {
            setIsAnonymous(false);
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Anonymous'),
          onTap: () {
            setIsAnonymous(true);
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
