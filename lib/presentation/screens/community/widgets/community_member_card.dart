import 'package:flutter/material.dart';

import '../../../../data/model/member_model.dart';
import '../../members_detail_page/members_detail_page.dart';

class CommunityMemberCard extends StatelessWidget {
  final String img;
  final String name;
  final String description;
  final String followers;
  final bool isFollowing;
  final int pageId;
  final List<dynamic> members;
  final BuildContext context;
  final int senderId;
  final Future<void> Function(int) leaveCommunityMethod;
  final Future<void> Function(int) joinCommunityMethod;

  const CommunityMemberCard({
    super.key,
    required this.img,
    required this.name,
    required this.description,
    required this.followers,
    required this.isFollowing,
    required this.pageId,
    required this.members,
    required this.context,
    required this.senderId,
    required this.leaveCommunityMethod,
    required this.joinCommunityMethod,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => CommunityDetailPage(communityId: pageId),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(55),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.grey,
                child: img.isNotEmpty
                    ? Image.network(img, fit: BoxFit.cover)
                    : Image.asset('images/ProfileImg.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(followers,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  // Display member images in a stacked manner
                  SizedBox(
                    height: 40, // Set a fixed height for the stack
                    child: Stack(
                      children: members.asMap().entries.map<Widget>((entry) {
                        int index = entry.key;
                        var member = entry.value;
                        return Positioned(
                          left: index * 20.0, // Adjust the offset for stacking
                          child: GestureDetector(
                            onTap: () {
                              // When the icon is tapped, navigate to the Members List Page
                              List<Member> membersList =
                                  members.map<Member>((memberData) {
                                return Member(
                                  id: memberData['memberId'],
                                  username: memberData['username'],
                                  profilePictureUrl: memberData[
                                              'profilePictureUrl'] !=
                                          null
                                      ? memberData['profilePictureUrl'] +
                                          '/download?project=66e4476900275deffed4'
                                      : '',
                                  description:
                                      'Member description here', // Placeholder
                                  senderId: senderId, // Pass the senderId here
                                );
                              }).toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MembersListPage(
                                    members: membersList,
                                    senderId: senderId,
                                  ),
                                ),
                              );
                            },
                            child: ClipOval(
                              child: member['profilePictureUrl'] != null
                                  ? Image.network(
                                      member['profilePictureUrl'] +
                                          '/download?project=66e4476900275deffed4',
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'images/ProfileImg.png',
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isFollowing
                  ? () => leaveCommunityMethod(pageId)
                  : () => joinCommunityMethod(pageId),
              child: Text(isFollowing ? 'Leave' : 'Join'),
            ),
          ],
        ),
      ),
    );
  }
}
