import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  String _profileImage = '';
  Map<String, bool> _isFollowingMap = {};

  @override
  void initState() {
    super.initState();
    _notificationsFuture = fetchNotifications();
    _scrollController.addListener(() {
      if (_scrollController.offset <= 0) {
        if (_isRefreshing) {
          // Logic to cancel refresh if needed
          setState(() {
            _isRefreshing = false;
          });
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final String? accessToken = await storage.read(key: 'accessToken');
    const url = 'https://script.teendev.dev/signal/api/notifications';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((notification) {
        return {
          "id": notification["id"],
          "message": notification["message"],
          "created_at": notification["created_at"],
        };
      }).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  DateTime parseRelativeDate(String relativeDate) {
    final now = DateTime.now();
    final dateFormats = {
      'day': const Duration(days: 1),
      'hours': const Duration(hours: 1),
      'minutes': const Duration(minutes: 1),
    };

    for (var format in dateFormats.keys) {
      if (relativeDate.contains(format)) {
        final amount = int.parse(relativeDate.split(" ")[0]);
        return now.subtract(dateFormats[format]! * amount);
      }
    }

    return now; // Fallback to current date if parsing fails
  }

  String formatDate(String dateString) {
    try {
      // Try parsing the date in ISO format
      DateTime parsedDate = DateTime.parse(dateString);
      // Format the parsed date as needed
      return DateFormat('yMMMd').format(parsedDate);
    } catch (e) {
      // Handle cases like "5 days ago"
      if (dateString.contains('days ago')) {
        int daysAgo = int.tryParse(dateString.split(' ')[0]) ?? 0;
        DateTime calculatedDate =
            DateTime.now().subtract(Duration(days: daysAgo));
        return DateFormat('yMMMd').format(calculatedDate);
      }
      // If the date format is unknown, return the original string
      return dateString;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Check for internet connection
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        _showNoInternetDialog(context);
        setState(() {
          _isRefreshing = false;
        });
        return;
      }

      // Set a timeout for the entire refresh operation
      await Future.any([
        Future.delayed(const Duration(seconds: 15), () {
          throw TimeoutException('The operation took too long.');
        }),
        _performDataFetch(),
      ]);
    } catch (e) {
      if (e is TimeoutException) {
        _showTimeoutDialog(context);
      } else {
        _showErrorDialog(context, e.toString());
      }
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
          content: const Text(
            'It looks like you are not connected to the internet. Please check your connection and try again.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Retry', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
                _refreshData();
              },
            ),
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Timed Out'),
          content: const Text(
            'The operation took too long to complete. Please try again later.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Retry', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
                _refreshData();
              },
            ),
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
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
          content: Text(
            'An error occurred: $error',
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.red)),
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
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        // body: RefreshIndicator(
        //   onRefresh: _refreshData,
        //   color: Colors.black,
        //   child: FutureBuilder<List<Map<String, dynamic>>>(
        //     future: _notificationsFuture,
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return const Center(
        //             child: CircularProgressIndicator(color: Colors.black));
        //       } else if (snapshot.hasError) {
        //         return Center(
        //           child: Column(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               const Text(
        //                 'An unexpected error occurred',
        //                 textAlign: TextAlign.center,
        //                 style: TextStyle(
        //                   fontFamily: 'Inconsolata',
        //                   color: Colors.red,
        //                 ),
        //               ),
        //               const SizedBox(height: 16),
        //               ElevatedButton(
        //                 onPressed: _refreshData,
        //                 child: const Text(
        //                   'Retry',
        //                   style: TextStyle(
        //                     fontFamily: 'Inconsolata',
        //                     fontWeight: FontWeight.bold,
        //                     fontSize: 18,
        //                     color: Colors.black,
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         );
        //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        //         return Center(
        //           child: Column(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               const Text(
        //                 'No notifications available',
        //                 textAlign: TextAlign.center,
        //                 style: TextStyle(
        //                   fontFamily: 'Inconsolata',
        //                   color: Colors.red,
        //                 ),
        //               ),
        //               const SizedBox(height: 16),
        //               ElevatedButton(
        //                 onPressed: _refreshData,
        //                 child: const Text(
        //                   'Retry',
        //                   style: TextStyle(
        //                     fontFamily: 'Inconsolata',
        //                     fontWeight: FontWeight.bold,
        //                     fontSize: 18,
        //                     color: Colors.black,
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         );
        //       }
        //
        //       List<Map<String, dynamic>> notifications = snapshot.data!;
        //       Map<String, List<Map<String, dynamic>>> groupedNotifications = {};
        //
        //       for (var notification in notifications) {
        //         String formattedDate = formatDate(notification['created_at']);
        //         if (groupedNotifications.containsKey(formattedDate)) {
        //           groupedNotifications[formattedDate]!.add(notification);
        //         } else {
        //           groupedNotifications[formattedDate] = [notification];
        //         }
        //       }
        //
        //       return
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'images/BackButton.png',
                        height: 25,
                      ),
                    ),
                    const Spacer(),
                    const Expanded(
                      flex: 10,
                      child: Text(
                        'Notification',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_vert),
                  ],
                ),
                //Remember to remove this once the backend is ready
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                notificationWidget(
                    _profileImage,
                    "Jane Doe is now following you",
                    "4h ago",
                    true),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                // ...groupedNotifications.entries.map((entry) {
                //   return Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         entry.key,
                //         style: const TextStyle(
                //           fontFamily: 'Inter',
                //           fontWeight: FontWeight.bold,
                //           fontSize: 22.0,
                //           color: Colors.black,
                //         ),
                //       ),
                //       SizedBox(
                //         height: MediaQuery.of(context).size.height * 0.02,
                //       ),
                //       Column(
                //         children: entry.value.map((notification) {
                //           return Padding(
                //             padding: const EdgeInsets.only(bottom: 15.0),
                //             child: notificationWidget(
                //               _profileImage,
                //               notification['message'],
                //               notification['created_at'],true
                //             ),
                //           );
                //         }).toList(),
                //       ),
                //     ],
                //   );
                // }).toList(),
              ],
            ),
          ),
        ),
        // },
        // ),
        // ),
      );
    });
  }

  Widget notificationWidget(
      String img, String message, String time, bool isFollowingMe) {
    final widgetKey = message;
    bool isFollowing = _isFollowingMap[widgetKey] ?? false;
    return InkWell(
      onTap: () {},
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1F4),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Row(
          children: [
            if (_profileImage.isEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(55),
                child: Container(
                  width: (50 / MediaQuery.of(context).size.width) *
                      MediaQuery.of(context).size.width,
                  height: (50 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height,
                  color: Colors.grey,
                  child: Image.asset(
                    "images/TrendingImg.png",
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(55),
                child: Container(
                  width: (50 / MediaQuery.of(context).size.width) *
                      MediaQuery.of(context).size.width,
                  height: (50 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height,
                  color: Colors.grey,
                  child: Image.file(
                    File(_profileImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Expanded(
              flex: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          softWrap: true,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    children: [
                      Text(
                        time,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isFollowingMe) const Spacer(),
            if (isFollowingMe)
              InkWell(
                onTap: () {
                  setState(() {
                    _isFollowingMap[widgetKey] = !isFollowing;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isFollowing
                        ? const Color(0xFF000099)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isFollowing
                          ? Colors.transparent
                          : const Color(0xFF000099).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: isFollowing
                      ? const Text(
                          "Following",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "+ Follow",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF000099),
                          ),
                        ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
