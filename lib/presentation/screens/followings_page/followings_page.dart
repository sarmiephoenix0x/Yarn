import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/followers_widgets/user.dart';
import '../../controllers/followings_page_controller.dart';

class FollowingsPage extends StatefulWidget {
  final int senderId;

  const FollowingsPage({super.key, required this.senderId});

  @override
  _FollowingsPageState createState() => _FollowingsPageState();
}

class _FollowingsPageState extends State<FollowingsPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FollowingsPageController(senderId: widget.senderId),
      child: Consumer<FollowingsPageController>(
          builder: (context, followingsPageController, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Following'),
          ),
          body: followingsPageController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF500450)))
              : followingsPageController.errorMessage.isNotEmpty
                  ? Center(child: Text(followingsPageController.errorMessage))
                  : followingsPageController.followingsList.isEmpty
                      ? Center(
                          // Display this if the timeline posts list is empty
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people,
                                  size: 100, color: Colors.grey),
                              const SizedBox(height: 20),
                              const Text(
                                'No followings found.',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () =>
                                    followingsPageController.fetchFollowings(),
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
                              followingsPageController.followingsList.length,
                          itemBuilder: (context, index) {
                            final following =
                                followingsPageController.followingsList[index];
                            return UserWidget(
                              img: following['profilepictureurl'] != null
                                  ? following['profilepictureurl'] +
                                      '/download?project=66e4476900275deffed4'
                                  : '',
                              name: following['username'],
                              isFollowing: following['isFollowing'],
                              userId: following['userId'],
                              senderId: widget.senderId,
                              isFollowingMap:
                                  followingsPageController.isFollowingMap,
                              storage: followingsPageController.storage,
                              setIsFollowingMap:
                                  followingsPageController.setIsFollowingMap,
                            );
                          },
                        ),
        );
      }),
    );
  }
}
