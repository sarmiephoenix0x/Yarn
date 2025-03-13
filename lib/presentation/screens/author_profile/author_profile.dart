import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/post_widgets/posts_widget.dart';
import '../../controllers/author_profile_controller.dart';

class AuthorProfilePage extends StatefulWidget {
  final int pageId;
  final int viewerUserId;
  final String profileImage;
  final String pageName;
  final String pageDescription;

  const AuthorProfilePage({
    super.key,
    required this.pageId,
    required this.viewerUserId,
    required this.profileImage,
    required this.pageName,
    required this.pageDescription,
  });

  @override
  State<AuthorProfilePage> createState() => _AuthorProfilePageState();
}

class _AuthorProfilePageState extends State<AuthorProfilePage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthorProfileController(
          pageId: widget.pageId,
          viewerUserId: widget.viewerUserId,
          profileImage: widget.profileImage,
          pageName: widget.pageName,
          pageDescription: widget.pageDescription,
          vsync: this),
      child: Consumer<AuthorProfileController>(
        builder: (context, authorProfileController, child) {
          return Scaffold(
            // Add Scaffold to each page
            body: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.more_vert),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          if (widget.profileImage.isEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(55),
                              child: Container(
                                width:
                                    (80 / MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                height:
                                    (80 / MediaQuery.of(context).size.height) *
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
                                width:
                                    (80 / MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                height:
                                    (80 / MediaQuery.of(context).size.height) *
                                        MediaQuery.of(context).size.height,
                                color: Colors.grey,
                                child: Image.network(
                                  widget.profileImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                        color: Colors
                                            .grey); // Fallback if image fails
                                  },
                                ),
                              ),
                            ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                          const Expanded(
                            flex: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "0",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                Text(
                                  "Followers",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "0",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                Text(
                                  "Following",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "0",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                Text(
                                  "Yarns",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        widget.pageName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        widget.pageDescription,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 3,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (authorProfileController.isFollowing) {
                                authorProfileController.unfollowUser();
                              } else {
                                authorProfileController.followUser();
                              }
                            },
                            child: Container(
                              width: (150 / MediaQuery.of(context).size.width) *
                                  MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: authorProfileController.isFollowing
                                    ? const Color(0xFF500450)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: authorProfileController.isFollowing
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
                              child: authorProfileController.isFollowing
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
                            onTap: () {},
                            child: Container(
                              width: (150 / MediaQuery.of(context).size.width) *
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
                                "Website",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    SizedBox(
                      height: (400 / MediaQuery.of(context).size.height) *
                          MediaQuery.of(context).size.height,
                      child: RefreshIndicator(
                        onRefresh: authorProfileController.fetchPosts,
                        child: authorProfileController.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF500450)),
                              )
                            : authorProfileController.posts.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.article_outlined,
                                            size: 100,
                                            color: Colors.grey.shade600),
                                        const SizedBox(height: 20),
                                        Text(
                                          'No yarns available at the moment.',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey.shade600),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () =>
                                              authorProfileController
                                                  .fetchPosts(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF500450),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Retry',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    controller: authorProfileController
                                        .timelineScrollController,
                                    itemCount:
                                        authorProfileController.posts.length +
                                            1,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      if (index ==
                                          authorProfileController
                                              .posts.length) {
                                        return authorProfileController.hasMore
                                            ? const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Color(
                                                              0xFF500450)),
                                                ),
                                              )
                                            : const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 16),
                                                  child: Text('No more yarns'),
                                                ),
                                              );
                                      }

                                      final post =
                                          authorProfileController.posts[index];
                                      return PostsWidget(
                                        post: post,
                                        isLikedNotifiers:
                                            authorProfileController
                                                .isLikedNotifiers,
                                        likesNotifier: authorProfileController
                                            .likesNotifier,
                                        commentsMap:
                                            authorProfileController.commentsMap,
                                        profileImage: authorProfileController
                                            .profileImage,
                                        submitCommentMethod:
                                            authorProfileController
                                                .submitComment,
                                        toggleLike:
                                            authorProfileController.toggleLike,
                                        viewerUserId: authorProfileController
                                            .viewerUserId,
                                      );
                                    },
                                  ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
