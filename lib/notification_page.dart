import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  late Future<List<Map<String, dynamic>>> _notificationsFuture;
  final storage = const FlutterSecureStorage();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = fetchNotifications();
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    const url = 'https://yarnapi-fuu0.onrender.com/api/users/notifications';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'Success') {
        List<dynamic> jsonData = jsonResponse['data'];
        return jsonData.map((notification) {
          return {
            "message": notification["text"],
            "created_at": notification["dateCreated"],
          };
        }).toList();
      } else {
        throw Exception(
            'Failed to load notifications: ${jsonResponse['status']}');
      }
    } else {
      throw Exception('Failed to load notifications: ${response.reasonPhrase}');
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('yMMMd').format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  String getDateHeader(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return DateFormat('yMMMd').format(date);
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        _showNoInternetDialog(context);
        return;
      }
      await _performDataFetch();
    } catch (e) {
      _showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _performDataFetch() async {
    _notificationsFuture = fetchNotifications();
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your connection and try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                _refreshData();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $error'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                _refreshData();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _notificationsFuture,
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
                  String dateHeader = getDateHeader(date);
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
                onRefresh: _refreshData,
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
                          return notificationWidget(
                            notification['message'],
                            formatDate(notification['created_at']),
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

  Widget notificationWidget(String message, String time) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.notifications,
              color: Colors.blueAccent,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
