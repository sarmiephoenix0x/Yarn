import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/widgets/custom_snackbar.dart';
import '../../core/widgets/location_dialog.dart';

class CreatePostController extends ChangeNotifier {
  QuillController _controller = QuillController.basic();
  File? _coverPhoto;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _bodyFocusNode = FocusNode();
  String? _postType = 'timeline'; // Default post type
  bool _isAnonymous = false; // Default anonymity option
  String? _postCategory = 'announcement';
  List<XFile>? _selectedImages = [];
  List<XFile>? _selectedVideos = [];
  final storage = const FlutterSecureStorage();
  bool _isLoading = false; // Loader state for the publish button
  List<String> _imageBase64List = [];
  final TextEditingController _textController = TextEditingController();
  String? _selectedCountryIsoCode;
  String? _selectedCountry;
  String? _selectedStateIsoCode;
  String? _selectedState;
  String? _selectedCity;
  List<csc.City> _cities = [];
  List<csc.State> _states = [];
  List<csc.Country> _countries = [];
  bool _isLoadingCountry = true; // Loading indicator for country
  bool _isLoadingState = true; // Loading indicator for state
  bool _isLoadingCity = true;

  // For automatic state and country detection
  Position? _position;
  String? _detectedCountry;
  String? _detectedState;
  String? _detectedCity;

  List<String> _labels = [];
  final TextEditingController _labelController = TextEditingController();

  final BuildContext postContext;

  CreatePostController({required this.postContext}) {
    initialize(postContext);
  }

//public getters
  bool get isLoading => _isLoading;
  bool get isLoadingCity => _isLoadingCity;
  List<XFile>? get selectedImages => _selectedImages;
  List<XFile>? get selectedVideos => _selectedVideos;
  File? get coverPhoto => _coverPhoto;
  String? get postType => _postType;
  bool get isAnonymous => _isAnonymous;
  String? get postCategory => _postCategory;
  String? get selectedCity => _selectedCity;
  List<csc.City> get cities => _cities;
  List<String> get labels => _labels;

  TextEditingController get titleController => _titleController;
  TextEditingController get labelController => _labelController;
  TextEditingController get textController => _textController;

  void setPostType(String value) {
    _postType = value;
    notifyListeners();
  }

  void setIsAnonymous(bool value) {
    _isAnonymous = value;
    notifyListeners();
  }

  void setPostCategory(String value) {
    _postCategory = value;
    notifyListeners();
  }

  void setSelectedCity(String value) {
    _selectedCity = value;
    notifyListeners();
  }

  void clearLabelController() {
    _labelController.clear();
    notifyListeners();
  }

  void removeLabel(String value) {
    _labels.remove(value);
    notifyListeners();
  }

