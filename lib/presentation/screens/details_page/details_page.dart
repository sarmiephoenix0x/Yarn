import 'package:flutter/material.dart' hide CarouselController;
import 'package:provider/provider.dart';

import '../../../core/widgets/post_widgets/labels.dart';
import '../../controllers/details_page_controller.dart';
import '../comments_page/comments_page.dart';
import '../user_profile/user_profile.dart';

class DetailsPage extends StatefulWidget {
  final int userId;
  final int postId;
  final List<String> postImg;
  final String authorImg;
  final String headerImg;
  final String description;
  final String authorName;
  final bool verified;
  final bool anonymous;
  final String time;
  final bool isFollowing;
  final String likes;
  final String comments;
  final bool isLiked;
  final int viewerUserId;
  final List<String> labels;

  const DetailsPage(
      {super.key,
      required this.postId,
      required this.postImg,
      required this.authorImg,
      required this.headerImg,
      required this.description,
      required this.authorName,
      required this.verified,
      required this.anonymous,
      required this.time,
      required this.isFollowing,
      required this.likes,
      required this.comments,
      required this.isLiked,
      required this.userId,
      required this.viewerUserId,
      required this.labels});

  @override
  DetailsPageState createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    Color originalIconColor = Theme.of(context).colorScheme.onSurface;
    return ChangeNotifierProvider(
      create: (context) => DetailsPageController(
          postId: widget.postId,
          postImg: widget.postImg,
          authorImg: widget.authorImg,
          headerImg: widget.headerImg,
          description: widget.description,
          authorName: widget.authorName,
          verified: widget.verified,
          anonymous: widget.anonymous,
          time: widget.time,
          isFollowingWidget: widget.isFollowing,
          likesWidget: widget.likes,
          comments: widget.comments,
          isLikedWidget: widget.isLiked,
          viewerUserId: widget.viewerUserId,
          labels: widget.labels,
          userId: widget.userId),
      child: Consumer<DetailsPageController>(
          builder: (context, detailsPageController, child) {
        return Scaffold(
          body: OrientationBuilder(builder: (context, orientation) {
            return Center(
              child: SizedBox(
                height: orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.height * 1.5,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Row(
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
                                IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () {},
                                ),
                                SizedBox(
                                  key: detailsPageController.key,
                                  child: IconButton(
                                    icon: const Icon(Icons.more_vert_outlined),
                                    onPressed: () {
                                      // _showPopupMenu(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: InkWell(
                              onTap: () {
                                if (widget.anonymous == false) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfile(
                                        key: UniqueKey(),
                                        userId: widget.userId,
                                        viewerUserId: widget.viewerUserId,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  if (widget.anonymous == false)
                                    if (widget.authorImg.isEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(55),
                                        child: Container(
                                          width: (50 /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) *
                                              MediaQuery.of(context).size.width,
                                          height: (50 /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height) *
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
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
                                          width: (50 /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) *
                                              MediaQuery.of(context).size.width,
                                          height: (50 /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height) *
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                          color: Colors.grey,
                                          child: Image.network(
                                            widget.authorImg,
                                            // Use the communityProfilePictureUrl or a default image
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
                                        0.01,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (widget.anonymous == false) ...[
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  widget.authorName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (widget.verified == true)
                                                Image.asset(
                                                  'images/verified.png',
                                                  height: 20,
                                                ),
                                            ],
                                          ),
                                        ] else ...[
                                          Text(
                                            'Anonymous',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                        // SizedBox(
                                        //   height:
                                        //       MediaQuery.of(context).size.height *
                                        //           0.01,
                                        // ),
                                        // Text(
                                        //   widget.time,
                                        //   overflow: TextOverflow.ellipsis,
                                        //   style: TextStyle(
                                        //     color: Colors.grey,
                                        //     fontSize: 16,
                                        //     fontFamily: 'Poppins',
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (widget.anonymous == false)
                                    if (detailsPageController.isMe == false)
                                      InkWell(
                                        onTap: () {
                                          // setState(() {
                                          //   isFollowing = !isFollowing;
                                          // });

                                          if (detailsPageController
                                              .isFollowing) {
                                            detailsPageController
                                                .unfollowUser();
                                          } else {
                                            detailsPageController.followUser();
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: detailsPageController
                                                    .isFollowing
                                                ? const Color(0xFF500450)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: detailsPageController
                                                      .isFollowing
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
                                          child:
                                              detailsPageController.isFollowing
                                                  ? Text(
                                                      "Following",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Poppins',
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Follow",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Poppins',
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                        ),
                                      )
                                ],
                              ),
                            ),
                          ),
                          if (widget.headerImg.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30.0,
                                  bottom: 10.0,
                                  left: 0.0,
                                  right: 0.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: Image.network(
                                  widget.headerImg,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          // Text(
                          //   "Ukraine's President Zelensky to BBC: Blood money being paid for Russian oil",
                          //   style: TextStyle(
                          //     fontSize: 20,
                          //     fontFamily: 'Poppins',
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: MediaQuery.of(context).size.height * 0.03,
                          // ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              widget.time,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Labels(labels: widget.labels),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 76.0, left: 20, right: 20),
                            child: Text(
                              widget.description,
                              style: TextStyle(
                                  fontSize: 16, fontFamily: 'Poppins'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20, // Distance from the bottom of the screen
                      right: 20, // Distance from the right side of the screen
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Like button with count
                          Column(
                            children: [
                              FloatingActionButton(
                                heroTag: 'like_fab',
                                onPressed: () {
                                  if (!detailsPageController.isLiked) {
                                    detailsPageController.toggleLike();
                                  }
                                },
                                backgroundColor: detailsPageController.isLiked
                                    ? Colors.red
                                    : Colors.grey.shade300,
                                mini: true,
                                child: Icon(
                                  detailsPageController.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(
                                  height: 4), // Space between FAB and number
                              Text(
                                widget.likes, // Replace with dynamic like count
                                style: const TextStyle(
                                  fontFamily: 'Inconsolata',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height:
                                  16), // Space between Like and Comment sections

                          // Comment button with count
                          Column(
                            children: [
                              FloatingActionButton(
                                heroTag: 'comments_fab',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommentsPage(
                                        key: UniqueKey(),
                                        postId: widget.postId,
                                        userId: widget.userId,
                                        viewerUserId: widget.viewerUserId,
                                      ),
                                    ),
                                  );
                                },
                                backgroundColor: Colors.grey.shade300,
                                mini: true,
                                child: const Icon(
                                  Icons.comment,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(
                                  height: 4), // Space between FAB and number
                              Text(
                                widget
                                    .comments, // Replace with dynamic comment count
                                style: const TextStyle(
                                  fontFamily: 'Inconsolata',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height:
                                  16), // Space between Comment and Bookmark sections

                          // Bookmark button (no count needed)
                          FloatingActionButton(
                            heroTag: 'bookmark_fab',
                            onPressed: () {
                              detailsPageController.setIsBookmarked(
                                  detailsPageController.isBookmarked);
                            },
                            backgroundColor: detailsPageController.isBookmarked
                                ? Colors.blue
                                : Colors.grey.shade300,
                            mini: true,
                            child: Icon(
                              detailsPageController.isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
