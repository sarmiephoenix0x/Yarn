import 'package:flutter/material.dart';

import 'community_member_card.dart';

class CommunityItem extends StatelessWidget {
  final dynamic community;
  final Map<int, bool> isFollowingMap;
  final int senderId;
  final Future<void> Function(int) leaveCommunityMethod;
  final Future<void> Function(int) joinCommunityMethod;

  const CommunityItem({
    super.key,
    this.community,
    required this.isFollowingMap,
    required this.senderId,
    required this.leaveCommunityMethod,
    required this.joinCommunityMethod,
  });

  @override
  Widget build(BuildContext context) {
    bool isFollowing = isFollowingMap[community['communityId']] ?? false;
    return CommunityMemberCard(
      img: community['communityProfilePictureUrl'] != null
          ? community['communityProfilePictureUrl'] +
              '/download?project=66e4476900275deffed4'
          : '',
      name: community['name'],
      description: community['description'],
      followers:
          "${community['members'].length} members", // Updated to show member count
      isFollowing: isFollowing, // Placeholder for isFollowing
      pageId:
          community['communityId'], // Assuming the community ID is available
      members: community['members'], // Pass members data
      context: context, senderId: senderId,
      leaveCommunityMethod: leaveCommunityMethod,
      joinCommunityMethod: joinCommunityMethod, // Pass the BuildContext
    );
  }
}
