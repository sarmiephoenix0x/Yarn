import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  CreatePostState createState() => CreatePostState();
}

class CreatePostState extends State<CreatePost> with TickerProviderStateMixin {
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
  bool _isLoading = false; // Loader state for the publish button

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
    // Extract plain text from the Quill editor
    String content = _controller.document.toPlainText().trim();
    final String title = _titleController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      _showCustomSnackBar(
        context,
        'Please fill in both title and content.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading when publishing
    });

    // Clean up the document content by removing "Insert[]" text
    content = content.replaceAll(RegExp(r'Insert\[\]'), '');

    final String postType = _postType!;
    final String communityOrPageName = title; // Customize as needed

    // Prepare the request
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse('https://yarnapi-n2dw.onrender.com/api/posts/');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['content'] = content
      ..fields['postType'] = postType
      ..fields['communityOrPageName'] = communityOrPageName
      ..fields['isAnonymous'] = _isAnonymous.toString();

    // Add header image if available
    if (_coverPhoto != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'headerImage',
        _coverPhoto!.path,
      ));
    }

    // Add selected images if any
    for (var file in _selectedImages!) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        file.path,
      ));
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    setState(() {
      _isLoading = false; // Stop loading after the response
    });

    // Check if the response is empty
    if (response.body.isEmpty) {
      _showCustomSnackBar(
        context,
        'Error: No response received from the server.',
        isError: true,
      );
      return;
    }

    // Try to parse the response as JSON
    try {
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('Yarn created successfully: ${responseData['message']}');
        Navigator.pop(context); // Navigate back or clear the fields
      } else {
        _showCustomSnackBar(
          context,
          'Error creating yarn: ${responseData['message']}',
          isError: true,
        );
      }
    } catch (e) {
      // If parsing fails, handle the error gracefully
      _showCustomSnackBar(
        context,
        'Unexpected error occurred: ${response.body}',
        isError: true,
      );
    }
  }

  // Dropdown to choose post type (timeline, page, community)
  Widget _postTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButton<String>(
        value: _postType,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        isExpanded: true,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        underline: Container(
          height: 2,
          color: Colors.grey,
        ),
        onChanged: (String? newValue) {
          setState(() {
            _postType = newValue;
          });
        },
        items: <String>['timeline', 'page', 'community']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text('Yarn to $value',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          );
        }).toList(),
      ),
    );
  }

  // Switch to choose anonymity option
  Widget _anonymousSwitch() {
    return SwitchListTile(
      title: const Text('Yarn Anonymously'),
      value: _isAnonymous,
      onChanged: (bool value) {
        setState(() {
          _isAnonymous = value;
        });
      },
      secondary: const Icon(Icons.visibility_off),
    );
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
        title: const Text('Create Yarn'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Photo Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: InkWell(
                    onTap: _pickCoverPhoto,
                    child: _coverPhoto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_coverPhoto!.path),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[300],
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter yarn title...',
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      onSubmitted: (_) {
                        _titleFocusNode.unfocus();
                        _bodyFocusNode.requestFocus();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Post Type Dropdown
                _postTypeDropdown(),
                const SizedBox(height: 20),
                // Anonymous Switch
                _anonymousSwitch(),
                const SizedBox(height: 20),
                // Body Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: QuillEditor.basic(
                      controller: _controller,
                      configurations: const QuillEditorConfigurations(),
                      focusNode: _bodyFocusNode,
                      scrollController: ScrollController(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Action Toolbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.extended(
                      onPressed: _insertImage,
                      icon: Icon(Icons.image,
                          color: Theme.of(context).colorScheme.onSurface),
                      label: Text('Add Image',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface)),
                      backgroundColor: const Color(0xFF500450),
                    ),
                    SizedBox(
                        width: (16.0 / MediaQuery.of(context).size.height) *
                            MediaQuery.of(context).size.height),
                    Container(
                      height: (60 / MediaQuery.of(context).size.height) *
                          MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _publishPost,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return Colors.white;
                              }
                              return const Color(0xFF500450);
                            },
                          ),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return const Color(0xFF500450);
                              }
                              return Colors.white;
                            },
                          ),
                          elevation: WidgetStateProperty.all<double>(4.0),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Publish',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
