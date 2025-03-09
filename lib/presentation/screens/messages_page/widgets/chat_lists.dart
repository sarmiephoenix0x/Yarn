import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/chat_provider_controller.dart';
import 'message_widget.dart';

class ChatLists extends StatelessWidget {
  final BuildContext context;
  final int senderId;
  final ScrollController chatsScrollController;

  const ChatLists({
    super.key,
    required this.context,
    required this.senderId,
    required this.chatsScrollController,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    // Filter chats to exclude the account owner based on their ID
    final filteredChats = chatProvider.chats
        .where((chat) => chat.id != senderId.toString())
        .toList();

    return ListView.builder(
      itemCount: filteredChats.length,
      reverse: true,
      shrinkWrap: true,
      controller: chatsScrollController,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        final latestPreviewText = chatProvider.getChatPreviewText(chat.id);

        return MessageWidget(
          chat: chat,
          latestPreviewText: latestPreviewText,
          isBadgeActive: false,
          senderId: senderId,
        );
      },
    );
  }
}
