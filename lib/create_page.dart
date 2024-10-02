import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  CreatePageState createState() => CreatePageState();
}

class CreatePageState extends State<CreatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _pageProfilePicture;
  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;

  // Function to pick profile picture
  Future<void> _pickPageProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pageProfilePicture = image;
    });
  }

  Future<void> _createPage() async {
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) {
      _showCustomSnackBar(
        context,
        'Please fill in both name and description.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    // Prepare the request
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse('https://yarnapi.onrender.com/api/pages/');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['name'] = name
      ..fields['description'] = description;

    // Add page profile picture if available
    if (_pageProfilePicture != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'pageProfilePicture',
        _pageProfilePicture!.path,
      ));
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    setState(() {
      _isLoading = false; // Stop loading after the response
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Page created successfully: ${responseData['message']}');
      Navigator.pop(context); // Navigate back or clear the fields
    } else {
      final errorData = json.decode(response.body);
      _showCustomSnackBar(
        context,
        'Error creating page: ${errorData['message']}',
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
        title: const Text('Create Page'),
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
                // Page Name Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter page name...',
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Page Description Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter page description...',
                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Page Profile Picture Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: InkWell(
                    onTap: _pickPageProfilePicture,
                    child: _pageProfilePicture != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_pageProfilePicture!.path),
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
                // Create Page Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createPage, // Disable button when loading
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey,
                        ),
                      ),
                      child: _isLoading
                          ? Row(
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                          const SizedBox(width: 10),
                          Text('Creating...', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      )
                          : Text('Create Page', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
