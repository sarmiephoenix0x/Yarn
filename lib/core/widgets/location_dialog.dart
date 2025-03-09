import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void showLocationDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openAppSettings(); // Open app settings
            },
            child: Text("Settings", style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}
