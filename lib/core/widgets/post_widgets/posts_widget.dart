import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../presentation/screens/comments_page/comments_page.dart';
import '../../../presentation/screens/details_page/details_page.dart';
import '../../../presentation/screens/user_profile/user_profile.dart';
import 'author_details.dart';
import 'comment_input.dart';
import 'labels.dart';
import 'location_and_time.dart';
import 'post_images.dart';
import 'profile_image.dart';
import 'profile_placeholder.dart';

class PostsWidget extends StatelessWidget {
  final dynamic post;
  final Map<int, ValueNotifier<bool>> isLikedNotifiers;
  final Map<int, ValueNotifier<int>> likesNotifier;
  final Map<int, int> commentsMap;
  final int? userId;
  final String profileImage;
  final Future<void> Function(int, TextEditingController) submitCommentMethod;
  final Future<void> Function(
      BuildContext context, dynamic post, int creatorUserId) toggleLike;

  const PostsWidget({
    super.key,
    this.post,
    required this.isLikedNotifiers,
    required this.likesNotifier,
    required this.commentsMap,
    required this.userId,
    required this.profileImage,
    required this.submitCommentMethod,
    required this.toggleLike,
  });

  @override
  Widget build(BuildContext context) {
    String headerImg = post['headerImageUrl'] != null
        ? "${post['headerImageUrl']}/download?project=66e4476900275deffed4"
        : '';
    String authorImg = post['creatorProfilePictureUrl'] != null
        ? "${post['creatorProfilePictureUrl']}/download?project=66e4476900275deffed4"
        : '';
    String authorName = post['creator'] ?? 'Anonymous';
    bool anonymous = post['isAnonymous'] ?? false;
    bool verified =
        false; // Assuming verification info not provided in post data
    String location = post['location'] ?? post['creatorCity'];
    String description = post['content'] ?? 'No description';
    List<String> postMedia = [
      // Process image URLs, filtering out any null or empty values
      ...List<String>.from(post['imagesUrl'] ?? [])
          .where((url) =>
              url?.trim().isNotEmpty ??
              false) // Trim and check for non-empty URLs
          .map((url) => "$url/download?project=66e4476900275deffed4")
          .toList(),

      // Process video URLs, filtering out any null or empty values
      ...List<String>.from(post['videosUrl'] ?? [])
          .where((url) =>
              url?.trim().isNotEmpty ??
              false) // Trim and check for non-empty URLs
          .map((url) => "$url/download?project=66e4476900275deffed4")
          .toList(),
    ];

    print(postMedia);

    List<String> labels = [];

    if (post['labels'] is List && post['labels'].isNotEmpty) {
      // Decode the first item in the list, which should be a string with the actual label list encoded
      String labelsString = post['labels'][0];

      // Decode the string (i.e., "[\"Test\",\"Trump\"]") into a List
      labels = List<String>.from(jsonDecode(labelsString));
    }
    String time = post['datePosted'] ?? 'Unknown time';
    bool isLiked =
        post['isLiked'] ?? false; // Use the API response for initial state
    if (!isLikedNotifiers.containsKey(post['postId'])) {
      isLikedNotifiers[post['postId']] =
          ValueNotifier<bool>(post['isLiked'] ?? false);
    }
    bool isFollowing = false;
    if (!likesNotifier.containsKey(post['postId'])) {
      likesNotifier[post['postId']] =
          ValueNotifier<int>(post['likesCount'] ?? 0);
    }
    ValueNotifier<int> commentsNotifier = ValueNotifier<int>(
        commentsMap[post['postId']] ?? post['commentsCount'] ?? 0);
    int creatorUserId = post['creatorId'];
    ValueNotifier<int> _current = ValueNotifier<int>(0);

    Color originalIconColor = IconTheme.of(context).color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPage(
                key: UniqueKey(),
                postId: post['postId'],
                postImg: postMedia,
                authorImg: authorImg,
                headerImg: headerImg,
                description: description,
                authorName: authorName,
                verified: verified,
                anonymous: anonymous,
                time: time,
                isFollowing: isFollowing,
                likes: likesNotifier[post['postId']]!.value.toString(),
                comments: commentsNotifier.value.toString(),
                isLiked: isLiked,
                userId: creatorUserId,
                senderId: userId!,
                labels: labels,
              ),
            ),
          );
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (anonymous == false) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfile(
                          key: UniqueKey(),
                          userId: creatorUserId,
                          senderId: userId!,
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      if (!anonymous)
                        if (authorImg.isEmpty)
                          ProfilePlaceholder()
                        else
                          ProfileImage(imageUrl: authorImg),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AuthorDetails(
                                authorName: authorName,
                                verified: verified,
                                anonymous: anonymous),
                            if (postMedia.isEmpty)
                              LocationAndTime(location: location, time: time),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // if (!anonymous) _buildFollowButton(isFollowing, authorName),
                    ],
                  ),
                ),
              ),
              if (postMedia.isNotEmpty)
                PostImages(mediaUrls: postMedia, currentIndex: _current),
              if (labels.isNotEmpty) Labels(labels: labels),
              // _buildInteractionRow(isLiked, postImg),
              if (postMedia.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(children: [
                    Row(
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: isLikedNotifiers[post['postId']]!,
                          builder: (context, isLiked, child) {
                            return IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: () async {
                                await toggleLike(context, post, creatorUserId);
                              },
                            );
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: likesNotifier[post['postId']]!,
                          builder: (context, likes, child) {
                            print("Likes updated: $likes");
                            return Text(
                              likes.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CommentsPage(
                                        key: UniqueKey(),
                                        postId: post['postId'],
                                        userId: creatorUserId,
                                        senderId: userId!,
                                      )),
                            );
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: commentsNotifier,
                          builder: (context, comments, child) {
                            return Text(
                              comments.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    ValueListenableBuilder<int>(
                      valueListenable: _current,
                      builder: (context, index, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            postMedia.length,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Image.asset(
                                _current.value == index
                                    ? "images/ActiveElipses.png"
                                    : "images/InactiveElipses.png",
                                width:
                                    (10 / MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                height:
                                    (10 / MediaQuery.of(context).size.height) *
                                        MediaQuery.of(context).size.height,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {},
                    ),
                  ]),
                ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              if (postMedia.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Color(0xFF4E4B66),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Image.asset(
                            "images/TimeStampImg.png",
                            height: 20,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03),
                          Text(
                            time,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  description,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 3,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              // if (postImg.isEmpty) _buildInteractionRow(isLiked, postImg),
              if (postMedia.isEmpty) ...[
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(children: [
                    Row(
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: isLikedNotifiers[post['postId']]!,
                          builder: (context, isLiked, child) {
                            return IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: () async {
                                await toggleLike(context, post, creatorUserId);
                              },
                            );
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: likesNotifier[post['postId']]!,
                          builder: (context, likes, child) {
                            print("Likes updated: $likes");
                            return Text(
                              likes.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CommentsPage(
                                        key: UniqueKey(),
                                        postId: post['postId'],
                                        userId: creatorUserId,
                                        senderId: userId!,
                                      )),
                            );
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: commentsNotifier,
                          builder: (context, comments, child) {
                            return Text(
                              comments.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    ValueListenableBuilder<int>(
                      valueListenable: _current,
                      builder: (context, index, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            postMedia.length,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Image.asset(
                                _current.value == index
                                    ? "images/ActiveElipses.png"
                                    : "images/InactiveElipses.png",
                                width:
                                    (10 / MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                height:
                                    (10 / MediaQuery.of(context).size.height) *
                                        MediaQuery.of(context).size.height,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {},
                    ),
                  ]),
                ),
              ],
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              CommentInput(
                imageUrl: profileImage,
                postId: post['postId'],
                submitCommentMethod: submitCommentMethod,
              ),
              Divider(color: Theme.of(context).colorScheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
