import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:yarn/author_profile.dart';
import 'package:yarn/user_profile.dart';

class CommentsPage extends StatefulWidget {
  final int postId;
  final int userId;
  final int senderId;

  const CommentsPage(
      {super.key,
      required this.postId,
      required this.userId,
      required this.senderId});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final storage = const FlutterSecureStorage();
  List<dynamic> commentsList = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      isLoading = true;
    });
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url =
        'https://yarnapi-n2dw.onrender.com/api/posts/${widget.postId}/comments';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(response.body);
        if (responseData['status'] == 'Success' &&
            responseData['data'] is List) {
          setState(() {
            commentsList =
                responseData['data']; // Update to use responseData['data']
            isLoading = false;
          });
        } else {
          // Handle unexpected response structure
          setState(() {
            errorMessage = 'Unexpected response format';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching comments: $error');
    }
  }

  Future<void> _submitComment() async {
    final String comment = commentController.text.trim();
    if (comment.isEmpty) {
      _showCustomSnackBar(
        context,
        'Please enter a comment.',
        isError: true,
      );
      return;
    }

    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse(
        'https://yarnapi-n2dw.onrender.com/api/posts/${widget.postId}/comments');
    // Log the comment and URL for debugging
    print("Submitting Comment:");
    print("Comment: $comment");
    print("POST URL: $uri");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'Comment': comment}),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        print('Comment added successfully: ${responseData['message']}');
        _fetchComments();
        commentController.clear();
      } catch (e) {
        print('Error parsing response: $e');
        _showCustomSnackBar(
          context,
          'Error adding comment. Invalid response from server.',
          isError: true,
        );
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        _showCustomSnackBar(
          context,
          'Error adding comment: ${errorData['message'] ?? 'Unknown error'}',
          isError: true,
        );
      } catch (e) {
        // If the response is not valid JSON, show the raw response text
        print('Error response: ${response.body}');
        _showCustomSnackBar(
          context,
          'Error adding comment. Server returned an unexpected response.',
          isError: true,
        );
      }
    }
  }

  void _showCustomSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF500450)))
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : commentsList.isEmpty
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
                                  onPressed: () => _fetchComments(),
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
                            itemCount: commentsList.length,
                            itemBuilder: (context, index) {
                              final comments = commentsList[index];
                              return comment(
                                comments['commentorProfilePictureUrl'] != null
                                    ? comments['commentorProfilePictureUrl'] +
                                        '/download?project=66e4476900275deffed4'
                                    : '',
                                comments['commentor'] ?? 'Unknown User',
                                comments['text'],
                                comments['dateCommented'],
                                comments['commentorId'],
                              );
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
                    controller: commentController,
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
                    _submitComment();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget comment(
      String img, String name, String description, String dateCommented, int commentorId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfile(
                key: UniqueKey(),
                userId: commentorId,
                senderId: widget.senderId,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: img.isNotEmpty
                      ? Image.network(
                          img,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'images/ProfileImg.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateCommented,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.0,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.more_vert,
                color: Colors.grey.shade500,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
