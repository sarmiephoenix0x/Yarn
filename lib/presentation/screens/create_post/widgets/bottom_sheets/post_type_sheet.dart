import 'package:flutter/material.dart';

void showPostTypeSheet(
    BuildContext context, void Function(String) setPostType) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
            title: const Text(
          'Choose Yarn Type',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        ...['timeline', 'page', 'community'].map((type) => ListTile(
              title: Text('Yarn to $type'),
              onTap: () {
                setPostType(type);
                Navigator.pop(context);
              },
            )),
      ],
    ),
  );
}
