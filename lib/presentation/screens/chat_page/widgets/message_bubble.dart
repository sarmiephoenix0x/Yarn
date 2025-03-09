import 'dart:io';

import 'package:flutter/material.dart' hide CarouselController;

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isSentByMe;
  final bool isPlaying;
  final String currentPlayingFilePath;
  final String Function(String) getAudioPathMethod;
  final Future<void> Function(String) togglePlayPauseMethod;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.isPlaying,
    required this.currentPlayingFilePath,
    required this.getAudioPathMethod,
    required this.togglePlayPauseMethod,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors for sender (right) and receiver (left)
    Color senderBubbleColor =
        isDarkMode ? Color(0xFF7A0D7D) : Color(0xFF500450);
    Color receiverBubbleColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

    Color senderTextColor = Colors.white;
    Color receiverTextColor = isDarkMode ? Colors.white : Colors.black87;

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        decoration: BoxDecoration(
          color: isSentByMe ? senderBubbleColor : receiverBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: isSentByMe ? Radius.circular(15) : Radius.zero,
            bottomRight: isSentByMe ? Radius.zero : Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audio message handling
            if (message['audioUrl'] != null)
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying &&
                              currentPlayingFilePath ==
                                  getAudioPathMethod(message['audioUrl'])
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () => togglePlayPauseMethod(
                        getAudioPathMethod(message['audioUrl'])),
                  ),
                  const Text(
                    'Voice Note',
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),

            // Image message handling (can be multiple images)
            if (message['imageUrls'] != null && message['imageUrls'].isNotEmpty)
              Column(
                children: message['imageUrls'].map<Widget>((imageUrl) {
                  return imageUrl.startsWith('http')
                      ? Image.network(
                          '$imageUrl/download?project=66e4476900275deffed4',
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(imageUrl),
                          fit: BoxFit.cover,
                        );
                }).toList(),
              ),

            // Text message handling
            if (message['text'] != null && message['text'].isNotEmpty)
              Text(
                message['text'],
                style: TextStyle(
                  color: isSentByMe ? senderTextColor : receiverTextColor,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
