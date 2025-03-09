import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../../core/widgets/custom_snackbar.dart';
import '../screens/messages_page/widgets/dialogs/no_internet_dialog.dart';
import 'chat_provider_controller.dart';

class MessagesPageControllers extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  bool _isLoading = true;
  String _errorMessage = '';
  ScrollController _chatsScrollController = ScrollController();
  StreamSubscription<ConnectivityResult>? connectivitySubscription;
  bool isConnected = true;
  bool isDialogOpen = false;

  final int senderId;
  final BuildContext initContext;

  MessagesPageControllers({required this.initContext, required this.senderId}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  ScrollController get chatsScrollController => _chatsScrollController;

  void initialize() {
    setupConnectivityListener(initContext);
    fetchChats(initContext);
  }

  Future<void> fetchChats(BuildContext context) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final accessToken = await storage.read(key: 'yarnAccessToken');
    final currentUserId = senderId.toString(); // Get the current user's ID
    final url = 'https://yarnapi-fuu0.onrender.com/api/chats';

    try {
      if (!isConnected) throw Exception("No internet connection");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check if the response status is 'Success'
        if (responseData['status'] == 'Success') {
          final List<dynamic> chatsJson = responseData['data'];

          // Check if chatsJson is empty
          if (chatsJson.isEmpty) {
            _showEmptyState(); // Show a message when there are no chats
            return; // Early return to avoid further processing
          }

          // Process the data into the expected Chat model
          final List<Chat> chats = chatsJson.map((chatJson) {
            final lastMessage = chatJson['lastMessage'];

            // Check if lastMessage is null
            if (lastMessage == null) {
              return Chat(
                id: 'unknown',
                username: 'Unknown',
                imageUrl: '',
                timeStamp: '',
                chatPreviewText: 'No message content',
              );
            }

            // Determine the chat preview text based on content availability
            final chatPreviewText = (lastMessage['audioUrl'] != null &&
                    lastMessage['audioUrl'].isNotEmpty)
                ? "Sent an Audio"
                : (lastMessage['imageUrls'] != null &&
                        lastMessage['imageUrls'].isNotEmpty)
                    ? "Sent an Image"
                    : lastMessage['text']?.isNotEmpty == true
                        ? lastMessage['text']
                        : "No message content";

            // Determine if the current user is the sender or receiver
            final isCurrentUserSender =
                lastMessage['senderId'].toString() == currentUserId;
            final username = isCurrentUserSender
                ? lastMessage['receiverUsername'] ?? 'Unknown'
                : lastMessage['senderUsername'] ?? 'Unknown';

            return Chat(
              id: isCurrentUserSender
                  ? lastMessage['receiverId'].toString()
                  : lastMessage['senderId'].toString(),
              username: username,
              imageUrl: '',
              timeStamp: lastMessage['dateSent'] ?? '',
              chatPreviewText: chatPreviewText,
            );
          }).toList();

          // Sort chats by the last message's dateSent
          chats.sort((a, b) => DateTime.parse(b.timeStamp)
              .compareTo(DateTime.parse(a.timeStamp)));

          // Add or update each chat individually
          for (var chat in chats) {
            chatProvider.addOrUpdateChat(chat);
          }
          _isLoading = false;
          notifyListeners();
        } else {
          throw Exception('Failed to load chats: ${responseData['status']}');
        }
      } else {
        throw Exception('Failed to load chats from the server');
      }
    } catch (e) {
      // Log the error for debugging
      print("Error loading chats: $e");

      CustomSnackbar.show(
        'Could not load chats. Showing saved chats instead.',
        isError: true,
      );

      // Load saved chats from local storage
      chatProvider.loadChatsLocally();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setupConnectivityListener(BuildContext context) {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      print("Connectivity changed: $result");

      isConnected = result != ConnectivityResult.none;
      notifyListeners();
      if (!isConnected) {
        print("No internet connection.");
        showNoConnectionDialog(context, isDialogOpen);
      } else {
        print("Back online.");
        if (isDialogOpen) {
          Navigator.pop(context); // Close the no-internet dialog if it's open
        }
        print("Fetching chats due to connectivity change.");
        fetchChats(
            context); // Retry fetching chats when the connection is restored
      }
    });
  }

  void _showEmptyState() {
    _isLoading =
        false; // Set to false since there’s no loading required in empty state
    notifyListeners();
  }
}
