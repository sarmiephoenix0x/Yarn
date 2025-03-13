import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class FollowersPageController extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  List<dynamic> _followersList = [];
  bool _isLoading = true;
  Map<String, bool> _isFollowingMap = {};
  String _errorMessage = '';

  final int viewerUserId;

  FollowersPageController({required this.viewerUserId}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List get followersList => _followersList;
  Map<String, bool> get isFollowingMap => _isFollowingMap;

  void initialize() {
    fetchFollowers();
  }

  void setIsFollowingMap(String id, bool value) {
    _isFollowingMap[id] = value;
    notifyListeners();
  }

  Future<void> fetchFollowers() async {
    _isLoading = true;
    notifyListeners();
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url =
        'https://yarnapi-fuu0.onrender.com/api/users/followers/$viewerUserId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'Success' &&
            responseData['data'] is List) {
          _followersList =
              responseData['data']; // Update to use responseData['data']
          _isLoading = false;
          notifyListeners();
        } else {
          // Handle unexpected response structure

          _errorMessage = 'Unexpected response format';
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _isLoading = false;
        notifyListeners();
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      print('Error fetching followers: $error');
    }
  }
}
