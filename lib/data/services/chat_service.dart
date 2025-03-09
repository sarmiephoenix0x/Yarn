import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

// Main Chat Service class for sending/receiving messages and fetching data
class ChatService {
  final String apiUrl =
      "https://yarnapi-fuu0.onrender.com/api"; // Replace with your API URL
  final Dio dio = Dio();
  final storage = const FlutterSecureStorage();

  ChatService() {
    _initialize(); // Call an async method for initialization
  }

  Future<void> _initialize() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    dio.options.headers["Authorization"] = "Bearer $accessToken";
  }

  // Send a message with optional text, audio, and images
  Future<void> sendMessage({
    required int receiverId,
    String? text,
    File? audioFile,
    List<File>? images,
  }) async {
    FormData formData = FormData();
    formData.fields.add(MapEntry("receiverId", receiverId.toString()));

    if (text != null) {
      formData.fields.add(MapEntry("text", text));
    }

    if (audioFile != null) {
      formData.files.add(MapEntry(
        "audio",
        await MultipartFile.fromFile(audioFile.path),
      ));
    }

    if (images != null) {
      for (var image in images) {
        formData.files.add(MapEntry(
          "images",
          await MultipartFile.fromFile(image.path),
        ));
      }
    }

    final response = await dio.post("$apiUrl/chats/", data: formData);

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print('Error sending message: ${response.statusCode}');
    }
  }

  // Fetch all chats
  Future<List<dynamic>> fetchChats() async {
    final authorizationHeader = dio.options.headers["Authorization"];

    if (authorizationHeader == null) {
      // Handle the case where Authorization header is missing
      throw Exception('Authorization header is missing.');
    }
    final response = await http.get(
      Uri.parse("$apiUrl/chats/"),
      headers: {"Authorization": authorizationHeader},
    );

    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if the response status is 'Success'
      if (responseData['status'] == 'Success') {
        final List<dynamic> chats =
            responseData['data']; // Extracting the list from 'data'

        // Sort chats by the last message's dateSent
        chats.sort((a, b) {
          return DateTime.parse(b['lastMessage']['dateSent'])
              .compareTo(DateTime.parse(a['lastMessage']['dateSent']));
        });

        return chats;
      } else {
        throw Exception('Failed to load chats: ${responseData['status']}');
      }
    } else {
      throw Exception('Failed to load chats: ${response.statusCode}');
    }
  }

  // Fetch messages in a chat
  Future<List<dynamic>> fetchMessages(int chatId) async {
    final response = await http.get(
      Uri.parse("$apiUrl/chats/messages/$chatId"),
      headers: {"Authorization": dio.options.headers["Authorization"]!},
    );
    print("Response body: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Check if 'data' is present and is a list
      if (data['status'] == 'Success' && data['data'] is List) {
        return data['data']; // Return the list of messages
      } else {
        throw Exception('Expected a list in data but got: $data');
      }
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  // Fetch the latest message using SignalR notification
  Future<Map<String, dynamic>> fetchNewMessage(int messageId) async {
    final response = await http.get(
      Uri.parse("$apiUrl/chats/message/new-message/$messageId"),
      headers: {"Authorization": dio.options.headers["Authorization"]!},
    );

    print("Fetching new message with ID: $messageId");
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load new message');
    }
  }
}
