import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/messages_page_controllers.dart';
import 'widgets/chat_content.dart';

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
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MessagesPageControllers(
          initContext: context, senderId: widget.senderId),
      child: Consumer<MessagesPageControllers>(
          builder: (context, messagesPageControllers, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Recent Chats'),
          ),
          body: Center(
            // Display this if the timeline posts list is empty
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ChatContent(
                  context: messagesPageControllers.initContext,
                  isLoading: messagesPageControllers.isLoading,
                  errorMessage: messagesPageControllers.errorMessage,
                  senderId: widget.senderId,
                  chatsScrollController:
                      messagesPageControllers.chatsScrollController,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
