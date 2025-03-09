import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/chat_provider_controller.dart';
import 'chat_lists.dart';
import 'empty_content.dart';

class ChatContent extends StatelessWidget {
  final BuildContext context;
  final bool isLoading;
  final String errorMessage;
  final int senderId;
  final ScrollController chatsScrollController;

  const ChatContent({
    super.key,
    required this.context,
    required this.isLoading,
    required this.errorMessage,
    required this.senderId,
    required this.chatsScrollController,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    // Show a loading spinner if data is still loading
    if (isLoading) {
      return Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF500450)),
            ],
          ),
        ),
      );
    }

    // Show error message if there's one and no chats are loaded
    if (errorMessage.isNotEmpty && chatProvider.chats.isEmpty) {
      return Center(child: Text(errorMessage));
    }

    // Show empty content if chats are still empty
    if (chatProvider.chats.isEmpty) {
      return EmptyContent(
        context: context,
      );
    }

    // Show chat list when chats are loaded
    return ChatLists(
      context: context,
      senderId: senderId,
      chatsScrollController: chatsScrollController,
    );
  }
}
