import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/notification_page_controller.dart';
import 'widgets/notification_widget.dart';

class NotificationPage extends StatefulWidget {
  final int selectedIndex;

  const NotificationPage({
    super.key,
    required this.selectedIndex,
  });

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final notificationPageController =
        Provider.of<NotificationPageController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: notificationPageController.notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Color(0xFF500450)),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'An unexpected error occurred',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No notifications available',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              List<Map<String, dynamic>> notifications = snapshot.data!;
              Map<String, List<Map<String, dynamic>>> groupedNotifications = {};

              // Function to parse date with error handling
              DateTime parseDate(String dateString) {
                try {
                  // Attempt to parse the date in ISO 8601 format
                  return DateTime.parse(dateString);
                } catch (e) {
                  // If parsing fails, try the dd/MM/yyyy format
                  try {
                    return DateFormat('dd/MM/yyyy').parse(dateString);
                  } catch (e) {
                    // If all parsing attempts fail, throw an exception or return a default date
                    throw FormatException('Invalid date format: $dateString');
                  }
                }
              }

// Usage in your notification processing loop
              for (var notification in notifications) {
                try {
                  DateTime date = parseDate(notification['created_at']);
                  String dateHeader =
                      notificationPageController.getDateHeader(date);
                  if (!groupedNotifications.containsKey(dateHeader)) {
                    groupedNotifications[dateHeader] = [];
                  }
                  groupedNotifications[dateHeader]!.add(notification);
                } catch (e) {
                  print('Error parsing date: $e');
                  // Handle the error (e.g., log it, show a message, etc.)
                }
              }

              return RefreshIndicator(
                onRefresh: () async {
                  notificationPageController.refreshData(context);
                },
                child: ListView.builder(
                  itemCount: groupedNotifications.keys.length,
                  itemBuilder: (context, index) {
                    String dateHeader =
                        groupedNotifications.keys.elementAt(index);
                    List<Map<String, dynamic>> notificationsForDate =
                        groupedNotifications[dateHeader]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            dateHeader,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...notificationsForDate.map((notification) {
                          return NotificationWidget(
                            message: notification['message'],
                            time: notificationPageController
                                .formatDate(notification['created_at']),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
