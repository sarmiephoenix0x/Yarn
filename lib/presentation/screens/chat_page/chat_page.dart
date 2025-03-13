import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/chat_page_controller.dart';
import '../../controllers/chat_provider_controller.dart';
import 'widgets/chat_text_field.dart';
import 'widgets/message_bubble.dart';

// Main Chat Widget with UI for sending and receiving messages
class ChatPage extends StatefulWidget {
  final int receiverId;
  final int senderId;
  final String receiverName;
  final String profilePic;

  const ChatPage(
      {super.key,
      required this.receiverId,
      required this.senderId,
      required this.receiverName,
      required this.profilePic});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatPageController(
          receiverId: widget.receiverId, senderId: widget.senderId),
      child: Consumer<ChatPageController>(
          builder: (context, chatPageController, child) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.receiverName)),
          body: Column(
            children: [
              Expanded(
                child: chatPageController.isLoading == true
                    ? Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF500450)),
                      )
                    : (chatPageController.messages.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.article_outlined,
                                  size: 100, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                'No recent chats.',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          )
                        : ListView.builder(
                            controller: chatPageController.scrollController,
                            reverse: false, // Display messages top to bottom
                            itemCount: chatPageController.messages.length,
                            itemBuilder: (context, index) {
                              final message =
                                  chatPageController.messages[index];
                              final isLastMessage = index ==
                                  chatPageController.messages.length - 1;

                              if (isLastMessage) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (message["audioUrl"] != null &&
                                      message["audioUrl"]!.isNotEmpty) {
                                    final newChat = Chat(
                                      id: widget.receiverId.toString(),
                                      username: widget.receiverName,
                                      chatPreviewText: "Sent An Audio",
                                      imageUrl: widget.profilePic,
                                      timeStamp: DateFormat('dd/MM/yyyy')
                                          .format(DateTime.now()),
                                    );
                                    Provider.of<ChatProvider>(context,
                                            listen: false)
                                        .addOrUpdateChat(newChat);
                                  }

                                  if (message["imageUrls"] != null &&
                                      message["imageUrls"]!.isNotEmpty) {
                                    final newChat = Chat(
                                      id: widget.receiverId.toString(),
                                      username: widget.receiverName,
                                      chatPreviewText: "Sent An Image",
                                      imageUrl: widget.profilePic,
                                      timeStamp: DateFormat('dd/MM/yyyy')
                                          .format(DateTime.now()),
                                    );
                                    Provider.of<ChatProvider>(context,
                                            listen: false)
                                        .addOrUpdateChat(newChat);
                                  }

                                  if (message["text"] != null &&
                                      message["text"]!.isNotEmpty) {
                                    final newChat = Chat(
                                      id: widget.receiverId.toString(),
                                      username: widget.receiverName,
                                      chatPreviewText: message['text']!,
                                      imageUrl: widget.profilePic,
                                      timeStamp: DateFormat('dd/MM/yyyy')
                                          .format(DateTime.now()),
                                    );
                                    Provider.of<ChatProvider>(context,
                                            listen: false)
                                        .addOrUpdateChat(newChat);
                                  }
                                });
                              }

                              final isSentByMe =
                                  message['senderId'] == widget.senderId;
                              return MessageBubble(
                                message: message,
                                isSentByMe: isSentByMe,
                                isPlaying: chatPageController.isPlaying,
                                currentPlayingFilePath:
                                    chatPageController.currentPlayingFilePath,
                                getAudioPathMethod:
                                    chatPageController.getAudioPath,
                                togglePlayPauseMethod:
                                    chatPageController.togglePlayPause,
                              );
                            },
                          )),
              ),

              ChatTextField(
                isRecording: chatPageController.isRecording,
                selectedAudioFile: chatPageController.selectedAudioFile,
                isPlaying: chatPageController.isPlaying,
                currentPlayingFilePath:
                    chatPageController.currentPlayingFilePath,
                messageController: chatPageController.messageController,
                stopRecordingMethod: chatPageController.stopRecording,
                startRecordingMethod: chatPageController.startRecording,
                selectImagesFromGalleryMethod:
                    chatPageController.selectImagesFromGallery,
                togglePlayPauseMethod: chatPageController.togglePlayPause,
                sendMessageMethod: chatPageController.sendMessage,
                deleteVoiceNoteMethod: chatPageController.deleteVoiceNote,
              ), // Show input field or audio UI
            ],
          ),
        );
      }),
    );
  }
}
