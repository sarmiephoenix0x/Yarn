import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:yarn/chat_provider.dart';

import 'chat_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class MeassagesPage extends StatefulWidget {
  final int senderId;

  const MeassagesPage({
    super.key,
    required this.senderId,
  });

  @override
  _MeassagesPageState createState() => _MeassagesPageState();
}

class _MeassagesPageState extends State<MeassagesPage> {
  final storage = const FlutterSecureStorage();
  bool isLoading = true;
  String errorMessage = '';
  ScrollController chatsScrollController = ScrollController();
  StreamSubscription<ConnectivityResult>? connectivitySubscription;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.loadChatsLocally();
    _setupConnectivityListener();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final accessToken = await storage.read(key: 'yarnAccessToken');
    final url = 'https://yarnapi-n2dw.onrender.com/api/chats';

    try {
      if (!isConnected) throw Exception("No internet connection");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check if the response status is 'Success'
        if (responseData['status'] == 'Success') {
          final List<dynamic> chatsJson = responseData['data'];

          // Process the data into the expected Chat model
          final List<Chat> chats = chatsJson.map((chatJson) {
            return Chat(
              id: chatJson['chatId']
                  .toString(), // Assuming the chatId is numeric
              username: chatJson['lastMessage']['senderUsername'] ??
                  'Unknown', // Use senderUsername as an example
              imageUrl:
                  '', // Skip the imageUrl as the backend doesn't provide it
              timeStamp: chatJson['lastMessage']['dateSent'] ??
                  '', // Format the timestamp as needed
              chatPreviewText: chatJson['lastMessage']['text'] ??
                  'No text', // Preview text from last message
            );
          }).toList();

          // Sort chats by the last message's dateSent
          chats.sort((a, b) => DateTime.parse(b.timeStamp)
              .compareTo(DateTime.parse(a.timeStamp)));

          // Set the chats in the provider
          chatProvider.setChats(chats);

          if (chats.isEmpty) {
            _showEmptyState(); // Show a message when there are no chats
          }
          setState(() => isLoading = false);
        } else {
          throw Exception('Failed to load chats: ${responseData['status']}');
        }
      } else {
        throw Exception('Failed to load chats from the server');
      }
    } catch (e) {
      // Log the error for debugging
      print("Error loading chats: $e");

      _showCustomSnackBar(
        context,
        'Could not load chats. Showing saved chats instead.',
        isError: true,
      );

      // Load saved chats from local storage
      chatProvider.loadChatsLocally();
      setState(() => isLoading = false);
    }
  }

  void _setupConnectivityListener() {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        isConnected = result != ConnectivityResult.none;
      });
      if (!isConnected) {
        _showNoConnectionDialog();
      } else {
        Navigator.pop(context); // Close the no-internet dialog when back online
        _fetchChats(); // Retry fetching chats when the connection is restored
      }
    });
  }

  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text("No Internet Connection"),
        content: Text("You're currently offline. Viewing saved chats."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showEmptyState() {
    setState(() {
      isLoading =
          false; // Set to false since there’s no loading required in empty state
    });
  }

  void _showCustomSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Chats'),
      ),
      body: Center(
        // Display this if the timeline posts list is empty
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildChatContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    // Show a loading spinner if data is still loading
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Show error message if there's one and no chats are loaded
    if (errorMessage.isNotEmpty && chatProvider.chats.isEmpty) {
      return Center(child: Text(errorMessage));
    }

    // Show empty content if chats are still empty
    if (chatProvider.chats.isEmpty) {
      return _buildEmptyContent(context);
    }

    // Show chat list when chats are loaded
    return _buildChatList(context);
  }

  Widget _buildEmptyContent(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No recent chats.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    // Filter chats to exclude the account owner based on their ID
    final filteredChats = chatProvider.chats
        .where((chat) => chat.id != widget.senderId.toString())
        .toList();

    return ListView.builder(
      itemCount: filteredChats.length,
      reverse: true,
      shrinkWrap: true,
      controller: chatsScrollController,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        final latestPreviewText = chatProvider.getChatPreviewText(chat.id);

        return _buildMessage(chat, latestPreviewText, false);
      },
    );
  }

  Widget _buildMessage(
      Chat chat, String latestPreviewText, bool isBadgeActive) {
    List<Widget> badgeChildren = [];
    if (chat.imageUrl.isEmpty) {
      badgeChildren.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Container(
              width: (50 / MediaQuery.of(context).size.width) *
                  MediaQuery.of(context).size.width,
              height: (50 / MediaQuery.of(context).size.height) *
                  MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF500450),
                  width: 1.0,
                ),
              ),
              child: Image.asset(
                'images/ProfileImg.png',
                fit: BoxFit.cover,
                color: Theme.of(context).colorScheme.onSurface,
              )),
        ),
      );
    } else if (chat.imageUrl.isNotEmpty) {
      badgeChildren.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(55),
          child: Container(
            width: (50 / MediaQuery.of(context).size.width) *
                MediaQuery.of(context).size.width,
            height: (50 / MediaQuery.of(context).size.height) *
                MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF5A5ABA),
                width: 1.0,
              ),
            ),
            child: Image.network(
              chat.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey); // Fallback if image fails
              },
            ),
          ),
        ),
      );
    }

    if (isBadgeActive == true) {
      badgeChildren.add(
        Positioned(
          top: MediaQuery.of(context).padding.bottom + 0,
          right: MediaQuery.of(context).padding.right + 0,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF92F60),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white,
                width: 1.0,
              ),
            ),
            child: const Text(
              "1",
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverId: int.parse(chat.id),
                    senderId: widget.senderId,
                    receiverName: chat.username,
                    profilePic: chat.imageUrl,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Stack(
                  children: badgeChildren,
                ),
                SizedBox(
                    width: (8 / MediaQuery.of(context).size.width) *
                        MediaQuery.of(context).size.width),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.username,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        latestPreviewText,
                        // softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  chat.timeStamp,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
