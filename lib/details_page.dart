import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DetailsPage extends StatefulWidget {
  final int newsId;
  final List<String> postImg;
  final String authorImg;
  final String description;
  final String authorName;
  final bool verified;
  final bool anonymous;
  final String time;
  final bool isFollowing;

  const DetailsPage(
      {super.key,
      required this.newsId,
      required this.postImg,
      required this.authorImg,
      required this.description,
      required this.authorName,
      required this.verified,
      required this.anonymous,
      required this.time,required this.isFollowing});

  @override
  DetailsPageState createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
  late Future<Map<String, dynamic>?> _newsFuture;
  final storage = const FlutterSecureStorage();
  final GlobalKey _key = GlobalKey();
  final FocusNode _commentFocusNode = FocusNode();

  final TextEditingController commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool isLiked = false;
  bool isBookmarked = false;
  final CarouselController _controller = CarouselController();
  int _current = 0;
  bool isFollowing = false;

  void _showPopupMenu(BuildContext context) async {
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx,
          position.dy + renderBox.size.height,
          position.dx + renderBox.size.width,
          position.dy),
      items: [
        PopupMenuItem<String>(
          value: 'Share',
          child: Row(
            children: [
              Image.asset(
                'images/share-box-line.png',
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              const Text(
                'Share',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Report',
          child: Row(
            children: [
              Image.asset(
                'images/feedback-line.png',
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              const Text(
                'Report',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Save',
          child: Row(
            children: [
              Image.asset(
                'images/save-line.png',
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Open',
          child: Row(
            children: [
              Image.asset(
                'images/basketball-line.png',
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              const Text(
                'Open in browser',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        _handleMenuSelection(value);
      }
    });
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Share':
        break;
      case 'Report':
        break;
      case 'Save':
        break;
      case 'Open':
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    isFollowing = widget.isFollowing;
    _newsFuture = fetchDetailsPage(widget.newsId);
    _scrollController.addListener(() {
      if (_scrollController.offset <= 0) {
        if (_isRefreshing) {
          // Logic to cancel refresh if needed
          setState(() {
            _isRefreshing = false;
          });
        }
      }
    });
  }

  Future<Map<String, dynamic>?> fetchDetailsPage(int id) async {
    final String? accessToken = await storage.read(key: 'accessToken');
    final url = 'https://script.teendev.dev/signal/api/news/$id';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Handle different status codes
        if (response.statusCode == 401) {
          // Unauthorized, handle accordingly
          print('Unauthorized request');
        } else if (response.statusCode == 404) {
          // Not Found, handle accordingly
          print('No News Exists with this ID');
        } else if (response.statusCode == 400 || response.statusCode == 422) {
          // Bad Request or Unprocessable Entity
          final responseBody = jsonDecode(response.body);
          print('Error: ${responseBody['message']}');
          // Handle the validation errors if any
          if (responseBody['errors'] != null) {
            print('Validation Errors: ${responseBody['errors']}');
          }
        }
        return null;
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
      return null;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Check for internet connection
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        _showNoPoppinsnetDialog(context);
        setState(() {
          _isRefreshing = false;
        });
        return;
      }

      // Set a timeout for the entire refresh operation
      await Future.any([
        Future.delayed(const Duration(seconds: 15), () {
          throw TimeoutException('The operation took too long.');
        }),
        _performDataFetch(),
      ]);
    } catch (e) {
      if (e is TimeoutException) {
        _showTimeoutDialog(context);
      } else {
        _showErrorDialog(context, e.toString());
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _performDataFetch() async {
    _newsFuture = fetchDetailsPage(widget.newsId);
  }

  void _showNoPoppinsnetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Poppinsnet Connection'),
          content: const Text(
            'It looks like you are not connected to the internet. Please check your connection and try again.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Retry',
                  style: TextStyle(color: const Color(0xFF500450))),
              onPressed: () {
                Navigator.of(context).pop();
                _refreshData();
              },
            ),
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Timed Out'),
          content: const Text(
            'The operation took too long to complete. Please try again later.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Retry',
                  style: TextStyle(color: const Color(0xFF500450))),
              onPressed: () {
                Navigator.of(context).pop();
                _refreshData();
              },
            ),
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
            'An error occurred: $error',
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> vote() async {
    final String? accessToken = await storage.read(key: 'accessToken');
    final response = await http.post(
      Uri.parse('https://script.teendev.dev/signal/api/news/vote'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'news_id': widget.newsId,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Show success message
      _showCustomSnackBar(
        context,
        responseBody['message'],
        isError: false,
      );

      setState(() {
        isLiked = true;
        _newsFuture = fetchDetailsPage(widget.newsId);
      });
      setState(() {}); // Update the UI
    } else {
      _showCustomSnackBar(
        context,
        responseBody['message'] ?? 'An error occurred',
        isError: true,
      );
    }
  }

  String _formatUpvotes(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K'; // Appends 'K' for 1000+
    } else {
      return count.toString();
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

  // @override
  // Widget build(BuildContext context) {
  //   Color originalIconColor = IconTheme
  //       .of(context)
  //       .color ?? Colors.black;
  //   return Scaffold(
  //     body: OrientationBuilder(
  //       builder: (context, orientation) {
  //         return Center(
  //           child: SizedBox(
  //             height: orientation == Orientation.portrait
  //                 ? MediaQuery
  //                 .of(context)
  //                 .size
  //                 .height
  //                 : MediaQuery
  //                 .of(context)
  //                 .size
  //                 .height * 1.5,
  //             child: RefreshIndicator(
  //               onRefresh: _refreshData,
  //               color: Colors.black,
  //               child: FutureBuilder<Map<String, dynamic>?>(
  //                 future: _newsFuture,
  //                 builder: (context, snapshot) {
  //                   if (snapshot.connectionState == ConnectionState.waiting) {
  //                     return const Center(
  //                         child:
  //                         CircularProgressIndicator(color: Colors.black));
  //                   } else if (snapshot.hasError) {
  //                     return Center(
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           const Text(
  //                             'An unexpected error occurred',
  //                             textAlign: TextAlign.center,
  //                             style: TextStyle(
  //                               fontFamily: 'Inconsolata',
  //                               color: Colors.red,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 16),
  //                           ElevatedButton(
  //                             onPressed: _refreshData,
  //                             child: const Text(
  //                               'Retry',
  //                               style: TextStyle(
  //                                 fontFamily: 'Inconsolata',
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 18,
  //                                 color: Colors.black,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   } else if (snapshot.hasData) {
  //                     final news = snapshot.data;
  //                     if (news == null) {
  //                       return Center(
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             const Text(
  //                               'No news found',
  //                               textAlign: TextAlign.center,
  //                               style: TextStyle(
  //                                 fontFamily: 'Inconsolata',
  //                                 color: Colors.red,
  //                               ),
  //                             ),
  //                             const SizedBox(height: 16),
  //                             ElevatedButton(
  //                               onPressed: _refreshData,
  //                               child: const Text(
  //                                 'Retry',
  //                                 style: TextStyle(
  //                                   fontFamily: 'Inconsolata',
  //                                   fontWeight: FontWeight.bold,
  //                                   fontSize: 18,
  //                                   color: Colors.black,
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       );
  //                     }
  //                     return Stack(
  //                       alignment: Alignment.center,
  //                       children: [
  //                         Padding(
  //                           padding:
  //                           const EdgeInsets.symmetric(horizontal: 20.0),
  //                           child: SingleChildScrollView(
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 SizedBox(
  //                                   height: MediaQuery
  //                                       .of(context)
  //                                       .size
  //                                       .height *
  //                                       0.1,
  //                                 ),
  //                                 Row(
  //                                   children: [
  //                                     InkWell(
  //                                       onTap: () {
  //                                         Navigator.pop(context);
  //                                       },
  //                                       child: Image.asset(
  //                                           'images/tabler_arrow-back.png'),
  //                                     ),
  //                                     const Spacer(),
  //                                   ],
  //                                 ),
  //                                 SizedBox(
  //                                   height: MediaQuery
  //                                       .of(context)
  //                                       .size
  //                                       .height *
  //                                       0.05,
  //                                 ),
  //                                 Row(
  //                                   children: [
  //                                     Image.asset('images/NewsProfileImg.png'),
  //                                     SizedBox(
  //                                       width:
  //                                       MediaQuery
  //                                           .of(context)
  //                                           .size
  //                                           .width *
  //                                           0.01,
  //                                     ),
  //                                     Expanded(
  //                                       child: Column(
  //                                         crossAxisAlignment:
  //                                         CrossAxisAlignment.start,
  //                                         children: [
  //                                           Text(
  //                                             news['user'] ?? '',
  //                                             overflow: TextOverflow.ellipsis,
  //                                             style: const TextStyle(
  //                                               fontSize: 16,
  //                                               fontFamily: 'Poppins',
  //                                               fontWeight: FontWeight.bold,
  //                                             ),
  //                                           ),
  //                                           SizedBox(
  //                                             height: MediaQuery
  //                                                 .of(context)
  //                                                 .size
  //                                                 .height *
  //                                                 0.01,
  //                                           ),
  //                                           Text(
  //                                             news['created_at'] ?? '',
  //                                             overflow: TextOverflow.ellipsis,
  //                                             style: const TextStyle(
  //                                               color: Colors.lightBlue,
  //                                               fontSize: 16,
  //                                               fontFamily: 'Poppins',
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                     const Spacer(),
  //                                     SizedBox(
  //                                       key: _key,
  //                                       child: IconButton(
  //                                         icon: const Icon(
  //                                             Icons.more_vert_outlined),
  //                                         onPressed: () {
  //                                           _showPopupMenu(context);
  //                                         },
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 SizedBox(
  //                                   height: MediaQuery
  //                                       .of(context)
  //                                       .size
  //                                       .height *
  //                                       0.03,
  //                                 ),
  //                                 Text(
  //                                   news['title'] ?? '',
  //                                   style: const TextStyle(
  //                                       fontSize: 16, fontFamily: 'Poppins'),
  //                                 ),
  //                                 Padding(
  //                                   padding: const EdgeInsets.symmetric(
  //                                       vertical: 20.0),
  //                                   child: ClipRRect(
  //                                     borderRadius: BorderRadius.circular(10),
  //                                     child: Image.network(
  //                                       news['images'] ?? '',
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 Padding(
  //                                   padding:
  //                                   const EdgeInsets.only(bottom: 76.0),
  //                                   child: Text(
  //                                     news['article'] ?? '',
  //                                     style: const TextStyle(
  //                                         fontSize: 16, fontFamily: 'Poppins'),
  //                                   ),
  //                                 ),
  //                                 SizedBox(
  //                                   height: MediaQuery
  //                                       .of(context)
  //                                       .size
  //                                       .height *
  //                                       0.1,
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                         Positioned(
  //                           bottom: 0,
  //                           child: Container(
  //                             height:
  //                             (70 / MediaQuery
  //                                 .of(context)
  //                                 .size
  //                                 .height) *
  //                                 MediaQuery
  //                                     .of(context)
  //                                     .size
  //                                     .height,
  //                             padding: const EdgeInsets.all(12.0),
  //                             decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               border:
  //                               Border.all(width: 0, color: Colors.black),
  //                               borderRadius: BorderRadius.circular(15),
  //                               boxShadow: [
  //                                 BoxShadow(
  //                                   color: Colors.grey.withOpacity(0.5),
  //                                   spreadRadius: 3,
  //                                   blurRadius: 5,
  //                                 ),
  //                               ],
  //                             ),
  //                             child: SizedBox(
  //                               width: MediaQuery
  //                                   .of(context)
  //                                   .size
  //                                   .width,
  //                               child: Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: 20.0),
  //                                 child: Row(children: [
  //                                   Row(
  //                                     children: [
  //                                       IconButton(
  //                                         icon: Icon(
  //                                             isLiked
  //                                                 ? Icons.favorite
  //                                                 : Icons.favorite_border,
  //                                             color: isLiked
  //                                                 ? Colors.red
  //                                                 : originalIconColor),
  //                                         onPressed: () {
  //                                           if (!isLiked) {
  //                                             vote();
  //                                           }
  //                                         },
  //                                       ),
  //                                       Text(
  //                                         _formatUpvotes(news['upvotes']),
  //                                         style: const TextStyle(
  //                                           fontFamily: 'Inconsolata',
  //                                           fontSize: 15,
  //                                           fontWeight: FontWeight.bold,
  //                                           color: Colors.black,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   SizedBox(
  //                                       width:
  //                                       MediaQuery
  //                                           .of(context)
  //                                           .size
  //                                           .width *
  //                                           0.06),
  //                                   Row(
  //                                     children: [
  //                                       IconButton(
  //                                         icon: const Icon(Icons.comment),
  //                                         onPressed: () {},
  //                                       ),
  //                                       const Text(
  //                                         '1K',
  //                                         style: TextStyle(
  //                                           fontFamily: 'Inconsolata',
  //                                           fontSize: 15,
  //                                           fontWeight: FontWeight.bold,
  //                                           color: Colors.black,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   const Spacer(),
  //                                   IconButton(
  //                                     icon: Icon(
  //                                         isBookmarked
  //                                             ? Icons.bookmark
  //                                             : Icons.bookmark_border,
  //                                         color: isBookmarked
  //                                             ? const Color(0xFF500450)
  //                                             : originalIconColor),
  //                                     onPressed: () {
  //                                       setState(() {
  //                                         isBookmarked = !isBookmarked;
  //                                       });
  //                                     },
  //                                   ),
  //                                   // Expanded(
  //                                   //   child: Stack(
  //                                   //     children: [
  //                                   //       Container(
  //                                   //         decoration: BoxDecoration(
  //                                   //           color:
  //                                   //               Colors.grey.withOpacity(0.1),
  //                                   //           borderRadius:
  //                                   //               BorderRadius.circular(25),
  //                                   //         ),
  //                                   //         child: SingleChildScrollView(
  //                                   //           child: TextFormField(
  //                                   //             keyboardType:
  //                                   //                 TextInputType.multiline,
  //                                   //             maxLines: null,
  //                                   //             controller: commentController,
  //                                   //             focusNode: _commentFocusNode,
  //                                   //             style: const TextStyle(
  //                                   //               fontSize: 16.0,
  //                                   //               decoration:
  //                                   //                   TextDecoration.none,
  //                                   //             ),
  //                                   //             decoration:
  //                                   //                 const InputDecoration(
  //                                   //               contentPadding:
  //                                   //                   EdgeInsets.only(
  //                                   //                       left: 20,
  //                                   //                       right: 65,
  //                                   //                       bottom: 20,
  //                                   //                       top: 0),
  //                                   //               labelText: 'Write a comment',
  //                                   //               labelStyle: TextStyle(
  //                                   //                 color: Colors.grey,
  //                                   //                 fontFamily: 'Poppins',
  //                                   //                 fontSize: 16.0,
  //                                   //               ),
  //                                   //               floatingLabelBehavior:
  //                                   //                   FloatingLabelBehavior
  //                                   //                       .never,
  //                                   //               border: InputBorder.none,
  //                                   //             ),
  //                                   //             cursorColor: Colors.black,
  //                                   //           ),
  //                                   //         ),
  //                                   //       ),
  //                                   //       Positioned(
  //                                   //         top: 0,
  //                                   //         right: MediaQuery.of(context)
  //                                   //                 .padding
  //                                   //                 .left +
  //                                   //             10,
  //                                   //         bottom: 0,
  //                                   //         child: Image.asset(
  //                                   //           'images/user-smile-line.png',
  //                                   //         ),
  //                                   //       ),
  //                                   //     ],
  //                                   //   ),
  //                                   // ),
  //                                 ]),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     );
  //                   } else {
  //                     return Center(
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           const Text(
  //                             'No data available',
  //                             textAlign: TextAlign.center,
  //                             style: TextStyle(
  //                               fontFamily: 'Inconsolata',
  //                               color: Colors.red,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 16),
  //                           ElevatedButton(
  //                             onPressed: _refreshData,
  //                             child: const Text(
  //                               'Retry',
  //                               style: TextStyle(
  //                                 fontFamily: 'Inconsolata',
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 18,
  //                                 color: Colors.black,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   }
  //                 },
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Color originalIconColor = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Center(
          child: SizedBox(
            height: orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.height * 1.5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'images/BackButton.png',
                                height: 25,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {},
                            ),
                            SizedBox(
                              key: _key,
                              child: IconButton(
                                icon: const Icon(Icons.more_vert_outlined),
                                onPressed: () {
                                  // _showPopupMenu(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        Row(
                          children: [
                            if (widget.anonymous == false)
                              if (widget.authorImg.isEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(55),
                                  child: Container(
                                    width: (50 /
                                            MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                    height: (50 /
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
                                    width: (50 /
                                            MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                    height: (50 /
                                            MediaQuery.of(context)
                                                .size
                                                .height) *
                                        MediaQuery.of(context).size.height,
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
                              width: MediaQuery.of(context).size.width * 0.01,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.anonymous == false)...[
                                    Row(
                                      children: [
                                        Text(
                                          widget.authorName,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
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
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  Text(
                                    widget.time,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (widget.anonymous == false)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isFollowing = !isFollowing;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isFollowing
                                        ? const Color(0xFF500450)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isFollowing
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
                                  child: isFollowing
                                      ? Text(
                                    "Following",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      color:
                                      Theme.of(context).colorScheme.onSurface,
                                    ),
                                  )
                                      : Text(
                                    "Follow",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      color:
                                      Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                        if (widget.postImg.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 30.0, bottom: 10.0, left: 0.0, right: 0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  autoPlay: false,
                                  enlargeCenterPage: false,
                                  aspectRatio: 14 / 9,
                                  viewportFraction: 1.0,
                                  enableInfiniteScroll: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _current = index;
                                    });
                                  },
                                ),
                                carouselController: _controller,
                                items: widget.postImg.map((item) {
                                  return Image.asset(
                                    item,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Text(
                          "Ukraine's President Zelensky to BBC: Blood money being paid for Russian oil",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 76.0),
                          child: Text(
                            widget.description,
                            style:
                                TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: (70 / MediaQuery.of(context).size.height) *
                        MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 0, color: Colors.black),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked
                                        ? Colors.red
                                        : originalIconColor),
                                onPressed: () {
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                },
                              ),
                              const Text(
                                '24K',
                                style: const TextStyle(
                                  fontFamily: 'Inconsolata',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.06),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.comment,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                onPressed: () {},
                              ),
                              const Text(
                                '1K',
                                style: TextStyle(
                                  fontFamily: 'Inconsolata',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isBookmarked
                                    ? const Color(0xFF500450)
                                    : originalIconColor),
                            onPressed: () {
                              setState(() {
                                isBookmarked = !isBookmarked;
                              });
                            },
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
