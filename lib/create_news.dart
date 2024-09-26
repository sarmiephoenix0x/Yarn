import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreateNews extends StatefulWidget {
  const CreateNews({super.key});

  @override
  CreateNewsState createState() => CreateNewsState();
}

class CreateNewsState extends State<CreateNews> with TickerProviderStateMixin {
  QuillController _controller = QuillController.basic();
  XFile? _coverPhoto;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _bodyFocusNode = FocusNode();
  String? _postType = 'timeline'; // Default post type
  bool _isAnonymous = false; // Default anonymity option
  List<XFile>? _selectedImages = []; // Store selected images
  final storage = const FlutterSecureStorage();

  // Function to pick the cover photo
  Future<void> _pickCoverPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _coverPhoto = image;
    });
  }

  Future<void> _insertImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageBytes = await image.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);
      final imageUrl = 'data:image/png;base64,$imageBase64';

      final delta = Delta()
        ..insert('\n') // Optional: Add a new line before the image
        ..insert({
          'embed': {'type': 'image', 'source': imageUrl}
        });

      _controller.document.insert(_controller.selection.baseOffset, delta);
      _controller.updateSelection(
        TextSelection.collapsed(offset: _controller.selection.baseOffset + 1),
        ChangeSource.local,
      );
    }
  }

  Future<void> _publishPost() async {
    // Prepare the request body
    final String content = _controller.document.toDelta().toJson().toString();
    final String title = _titleController.text;

    if (title.isEmpty || content.isEmpty) {
      _showErrorDialog('Please fill in both title and content.');
      return;
    }

    final String postType = _postType!;
    final String communityOrPageName =
        "YourCommunityOrPage"; // Customize as needed

    final Map<String, dynamic> body = {
      'content': content,
      'postType': postType,
      'communityOrPageName': communityOrPageName,
      'isAnonymous': _isAnonymous,
      'headerImage':
          _coverPhoto != null ? await _coverPhoto!.readAsBytes() : null,
      'images': await Future.wait(
          _selectedImages!.map((file) async => await file.readAsBytes())),
      // Handle videos similarly if needed
    };

    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final response = await http.post(
      Uri.parse('https://yarnapi.onrender.com/api/posts/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Handle successful post creation (e.g., navigate back or show success message)
      print('Post created successfully: ${responseData['message']}');
    } else {
      final errorData = json.decode(response.body);
      // Handle error (e.g., show an alert dialog or snackbar)
      _showErrorDialog('Error creating post: ${errorData['message']}');
    }
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to show more options in a modal bottom sheet
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.format_quote),
                title: Text('Insert Quote'),
                onTap: () {
                  // Logic to insert quote
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.link),
                title: Text('Insert Link'),
                onTap: () {
                  // Logic to insert link
                  Navigator.pop(context);
                },
              ),
              // Add more options here
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Icon(Icons.arrow_back,
                                    size: 25,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              const Spacer(),
                              Expanded(
                                flex: 10,
                                child: Text(
                                  'Create Post',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // const Icon(Icons.more_vert),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GestureDetector(
                              onTap: _pickCoverPhoto,
                              child: _coverPhoto != null
                                  ? Image.file(
                                      File(_coverPhoto!.path),
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _titleController,
                            focusNode: _titleFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Enter post title',
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 10.0),
                            ),
                            onSubmitted: (_) {
                              _titleFocusNode.unfocus();
                              _bodyFocusNode.requestFocus();
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              _titleFocusNode
                                  .unfocus(); // Unfocus title when tapping on body
                              _bodyFocusNode
                                  .requestFocus(); // Focus on body field
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(color: Colors.grey[300]!)),
                                // Only top border
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              child: QuillEditor.basic(
                                controller: _controller,
                                configurations:
                                    const QuillEditorConfigurations(),
                                focusNode: _bodyFocusNode,
                                scrollController: ScrollController(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 0.5,
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomToolbar(
                      controller: _controller,
                      onImagePressed: _insertImage,
                      onMorePressed: () => _showMoreOptions(context),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _publishPost,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.white;
                            }
                            return const Color(0xFF500450);
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF500450);
                            }
                            return Colors.white;
                          },
                        ),
                        elevation: WidgetStateProperty.all<double>(4.0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Publish',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomToolbar extends StatelessWidget {
  final QuillController controller;
  final VoidCallback onImagePressed;
  final VoidCallback onMorePressed;

  const CustomToolbar({
    Key? key,
    required this.controller,
    required this.onImagePressed,
    required this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconColor = Theme.of(context).iconTheme.color ?? Colors.black;

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.format_bold, color: iconColor),
          onPressed: () => controller.formatSelection(Attribute.bold),
        ),
        IconButton(
          icon: Icon(Icons.format_italic, color: iconColor),
          onPressed: () => controller.formatSelection(Attribute.italic),
        ),
        IconButton(
          icon: Icon(Icons.format_underline, color: iconColor),
          onPressed: () => controller.formatSelection(Attribute.underline),
        ),
        IconButton(
          icon: Icon(Icons.image, color: iconColor),
          onPressed: onImagePressed,
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, color: iconColor),
          onPressed: onMorePressed,
        ),
      ],
    );
  }
}
