import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the notification plugin
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show a notification based on the post type
  Future<void> showNotification(String title, String body, String type) async {
    var androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.blue,
    );

    var details = NotificationDetails(android: androidDetails);

    // Trigger notification if the type is alert, warning, or announcement
    if (type == 'alert' || type == 'warning' || type == 'announcement') {
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        details,
        payload: type, // Pass the post type for further handling (optional)
      );
    }
  }
}
