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
  File? _coverPhoto;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _bodyFocusNode = FocusNode();
  String? _postType = 'timeline'; // Default post type
  bool _isAnonymous = false; // Default anonymity option
  String? _postCategory = 'Information';
  List<XFile>? _selectedImages = []; // Store selected images
  final storage = const FlutterSecureStorage();
  bool _isLoading = false; // Loader state for the publish button
  List<String> _imageBase64List = [];
  final TextEditingController _textController = TextEditingController();

  Future<void> _pickCoverPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverPhoto = File(image.path);
      });
    }
  }

  void _insertImage() async {
    final pickedImage = await _pickImage(); // Use your image picker here
    if (pickedImage != null) {
      setState(() {
        _selectedImages!.add(pickedImage); // Store selected images in a list
      });
    }
  }

// Remove image from the list
  void _removeImage(XFile image) {
    setState(() {
      _selectedImages!.remove(image);
    });
  }

// Image picker method (example placeholder)
  Future<XFile?> _pickImage() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<void> _publishPost() async {
    // Extract plain text from the Quill editor
    String content = _textController.text.trim();
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
        title: const Text('Yarn'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Photo Section
                    _buildCoverPhotoSection(),
                    const SizedBox(height: 20),
                    // Title Section
                    _buildTitleSection(),
                    const SizedBox(height: 20),
                    // Post Type Dropdown
                    _buildCollapsibleFilters(),
                    const SizedBox(height: 20),
                    // Image Preview Section
                    if (_selectedImages!.isNotEmpty)
                      _buildImagePreviewSection(),
                    const SizedBox(height: 20),
                    // Body Section (Text Field)
                    _buildContentField(),
                  ],
                ),
              ),
            ),
            // Bottom Options Section
            _buildBottomOptions(),
          ],
        ),
      ),
    );
  }

// Bottom Options Section
  Widget _buildBottomOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: _insertImage,
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _publishPost,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              backgroundColor: const Color(0xFF500450),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : const Text('Yarn',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

// Cover Photo Section
  Widget _buildCoverPhotoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                child:
                    const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
              ),
      ),
    );
  }

// Title Section
  Widget _buildTitleSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter yarn title...',
            hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

// Post Type Dropdown
  Widget _postTypeDropdown() {
    return ListTile(
      title: const Text('Select Yarn Type'),
      subtitle: Text(
        _postType != null ? 'Yarn to $_postType' : 'Choose a type...',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () => _showPostTypeDialog(),
    );
  }

// Anonymous Switch with Options
  Widget _anonymousSwitch() {
    return ListTile(
      title: const Text('Privacy'),
      subtitle: Text(
        _isAnonymous ? 'Yarn as Anonymous' : 'Yarn with Identity',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      trailing: IconButton(
        icon: Icon(
          _isAnonymous
              ? Icons.visibility_off
              : Icons.visibility, // Change icon based on privacy state
        ),
        onPressed: () => _showAnonymousOptionDialog(),
      ),
      onTap: () => _showAnonymousOptionDialog(), // Show dialog on tap
    );
  }

  // Post Category Dropdown
  Widget _postCategoryDropdown() {
    Icon categoryIcon;
    Color categoryColor;

    if (_postCategory == 'Information') {
      categoryIcon = Icon(Icons.info, color: Colors.blue);
      categoryColor = Colors.blue;
    } else if (_postCategory == 'Alert/Emergency') {
      categoryIcon = Icon(Icons.warning, color: Colors.red);
      categoryColor = Colors.red;
    } else {
      categoryIcon =
          Icon(Icons.arrow_drop_down, color: Theme.of(context).iconTheme.color);
      categoryColor = Theme.of(context).colorScheme.onSurface;
    }

    return ListTile(
      title: const Text('Yarn Category'),
      subtitle: Row(
        children: [
          categoryIcon,
          const SizedBox(width: 8),
          Text(
            _postCategory != null ? _postCategory! : 'Choose a category...',
            style: TextStyle(color: categoryColor),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () => _showPostCategoryDialog(),
    );
  }

// Content Field
  Widget _buildContentField() {
    return TextField(
      controller: _textController,
      maxLines: null,
      decoration: InputDecoration(
        hintText: 'What do you want to yarn about?...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.all(12),
      ),
    );
  }

// Dialogs
  void _showPostTypeDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              title: const Text(
            'Choose Yarn Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          ...['timeline', 'page', 'community'].map((type) => ListTile(
                title: Text('Yarn to $type'),
                onTap: () {
                  setState(() => _postType = type);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  void _showAnonymousOptionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              title: const Text(
            'Choose Privacy Option',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          ListTile(
            title: const Text('Anyone'),
            onTap: () {
              setState(() => _isAnonymous = false);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Anonymous'),
            onTap: () {
              setState(() => _isAnonymous = true);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showPostCategoryDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text(
              'Choose Yarn Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info,
                color: Colors.blue), // Calmer icon for Information
            title: const Text('Information'),
            onTap: () {
              setState(() => _postCategory = 'Information');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.warning,
                color: Colors.red), // Warning icon for Alert/Emergency
            title: const Text('Alert/Emergency'),
            onTap: () {
              setState(() => _postCategory = 'Alert/Emergency');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreviewSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedImages!.map((image) {
        return Stack(
          children: [
            // Thumbnail of selected image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(image.path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            // Remove button for each image
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => _removeImage(image),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCollapsibleFilters() {
    return ExpansionTile(
      title: const Text('Filters'),
      children: [
        _postTypeDropdown(),
        const SizedBox(height: 10),
        _anonymousSwitch(),
        const SizedBox(height: 10),
        _postCategoryDropdown(), // Add the new filter here
      ],
    );
  }
}
