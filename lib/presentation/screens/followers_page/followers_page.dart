import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/followers_widgets/user.dart';
import '../../controllers/followers_page_controller.dart';

class FollowersPage extends StatefulWidget {
  final int viewerUserId;

  const FollowersPage({
    super.key,
    required this.viewerUserId,
  });

  @override
  _FollowersPageState createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          FollowersPageController(viewerUserId: widget.viewerUserId),
      child: Consumer<FollowersPageController>(
          builder: (context, followersPageController, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Followers'),
          ),
          body: followersPageController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF500450)))
              : followersPageController.errorMessage.isNotEmpty
                  ? Center(child: Text(followersPageController.errorMessage))
                  : followersPageController.followersList.isEmpty
                      ? Center(
                          // Display this if the timeline posts list is empty
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people,
                                  size: 100, color: Colors.grey),
                              const SizedBox(height: 20),
                              const Text(
                                'No followers found.',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () =>
                                    followersPageController.fetchFollowers(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF500450),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              followersPageController.followersList.length,
                          itemBuilder: (context, index) {
                            final follower =
                                followersPageController.followersList[index];
                            return UserWidget(
                              img: follower['profilepictureurl'] != null
                                  ? follower['profilepictureurl'] +
                                      '/download?project=66e4476900275deffed4'
                                  : '',
                              name: follower['username'],
                              isFollowing: follower['isFollowing'],
                              userId: follower['userId'],
                              viewerUserId: widget.viewerUserId,
                              isFollowingMap:
                                  followersPageController.isFollowingMap,
                              storage: followersPageController.storage,
                              setIsFollowingMap:
                                  followersPageController.setIsFollowingMap,
                            );
                          },
                        ),
        );
      }),
    );
  }
}
