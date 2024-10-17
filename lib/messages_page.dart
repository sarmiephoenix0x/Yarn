import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:yarn/chat_provider.dart';

import 'chat_page.dart';

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
  bool isLoading = false;
  String errorMessage = '';
  ScrollController chatsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.loadChatsLocally();
    // _fetchFollowers();
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

    if (chatProvider.chats.isEmpty) {
      return _buildEmptyContent(context);
    } else {
      return _buildChatList(context);
    }
  }

  Widget _buildEmptyContent(BuildContext context) {
    return SizedBox(
      height:
          MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
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
    return ListView.builder(
      itemCount: chatProvider.chats.length,
      reverse: true,
      shrinkWrap: true,
      controller: chatsScrollController,
      itemBuilder: (context, index) {
        final chat = chatProvider.chats[index];
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
          borderRadius: BorderRadius.circular(35),
          child: Container(
            width: (50 / MediaQuery.of(context).size.width) *
                MediaQuery.of(context).size.width,
            height: (50 / MediaQuery.of(context).size.height) *
                MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF5A5ABA),
                width: 1.0,
              ),
            ),
            child: Image.network(
              chat.imageUrl[0],
              fit: BoxFit.cover,
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
