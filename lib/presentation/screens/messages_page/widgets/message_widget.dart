import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/chat_provider_controller.dart';
import '../../chat_page/chat_page.dart';

class MessageWidget extends StatelessWidget {
  final Chat chat;
  final String latestPreviewText;
  final bool isBadgeActive;
  final int senderId;

  const MessageWidget({
    super.key,
    required this.chat,
    required this.latestPreviewText,
    required this.isBadgeActive,
    required this.senderId,
  });

  @override
  Widget build(BuildContext context) {
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
                    senderId: senderId,
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
