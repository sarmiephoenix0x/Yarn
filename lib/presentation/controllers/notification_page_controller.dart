import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../core/widgets/error_dialog.dart';
import '../../core/widgets/no_internet_dialog.dart';

class NotificationPageController extends ChangeNotifier {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;
  final storage = const FlutterSecureStorage();
  bool _isRefreshing = false;

  NotificationPageController() {
    initialize();
  }

//public getters
  Future<List<Map<String, dynamic>>> get notificationsFuture =>
      _notificationsFuture;

  void initialize() {
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

  Future<void> refreshData(BuildContext context) async {
    _isRefreshing = true;
    notifyListeners();

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        showNoInternetDialog(context, refreshData);
        return;
      }
      await _performDataFetch();
    } catch (e) {
      showErrorDialog(context, e.toString());
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> _performDataFetch() async {
    _notificationsFuture = fetchNotifications();
  }
}
