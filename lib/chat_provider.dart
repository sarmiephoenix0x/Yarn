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
    print("Adding or updating chat: ${chat.toJson()}");
    final existingChatIndex = _chats.indexWhere((c) => c.id == chat.id);
    if (existingChatIndex != -1) {
      print("Chat already exists. Updating chat with ID: ${chat.id}");
      _chats[existingChatIndex].chatPreviewText = chat.chatPreviewText;
      _chats[existingChatIndex].timeStamp = chat.timeStamp;
    } else {
      print("Adding new chat with ID: ${chat.id}");
      _chats.add(chat);
    }
    saveChatsLocally();
    notifyListeners();
    print("Current chats: ${_chats.map((c) => c.toJson()).toList()}");
  }

  void setChats(List<Chat> chats) {
    print("Setting chats: ${chats.map((c) => c.toJson()).toList()}");
    _chats = chats;
    notifyListeners();
  }

  Future<void> saveChatsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> chats =
        _chats.map((chat) => jsonEncode(chat.toJson())).toList();
    await prefs.setStringList('chats', chats);
    print("Chats saved locally: $chats");
  }

  Future<void> loadChatsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? chats = prefs.getStringList('chats');
    if (chats != null) {
      print("Loading chats from local storage: $chats");
      _chats = chats.map((chat) => Chat.fromJson(jsonDecode(chat))).toList();
      notifyListeners();
      print("Chats loaded: ${_chats.map((c) => c.toJson()).toList()}");
    } else {
      print("No chats found in local storage.");
    }
  }

  void clearChats() {
    print("Clearing chats.");
    _chats.clear(); // Clear the chat list in memory
    saveChatsLocally(); // Save the cleared state to SharedPreferences
    notifyListeners(); // Notify any listeners about the update
    print("Chats after clearing: $_chats");
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
    print(
        "Getting chat preview text for ID: $id. Preview text: ${chat.chatPreviewText}");
    return chat.chatPreviewText;
  }
}
