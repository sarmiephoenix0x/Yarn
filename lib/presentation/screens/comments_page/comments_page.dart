import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/comments_page_controller.dart';
import 'widgets/comment.dart';

class CommentsPage extends StatefulWidget {
  final int postId;
  final int userId;
  final int viewerUserId;

  const CommentsPage(
      {super.key,
      required this.postId,
      required this.userId,
      required this.viewerUserId});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CommentsPageController(postId: widget.postId),
      child: Consumer<CommentsPageController>(
          builder: (context, commentsPageController, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Comments'),
          ),
          body: Column(
            children: [
              Expanded(
                child: commentsPageController.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF500450)))
                    : commentsPageController.errorMessage.isNotEmpty
                        ? Center(
                            child: Text(commentsPageController.errorMessage))
                        : commentsPageController.commentsList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.people,
                                        size: 100, color: Colors.grey),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'No comments found.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () => commentsPageController
                                          .fetchComments(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF500450),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                    commentsPageController.commentsList.length,
                                itemBuilder: (context, index) {
                                  final comments = commentsPageController
                                      .commentsList[index];
                                  return CommentWidget(
                                      img: comments[
                                                  'commentorProfilePictureUrl'] !=
                                              null
                                          ? comments[
                                                  'commentorProfilePictureUrl'] +
                                              '/download?project=66e4476900275deffed4'
                                          : '',
                                      name: comments['commentor'] ??
                                          'Unknown User',
                                      description: comments['text'],
                                      dateCommented: comments['dateCommented'],
                                      commentorId: comments['commentorId'],
                                      viewerUserId: widget.viewerUserId);
                                },
                              ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentsPageController.commentController,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).colorScheme.onSurface,
                          decoration: TextDecoration.none,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: false,
                          fillColor: Colors.grey[200],
                        ),
                        minLines: 1,
                        maxLines: null,
                        cursorColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF500450)),
                      onPressed: () {
                        commentsPageController.submitComment();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
