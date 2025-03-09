import 'package:flutter/material.dart';

void showMediaOptions(BuildContext context, Future<void> Function() pickImage,
    Future<void> Function() pickVideo) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.image, color: Colors.purple),
            title: Text('Image'),
            onTap: () async {
              Navigator.pop(context); // Close the sheet
              await pickImage();
            },
          ),
          ListTile(
            leading: Icon(Icons.videocam, color: Colors.red),
            title: Text('Video'),
            onTap: () async {
              Navigator.pop(context); // Close the sheet
              await pickVideo();
            },
          ),
        ],
      );
    },
  );
}
