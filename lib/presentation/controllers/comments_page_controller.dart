import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../core/widgets/custom_snackbar.dart';

class CommentsPageController extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  List<dynamic> _commentsList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _commentController = TextEditingController();

  final int postId;

  CommentsPageController({required this.postId}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List get commentsList => _commentsList;

  TextEditingController get commentController => _commentController;

  void initialize() {
    fetchComments();
  }

  Future<void> fetchComments() async {
    _isLoading = true;
    notifyListeners();
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url = 'https://yarnapi-fuu0.onrender.com/api/posts/$postId/comments';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(response.body);
        if (responseData['status'] == 'Success' &&
            responseData['data'] is List) {
          _commentsList =
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
      print('Error fetching comments: $error');
    }
  }

  Future<void> submitComment() async {
    final String comment = commentController.text.trim();
    if (comment.isEmpty) {
      CustomSnackbar.show(
        'Please enter a comment.',
        isError: true,
      );
      return;
    }

    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse(
        'https://yarnapi-fuu0.onrender.com/api/posts/$postId/comments');
    // Log the comment and URL for debugging
    print("Submitting Comment:");
    print("Comment: $comment");
    print("POST URL: $uri");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'Comment': comment}),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        print('Comment added successfully: ${responseData['message']}');
        fetchComments();
        commentController.clear();
      } catch (e) {
        print('Error parsing response: $e');
        CustomSnackbar.show(
          'Error adding comment. Invalid response from server.',
          isError: true,
        );
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        CustomSnackbar.show(
          'Error adding comment: ${errorData['message'] ?? 'Unknown error'}',
          isError: true,
        );
      } catch (e) {
        // If the response is not valid JSON, show the raw response text
        print('Error response: ${response.body}');
        CustomSnackbar.show(
          'Error adding comment. Server returned an unexpected response.',
          isError: true,
        );
      }
    }
  }
}
