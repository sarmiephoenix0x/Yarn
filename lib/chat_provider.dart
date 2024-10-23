import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat {
  final String id;
  final String username;
  String chatPreviewText;
  final String imageUrl;
  String timeStamp;

  Chat({
    required this.id,
    required this.username,
    required this.chatPreviewText,
    required this.imageUrl,
    required this.timeStamp,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      chatPreviewText: json['chatPreviewText'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      timeStamp: json['timeStamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'chatPreviewText': chatPreviewText,
      'imageUrl': imageUrl,
      'timeStamp': timeStamp,
    };
  }
}

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  // Method to add or update a chat based on username
  void addOrUpdateChat(Chat chat) {
    // Check if a chat with the same username already exists
    final existingChatIndex = _chats.indexWhere((c) => c.id == chat.id);
    if (existingChatIndex != -1) {
      // Update the existing chat's preview text
      _chats[existingChatIndex].chatPreviewText = chat.chatPreviewText;
      _chats[existingChatIndex].timeStamp = chat.timeStamp;
    } else {
      // Add the new chat if it doesn't already exist
      _chats.add(chat);
    }
    saveChatsLocally();
    notifyListeners();
    print("Chat Updated");
  }

  void setChats(List<Chat> chats) {
    _chats = chats;
    notifyListeners();
  }

  Future<void> saveChatsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> chats =
        _chats.map((chat) => jsonEncode(chat.toJson())).toList();
    prefs.setStringList('chats', chats);
  }

  Future<void> loadChatsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? chats = prefs.getStringList('chats');
    if (chats != null) {
      _chats = chats.map((chat) => Chat.fromJson(jsonDecode(chat))).toList();
      notifyListeners();
    }
  }

  void clearChats() {
    _chats.clear(); // Clear the chat list in memory
    saveChatsLocally(); // Save the cleared state to SharedPreferences
    notifyListeners(); // Notify any listeners about the update
  }

  String getChatPreviewText(String id) {
    final chat = _chats.firstWhere((c) => c.id == id,
        orElse: () => Chat(
              id: id,
              username: '',
              chatPreviewText: '',
              imageUrl: '',
              timeStamp: '',
            ));
    return chat.chatPreviewText;
  }
}
