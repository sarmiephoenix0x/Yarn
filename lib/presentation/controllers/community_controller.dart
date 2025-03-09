import 'dart:convert';

import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../core/widgets/custom_snackbar.dart';

class CommunityController extends ChangeNotifier {
  final String baseUrl = 'https://yarnapi-fuu0.onrender.com/api/communities/';
  final storage = const FlutterSecureStorage();
  Map<int, bool> _isFollowingMap = {};

//public getters
  Map<int, bool> get isFollowingMap => _isFollowingMap;

  Future<List<dynamic>> fetchCommunities(String endpoint) async {
    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        return decodedResponse['data']; // Extract the list from the 'data' key
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      CustomSnackbar.show(
        e.toString(),
        isError: true,
      );
      return [];
    }
  }

  Future<void> joinCommunity(int communityId) async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final response = await http.patch(
      Uri.parse('$baseUrl$communityId/join'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      CustomSnackbar.show(
        'Joined community successfully',
        isError: false,
      );
      _isFollowingMap[communityId] = true; // Mark as following
      notifyListeners();
    } else {
      CustomSnackbar.show(
        'Failed to join community: ${response.reasonPhrase}',
        isError: true,
      );
    }
  }

  Future<void> leaveCommunity(int communityId) async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final response = await http.patch(
      Uri.parse('$baseUrl$communityId/leave'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      CustomSnackbar.show(
        'Left community successfully',
        isError: false,
      );

      _isFollowingMap[communityId] = false; // Mark as not following
      notifyListeners();
    } else {
      CustomSnackbar.show(
        'Failed to leave community: ${response.reasonPhrase}',
        isError: true,
      );
    }
  }

  Future<List<dynamic>> refreshCommunities(String endpoint) async {
    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        return decodedResponse['data']; // Extract the list from the 'data' key
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      return []; // Return an empty list on error
    }
  }

  void refreshState() {
    notifyListeners();
  }
}
