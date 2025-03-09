import 'package:flutter/material.dart';

void showPostCategorySheet(
    BuildContext context, void Function(String) setPostCategory) {
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
            'Choose Yarn Category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: Icon(Icons.info,
              color: Colors.blue), // Calmer icon for Information
          title: const Text('Announcement'),
          onTap: () {
            setPostCategory('announcement');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.warning,
              color: Colors.orange), // Warning icon for Alert/Emergency
          title: const Text('Warning'),
          onTap: () {
            setPostCategory('warning');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.warning,
              color: Colors.red), // Warning icon for Alert/Emergency
          title: const Text('Alert'),
          onTap: () {
            setPostCategory('alert');
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
