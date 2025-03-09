import 'package:flutter/material.dart';

import 'community_empty_state.dart';
import 'community_item.dart';

class CommunitySection extends StatelessWidget {
  final String title;
  final String endpoint;
  final Map<int, bool> isFollowingMap;
  final Future<List<dynamic>> Function(String) refreshCommunitiesMethod;
  final void Function() refreshState;
  final int senderId;
  final Future<void> Function(int) leaveCommunityMethod;
  final Future<void> Function(int) joinCommunityMethod;

  const CommunitySection({
    super.key,
    required this.title,
    required this.endpoint,
    required this.isFollowingMap,
    required this.refreshCommunitiesMethod,
    required this.refreshState,
    required this.senderId,
    required this.leaveCommunityMethod,
    required this.joinCommunityMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        FutureBuilder<List<dynamic>>(
          future: refreshCommunitiesMethod(
              endpoint), // Fetch communities for the first time
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: Color(0xFF500450)));
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load $title'));
            } else {
              final communities = snapshot.data!;
              if (communities.isEmpty) {
                return CommunityEmptyState(
                  title: title,
                  refreshCommunitiesMethod: refreshCommunitiesMethod,
                  refreshState: refreshState,
                );
              } else {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(), // Prevent scrolling
                  shrinkWrap:
                      true, // Allow ListView to take only necessary space
                  itemCount: communities.length,
                  itemBuilder: (context, index) {
                    return CommunityItem(
                      community: communities[index],
                      isFollowingMap: isFollowingMap,
                      senderId: senderId,
                      leaveCommunityMethod: leaveCommunityMethod,
                      joinCommunityMethod: joinCommunityMethod,
                    );
                  },
                );
              }
            }
          },
        ),
      ],
    );
  }
}
