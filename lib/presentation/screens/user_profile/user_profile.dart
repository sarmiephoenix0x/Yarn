import 'package:flutter/material.dart' hide CarouselController;
import 'package:provider/provider.dart';

import '../../../core/widgets/post_widgets/posts_widget.dart';
import '../../../core/widgets/tab.dart';
import '../../controllers/user_profile_controller.dart';
import '../chat_page/chat_page.dart';
import '../followers_page/followers_page.dart';
import '../followings_page/followings_page.dart';
import '../locations_followed/locations_followed.dart';

class UserProfile extends StatefulWidget {
  final int userId;
  final int viewerUserId;

  const UserProfile(
      {super.key, required this.userId, required this.viewerUserId});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProfileController(
          vsync: this,
          userId: widget.userId,
          viewerUserId: widget.viewerUserId),
      child: Consumer<UserProfileController>(
          builder: (context, userProfileController, child) {
        return Scaffold(
          // Add Scaffold to each page
          body: userProfileController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF500450)),
                )
              : RefreshIndicator(
                  onRefresh: userProfileController.fetchUserProfile,
                  child: ListView(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Image.asset(
                                    'images/BackButton.png',
                                    height: 25,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.more_vert),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                if (userProfileController.profileImage.isEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(55),
                                    child: Container(
                                      width: (80 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          MediaQuery.of(context).size.width,
                                      height: (80 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .height) *
                                          MediaQuery.of(context).size.height,
                                      color: Colors.grey,
                                      child: Image.asset(
                                        'images/ProfileImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                else
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(55),
                                    child: Container(
                                      width: (80 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          MediaQuery.of(context).size.width,
                                      height: (80 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .height) *
                                          MediaQuery.of(context).size.height,
                                      color: Colors.grey,
                                      child: Image.network(
                                        userProfileController.profileImage,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                              color: Colors
                                                  .grey); // Fallback if image fails
                                        },
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.02),
                                Expanded(
                                  flex: 5,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FollowersPage(
                                                  key: UniqueKey(),
                                                  viewerUserId: widget.userId,
                                                )),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person, size: 20),
                                        SizedBox(
                                            height: (4 /
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height) *
                                                MediaQuery.of(context)
                                                    .size
                                                    .height),
                                        Text(
                                          userProfileController.followers
                                              .toString(),
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        const Text(
                                          "Foll.",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FollowingsPage(
                                            key: UniqueKey(),
                                            viewerUserId: widget.userId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person_outline, size: 20),
                                        SizedBox(
                                            height: (4 /
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height) *
                                                MediaQuery.of(context)
                                                    .size
                                                    .height),
                                        Text(
                                          userProfileController.following
                                              .toString(),
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        const Text(
                                          "Foll'ing",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.article, size: 20),
                                      SizedBox(
                                          height: (4 /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height) *
                                              MediaQuery.of(context)
                                                  .size
                                                  .height),
                                      Text(
                                        userProfileController.posts.toString(),
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      const Text(
                                        "Yarns",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 10.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LocationsFollowedPage(
                                            key: UniqueKey(),
                                            viewerUserId: widget.userId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.location_on, size: 20),
                                        SizedBox(
                                            height: (4 /
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height) *
                                                MediaQuery.of(context)
                                                    .size
                                                    .height),
                                        Text(
                                          userProfileController.locations
                                              .toString(), // This would be your number of locations
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        const Text(
                                          "Locations", // The label for locations
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              userProfileController.userName ?? 'Unknown User',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              userProfileController.occupation ?? "No Bio",
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 3,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (widget.userId != widget.viewerUserId) {
                                      if (userProfileController.isFollowing) {
                                        userProfileController.unfollowUser();
                                      } else {
                                        userProfileController.followUser();
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: (150 /
                                            MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: userProfileController.isFollowing
                                          ? const Color(0xFF500450)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: userProfileController.isFollowing
                                            ? Colors.transparent
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    child: userProfileController.isFollowing
                                        ? Text(
                                            "Following",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Poppins',
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          )
                                        : const Text(
                                            "+ Follow",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    if (widget.userId != widget.viewerUserId) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            receiverId: widget.userId,
                                            receiverName: userProfileController
                                                    .userName ??
                                                'Unknown User',
                                            profilePic: userProfileController
                                                .profileImage,
                                            senderId: widget.viewerUserId,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: (150 /
                                            MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    child: Text(
                                      "Message",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),
                          TabBar(
                            controller: userProfileController.profileTab,
                            tabs: [
                              TabWidget(name: 'My Timeline'),
                              TabWidget(name: 'My Communities'),
                            ],
                            labelColor: Theme.of(context).colorScheme.onSurface,
                            unselectedLabelColor: Colors.grey,
                            labelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inconsolata',
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inconsolata',
                            ),
                            labelPadding: EdgeInsets.zero,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorColor:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(
                            height: (400 / MediaQuery.of(context).size.height) *
                                MediaQuery.of(context).size.height,
                            child: TabBarView(
                              controller: userProfileController.profileTab,
                              children: [
                                // Timeline Tab
                                userProfileController.isLoadingTimeline
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: Color(0xFF500450)))
                                    : userProfileController
                                            .timelinePosts.isEmpty
                                        ? Center(
                                            // Display this if the timeline posts list is empty
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.article_outlined,
                                                    size: 100,
                                                    color:
                                                        Colors.grey.shade600),
                                                const SizedBox(height: 20),
                                                Text(
                                                  'No timeline yarns available at the moment.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color:
                                                          Colors.grey.shade600),
                                                ),
                                                const SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      userProfileController
                                                          .fetchMyTimelinePosts(),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Color(0xFF500450),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Retry',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : RefreshIndicator(
                                            onRefresh: userProfileController
                                                .fetchMyTimelinePosts,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              controller: userProfileController
                                                  .timelineScrollController, // Add controller for scroll detection
                                              itemCount: userProfileController
                                                      .timelinePosts.length +
                                                  1,
                                              itemBuilder: (context, index) {
                                                if (index ==
                                                    userProfileController
                                                        .timelinePosts.length) {
                                                  return userProfileController
                                                          .hasMoreTimeline
                                                      ? const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 16),
                                                          child: Center(
                                                            child: CircularProgressIndicator(
                                                                color: Color(
                                                                    0xFF500450)),
                                                          ),
                                                        )
                                                      : const Center(
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        16),
                                                            child: Text(
                                                                'No more timeline yarns'),
                                                          ),
                                                        );
                                                }

                                                final post =
                                                    userProfileController
                                                        .timelinePosts[index];
                                                return PostsWidget(
                                                  post: post,
                                                  isLikedNotifiers:
                                                      userProfileController
                                                          .isLikedNotifiers,
                                                  likesNotifier:
                                                      userProfileController
                                                          .likesNotifier,
                                                  commentsMap:
                                                      userProfileController
                                                          .commentsMap,
                                                  profileImage:
                                                      userProfileController
                                                          .profileImage,
                                                  submitCommentMethod:
                                                      userProfileController
                                                          .submitComment,
                                                  toggleLike:
                                                      userProfileController
                                                          .toggleLike,
                                                  userId: userProfileController
                                                      .userId,
                                                );
                                              },
                                            ),
                                          ),

                                // Community Tab
                                userProfileController.isLoadingCommunity
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: Color(0xFF500450)))
                                    : userProfileController
                                            .communityPosts.isEmpty
                                        ? Center(
                                            // Display this if the community posts list is empty
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.group_outlined,
                                                    size: 100,
                                                    color:
                                                        Colors.grey.shade600),
                                                const SizedBox(height: 20),
                                                Text(
                                                  'No community yarns available at the moment.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color:
                                                          Colors.grey.shade600),
                                                ),
                                                const SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      userProfileController
                                                          .fetchMyCommunityPosts(),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Color(0xFF500450),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Retry',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : RefreshIndicator(
                                            onRefresh: userProfileController
                                                .fetchMyCommunityPosts,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              controller: userProfileController
                                                  .communityScrollController, // Add controller for scroll detection
                                              itemCount: userProfileController
                                                      .communityPosts.length +
                                                  1,
                                              itemBuilder: (context, index) {
                                                if (index ==
                                                    userProfileController
                                                        .communityPosts
                                                        .length) {
                                                  return userProfileController
                                                          .hasMoreCommunity
                                                      ? const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 16),
                                                          child: Center(
                                                            child: CircularProgressIndicator(
                                                                color: Color(
                                                                    0xFF500450)),
                                                          ),
                                                        )
                                                      : const Center(
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        16),
                                                            child: Text(
                                                                'No more community yarns'),
                                                          ),
                                                        );
                                                }

                                                final post =
                                                    userProfileController
                                                        .communityPosts[index];
                                                return PostsWidget(
                                                  post: post,
                                                  isLikedNotifiers:
                                                      userProfileController
                                                          .isLikedNotifiers,
                                                  likesNotifier:
                                                      userProfileController
                                                          .likesNotifier,
                                                  commentsMap:
                                                      userProfileController
                                                          .commentsMap,
                                                  profileImage:
                                                      userProfileController
                                                          .profileImage,
                                                  submitCommentMethod:
                                                      userProfileController
                                                          .submitComment,
                                                  toggleLike:
                                                      userProfileController
                                                          .toggleLike,
                                                  userId: userProfileController
                                                      .userId,
                                                );
                                              },
                                            ),
                                          ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      }),
    );
  }
}