  void initialize(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocation(context);
    });
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    _isLoadingCountry = true; // Start loading
    notifyListeners();
    // Fetch all countries including ISO codes
    List<csc.Country> countries = await csc.getAllCountries();

    _countries = countries; // Assign countries with ISO codes
    _isLoadingCountry = false; // Stop loading
    notifyListeners();
  }

  Future<void> _getLocation(BuildContext context) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show a dialog to inform the user about the need for location services
      showLocationDialog(context, "Location Required",
          "This app requires location access to provide accurate information and a better experience. Please enable location services in your settings.");
      return;
    }

    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Request permission if it's denied
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Show a dialog if permission is not granted
        showLocationDialog(context, "Location Permission Needed",
            "This app requires location permissions to function correctly. Please allow access in your settings.");
        return;
      }
    }

    // Retrieve the current position
    Position _position = await Geolocator.getCurrentPosition();

    // Fetch address from coordinates if _position is not null
    if (_position != null) {
      await _getAddressFromLatLng(_position);
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Detected country, state, and city
        _detectedCountry = place.country;
        _detectedState = place.administrativeArea;
        _detectedCity = place.locality;

        print(
            'Detected country: $_detectedCountry, state: $_detectedState, city: $_detectedCity');

        if (_detectedCountry != null) {
          // Ensure countries list is populated
          if (_countries.isNotEmpty) {
            csc.Country? detectedCountry = _countries.firstWhere(
                (country) => country.name == _detectedCountry,
                orElse: () => csc.Country(
                    name: '',
                    isoCode: '',
                    phoneCode: '',
                    flag: '',
                    currency: '',
                    latitude: '',
                    longitude: ''));

            if (detectedCountry.name.isNotEmpty) {
              _selectedCountryIsoCode = detectedCountry.isoCode;
              _selectedCountry = detectedCountry.name;

              if (_selectedCountryIsoCode != null) {
                print('Fetching states for: $_selectedCountry');
                await _fetchStates(_selectedCountryIsoCode!);
                print('Done fetching states');
              } else {
                print('No valid ISO code for the detected country.');
              }
            } else {
              print('Detected country not found in the list.');
            }
          } else {
            print('Countries list is empty.');
          }
        }

        if (_detectedState != null) {
          // Ensure states list is populated
          if (_states.isNotEmpty) {
            csc.State? detectedState = _states.firstWhere(
                (state) =>
                    state.name.toLowerCase() == _detectedState!.toLowerCase(),
                orElse: () => csc.State(
                    name: '',
                    isoCode: '',
                    countryCode: '',
                    latitude: '',
                    longitude: ''));

            if (detectedState.name.isNotEmpty) {
              _selectedStateIsoCode = detectedState.isoCode;
              _selectedState = detectedState.name;

              if (_selectedStateIsoCode != null &&
                  _selectedCountryIsoCode != null) {
                print(
                    'Fetching cities for state: $_selectedState and country: $_selectedCountry');
                await _fetchCities(
                    _selectedStateIsoCode!, _selectedCountryIsoCode!);
              } else {
                print('State or Country ISO code is null.');
              }
            } else {
              print('Detected state not found in the list.');
            }
          } else {
            print('States list is empty.');
          }
        } else {
          print('No state detected.');
        }
      } else {
        print('No placemarks found.');
      }
    } catch (e) {
      print('Error in _getAddressFromLatLng: $e');
    }
  }

  Future<void> _fetchStates(String countryIsoCode) async {
    _isLoadingState = true; // Start loading states
    notifyListeners();

    // Fetch states for the selected country
    List<csc.State> states = await csc.getStatesOfCountry(countryIsoCode);

    // Debug: Print the fetched states
    print('Fetched states: ${states.map((state) => state.name).toList()}');

    if (_detectedState != null) {
      csc.State? detectedState = states.firstWhere(
          (state) =>
              state.name.trim().toLowerCase() ==
                  _detectedState!.trim().toLowerCase() ||
              state.name.trim().toLowerCase() ==
                  '${_detectedState!.trim()} State'.toLowerCase(),
          orElse: () => csc.State(
              name: '',
              isoCode: '',
              countryCode: '',
              latitude: '',
              longitude: ''));

      if (detectedState.name.isNotEmpty) {
        _states = states;
        _selectedStateIsoCode = detectedState.isoCode;
        _selectedState = detectedState.name;
        _isLoadingState = false;
        notifyListeners();
        await _fetchCities(_selectedStateIsoCode!, _selectedCountryIsoCode!);
      } else {
        print('Detected state not found in the list.');
      }
    } else {
      print('No states found for country $countryIsoCode');

      _states = []; // Clear the list if no states are found
      _isLoadingState = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCities(String stateIsoCode, String countryIsoCode) async {
    if (stateIsoCode.isEmpty || countryIsoCode.isEmpty) {
      print(
          'Invalid state or country ISO code. State: $stateIsoCode, Country: $countryIsoCode');
      return; // Ensure valid state and country codes
    }

    print(
        'Fetching cities for countryIsoCode: $countryIsoCode and stateIsoCode: $stateIsoCode');

    _isLoadingCity = true; // Start loading cities
    notifyListeners();

    try {
      // Fetch the cities based on the selected state and country
      List<csc.City> cities =
          await csc.getStateCities(countryIsoCode, stateIsoCode);
      print(cities);

      _cities = cities;
      _selectedCity = _detectedCity;

      // Automatically set the city based on geolocation
      if (_detectedCity != null) {
        var detectedCity = _cities.firstWhere(
            (city) => city.name.toLowerCase() == _detectedCity!.toLowerCase(),
            orElse: () => csc.City(name: '', stateCode: '', countryCode: ''));

        if (detectedCity.name.isNotEmpty) {
          _selectedCity = detectedCity.name; // Set the detected city if found
        } else {
          print('Detected city not found.');
        }
      }

      _isLoadingCity = false; // Stop loading
      notifyListeners();
    } catch (e) {
      _isLoadingCity = false; // Stop loading on error
      notifyListeners();
      print('Error fetching cities: $e');
    }
  }

  Future<void> pickCoverPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _coverPhoto = File(image.path);
      notifyListeners();
    }
  }

  void removeImage(XFile image) {
    _selectedImages!.remove(image);
    notifyListeners();
  }

  void removeVideo(XFile video) {
    _selectedVideos!.remove(video);
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _selectedImages!.add(pickedImage);
      notifyListeners();
    }
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final XFile? pickedVideo =
        await picker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      _selectedVideos!.add(pickedVideo); // Store videos separately
      notifyListeners();
    }
  }

  Future<void> publishPost(BuildContext context) async {
    String content = _textController.text.trim();
    final String title = _titleController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      CustomSnackbar.show(
        'Please fill in both title and content.',
        isError: true,
      );
      return;
    }

    _isLoading = true; // Start loading when publishing
    notifyListeners();

    final String postType = _postType!;
    final String notificationType = _postCategory!;
    final String location = _selectedCity!;
    final String communityOrPageName = title;

    // Prepare the request
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse('https://yarnapi-fuu0.onrender.com/api/posts/');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['content'] = content
      ..fields['postType'] = postType
      ..fields['notificationType'] = notificationType
      ..fields['location'] = location
      ..fields['communityOrPageName'] = communityOrPageName
      ..fields['isAnonymous'] = _isAnonymous.toString()
      ..fields['labels'] = jsonEncode(_labels);

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

    // Add selected videos if any
    for (var file in _selectedVideos!) {
      request.files.add(await http.MultipartFile.fromPath(
        'videos',
        file.path,
      ));
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _isLoading = false; // Stop loading after the response
    notifyListeners();

    if (response.body.isEmpty) {
      CustomSnackbar.show(
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
        CustomSnackbar.show(
          'Error creating yarn: ${responseData['message']}',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        'Unexpected error occurred: ${response.body}',
        isError: true,
      );
    }
  }
}
