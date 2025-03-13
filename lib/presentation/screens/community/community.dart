import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/community_controller.dart';
import 'widgets/community_section.dart';

class CommunityPage extends StatefulWidget {
  final int viewerUserId;
  const CommunityPage({super.key, required this.viewerUserId});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    final communityController = Provider.of<CommunityController>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Communities')),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {}); // Trigger a rebuild to refresh all communities
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CommunitySection(
                      title: 'All Communities',
                      endpoint: '',
                      isFollowingMap: communityController.isFollowingMap,
                      refreshCommunitiesMethod:
                          communityController.refreshCommunities,
                      refreshState: communityController.refreshState,
                      viewerUserId: widget.viewerUserId,
                      leaveCommunityMethod: communityController.leaveCommunity,
                      joinCommunityMethod: communityController.joinCommunity,
                    ),
                    CommunitySection(
                      title: 'Created Communities',
                      endpoint: 'created',
                      isFollowingMap: communityController.isFollowingMap,
                      refreshCommunitiesMethod:
                          communityController.refreshCommunities,
                      refreshState: communityController.refreshState,
                      viewerUserId: widget.viewerUserId,
                      leaveCommunityMethod: communityController.leaveCommunity,
                      joinCommunityMethod: communityController.joinCommunity,
                    ),
                    CommunitySection(
                      title: 'Joined Communities',
                      endpoint: 'joined',
                      isFollowingMap: communityController.isFollowingMap,
                      refreshCommunitiesMethod:
                          communityController.refreshCommunities,
                      refreshState: communityController.refreshState,
                      viewerUserId: widget.viewerUserId,
                      leaveCommunityMethod: communityController.leaveCommunity,
                      joinCommunityMethod: communityController.joinCommunity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
