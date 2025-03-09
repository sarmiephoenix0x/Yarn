import 'package:flutter/material.dart' hide CarouselController;
import 'package:provider/provider.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../../core/widgets/post_widgets/posts_widget.dart';
import '../../../core/widgets/tab.dart';
import '../../controllers/account_page_controller.dart';
import '../analytics/analytics.dart';
import '../edit_page/edit_page.dart';
import '../followers_page/followers_page.dart';
import '../followings_page/followings_page.dart';
import '../locations_followed/locations_followed.dart';
import '../settings/settings.dart';
import '../../../core/widgets/post_widgets/create_options.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class AccountPage extends StatefulWidget {
  final int selectedIndex;
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final HubConnection? hubConnection;

  const AccountPage(
      {super.key,
      required this.selectedIndex,
      required this.onToggleDarkMode,
      required this.isDarkMode,
      this.hubConnection});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with TickerProviderStateMixin, RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      Provider.of<AccountPageController>(context).didChangeDependenciesCall();
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AccountPageController(
          onToggleDarkMode: widget.onToggleDarkMode,
          isDarkMode: widget.isDarkMode,
          hubConnection: widget.hubConnection,
          vsync: this),
      child: Consumer<AccountPageController>(
          builder: (context, accountPageController, child) {
        return Scaffold(
          // Add Scaffold to each page
          body: accountPageController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF500450)),
                )
              : RefreshIndicator(
                  onRefresh: accountPageController.fetchUserProfile,
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
                                const Spacer(),
                                Text(
                                  'Profile',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Settings(
                                            key: UniqueKey(),
                                            onToggleDarkMode:
                                                widget.onToggleDarkMode,
                                            isDarkMode: widget.isDarkMode),
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    'images/Settings.png',
                                    height: 30,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
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
                                if (accountPageController.profileImage.isEmpty)
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
                                        accountPageController.profileImage,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey,
                                          ); // Fallback if image fails
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
                                            senderId:
                                                accountPageController.userId!,
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
                                          accountPageController.followers
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
                                            senderId:
                                                accountPageController.userId!,
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
                                          accountPageController.following
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
                                        accountPageController.posts.toString(),
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
                                            senderId:
                                                accountPageController.userId!,
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
                                          accountPageController.locations
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
                            child: //userName != null
                                //?
                                Text(
                              accountPageController.userName ?? 'Unknown User',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            // : const Center(
                            //     // Center the loader if desired
                            //     child: CircularProgressIndicator(
                            //       color: Colors.white,
                            //     ),
                            //   ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              accountPageController.occupation ?? "No Bio",
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfilePage(
                                          key: UniqueKey(),
                                          profileImgUrl: accountPageController
                                              .profileImage,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
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
                                      "Edit profile",
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
                                const Spacer(),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
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
                                      "Share profile",
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
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Analytics(
                                          key: UniqueKey(),
                                          senderId:
                                              accountPageController.userId!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
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
                                    child: Image.asset(
                                      'images/StatImg.png',
                                      height: 25,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                            controller: accountPageController.profileTab,
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
                              controller: accountPageController.profileTab,
                              children: [
                                // Timeline Tab
                                accountPageController.isLoadingTimeline
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: Color(0xFF500450)))
                                    : accountPageController
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
                                                      accountPageController
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
                                            onRefresh: accountPageController
                                                .fetchMyTimelinePosts,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              controller: accountPageController
                                                  .timelineScrollController, // Add controller for scroll detection
                                              itemCount: accountPageController
                                                      .timelinePosts.length +
                                                  1,
                                              itemBuilder: (context, index) {
                                                if (index ==
                                                    accountPageController
                                                        .timelinePosts.length) {
                                                  return accountPageController
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
                                                    accountPageController
                                                        .timelinePosts[index];
                                                return PostsWidget(
                                                  post: post,
                                                  isLikedNotifiers:
                                                      accountPageController
                                                          .isLikedNotifiers,
                                                  likesNotifier:
                                                      accountPageController
                                                          .likesNotifier,
                                                  commentsMap:
                                                      accountPageController
                                                          .commentsMap,
                                                  profileImage:
                                                      accountPageController
                                                          .profileImage,
                                                  submitCommentMethod:
                                                      accountPageController
                                                          .submitComment,
                                                  toggleLike:
                                                      accountPageController
                                                          .toggleLike,
                                                  userId: accountPageController
                                                      .userId,
                                                );
                                              },
                                            ),
                                          ),

                                // Community Tab
                                accountPageController.isLoadingCommunity
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: Color(0xFF500450)))
                                    : accountPageController
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
                                                      accountPageController
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
                                            onRefresh: accountPageController
                                                .fetchMyCommunityPosts,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              controller: accountPageController
                                                  .communityScrollController, // Add controller for scroll detection
                                              itemCount: accountPageController
                                                      .communityPosts.length +
                                                  1,
                                              itemBuilder: (context, index) {
                                                if (index ==
                                                    accountPageController
                                                        .communityPosts
                                                        .length) {
                                                  return accountPageController
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
                                                    accountPageController
                                                        .communityPosts[index];
                                                return PostsWidget(
                                                  post: post,
                                                  isLikedNotifiers:
                                                      accountPageController
                                                          .isLikedNotifiers,
                                                  likesNotifier:
                                                      accountPageController
                                                          .likesNotifier,
                                                  commentsMap:
                                                      accountPageController
                                                          .commentsMap,
                                                  profileImage:
                                                      accountPageController
                                                          .profileImage,
                                                  submitCommentMethod:
                                                      accountPageController
                                                          .submitComment,
                                                  toggleLike:
                                                      accountPageController
                                                          .toggleLike,
                                                  userId: accountPageController
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
          floatingActionButton: FloatingActionButton(
            heroTag: 'profile_fab',
            onPressed: () {
              showCreateOptions(context, accountPageController.hasFetchedData);
            },
            backgroundColor: const Color(0xFF500450),
            shape: const CircleBorder(),
            child: Image.asset(
              'images/User-talk.png',
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
        );
      }),
    );
  }
}
