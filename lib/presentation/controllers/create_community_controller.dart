import 'dart:convert';

import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/custom_snackbar.dart';

class CreateCommunityController extends ChangeNotifier {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _communityProfilePicture;
  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;

//public getters
  bool get isLoading => _isLoading;
  XFile? get communityProfilePicture => _communityProfilePicture;

  TextEditingController get nameController => _nameController;
  TextEditingController get descriptionController => _descriptionController;

  Future<void> pickProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    _communityProfilePicture = image;
    notifyListeners();
  }

  Future<void> createCommunity(BuildContext context) async {
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) {
      CustomSnackbar.show(
        'Please fill in both name and description.',
        isError: true,
      );
      return;
    }

    _isLoading = true; // Start loading
    notifyListeners();

    // Prepare the request
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse('https://yarnapi-fuu0.onrender.com/api/communities/');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['name'] = name
      ..fields['description'] = description;

    // Add page profile picture if available
    if (_communityProfilePicture != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'communityProfilePicture',
        _communityProfilePicture!.path,
      ));
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _isLoading = false; // Stop loading after the response

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Community created successfully: ${responseData['message']}');
      Navigator.pop(context); // Navigate back or clear the fields
    } else {
      final errorData = json.decode(response.body);
      CustomSnackbar.show(
        'Error creating page: ${errorData['message']}',
        isError: true,
      );
    }
  }
}
