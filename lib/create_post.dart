import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void initState() {
    super.initState();
    _getLocation();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    if (mounted) {
      setState(() {
        _isLoadingCountry = true; // Start loading
      });
    }

    // Fetch all countries including ISO codes
    List<csc.Country> countries = await csc.getAllCountries();

    if (mounted) {
      setState(() {
        _countries = countries; // Assign countries with ISO codes
        _isLoadingCountry = false; // Stop loading
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    _position = await Geolocator.getCurrentPosition();
    await _getAddressFromLatLng(_position!); // Fetch address
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
    setState(() {
      _isLoadingState = true; // Start loading states
    });

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
        setState(() {
          _states = states;
          _selectedStateIsoCode = detectedState.isoCode;
          _selectedState = detectedState.name;
          _isLoadingState = false;
        });
        await _fetchCities(_selectedStateIsoCode!, _selectedCountryIsoCode!);
      } else {
        print('Detected state not found in the list.');
      }
    } else {
      print('No states found for country $countryIsoCode');
      setState(() {
        _states = []; // Clear the list if no states are found
        _isLoadingState = false;
      });
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

    setState(() {
      _isLoadingCity = true; // Start loading cities
    });

    try {
      // Fetch the cities based on the selected state and country
      List<csc.City> cities =
          await csc.getStateCities(countryIsoCode, stateIsoCode);
      print(cities);
      setState(() {
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
      });
    } catch (e) {
      setState(() {
        _isLoadingCity = false; // Stop loading on error
      });
      print('Error fetching cities: $e');
    }
  }

  Future<void> _pickCoverPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverPhoto = File(image.path);
      });
    }
  }

  void _removeImage(XFile image) {
    setState(() {
      _selectedImages!.remove(image);
    });
  }

  void _removeVideo(XFile video) {
    setState(() {
      _selectedVideos!.remove(video);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImages!.add(pickedImage);
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final XFile? pickedVideo =
        await picker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      setState(() {
        _selectedVideos!.add(pickedVideo); // Store videos separately
      });
    }
  }

  Future<void> _publishPost() async {
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
    final String notificationType = _postCategory!;
    final String location = _selectedCity!;
    final String communityOrPageName = title;

    // Prepare the request
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse('https://yarnapi-n2dw.onrender.com/api/posts/');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['content'] = content
      ..fields['postType'] = postType
      ..fields['notificationType'] = notificationType
      ..fields['location'] = location
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

    setState(() {
      _isLoading = false; // Stop loading after the response
    });

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
                    _buildLocationSection(),
                    const SizedBox(height: 20),
                    _buildLabelInput(), // Add label input here
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

  Widget _buildBottomOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.add), // Plus or Pin icon
            onPressed: _showMediaOptions,
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

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.image, color: Colors.purple),
              title: Text('Image'),
              onTap: () async {
                Navigator.pop(context); // Close the sheet
                await _pickImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: Colors.red),
              title: Text('Video'),
              onTap: () async {
                Navigator.pop(context); // Close the sheet
                await _pickVideo();
              },
            ),
          ],
        );
      },
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

    if (_postCategory == 'announcement') {
      categoryIcon = Icon(Icons.info, color: Colors.blue);
      categoryColor = Colors.blue;
    } else if (_postCategory == 'warning') {
      categoryIcon = Icon(Icons.warning, color: Colors.orange);
      categoryColor = Colors.orange;
    } else if (_postCategory == 'alert') {
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
            title: const Text('Announcement'),
            onTap: () {
              setState(() => _postCategory = 'announcement');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.warning,
                color: Colors.orange), // Warning icon for Alert/Emergency
            title: const Text('Warning'),
            onTap: () {
              setState(() => _postCategory = 'warning');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.warning,
                color: Colors.red), // Warning icon for Alert/Emergency
            title: const Text('Alert'),
            onTap: () {
              setState(() => _postCategory = 'alert');
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
      children: [
        // Display images
        ..._selectedImages!.map((image) {
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
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          );
        }).toList(),

        // Display videos as thumbnails
        ..._selectedVideos!.map((video) {
          return Stack(
            children: [
              // Video thumbnail or icon (you can use a video thumbnail library or just show an icon)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.videocam, size: 50, color: Colors.red),
              ),
              // Remove button for each video
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => _removeVideo(video),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
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

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          setState(() {
            _selectedCity = value; // Update selected city
          });
        },
        itemBuilder: (BuildContext context) {
          return _isLoadingCity
              ? [
                  const PopupMenuItem<String>(
                    enabled: false, // Disable selection while loading
                    child: Center(
                        child:
                            CircularProgressIndicator()), // Show loading spinner
                  )
                ]
              : _cities.map((csc.City city) {
                  return PopupMenuItem<String>(
                    value: city.name,
                    child: Text(
                      city.name == _selectedCity
                          ? '${city.name} (Detected)' // Show detected alias
                          : city.name, // Normal city name
                    ),
                  );
                }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isLoadingCity
                    ? 'Loading location...'
                    : (_selectedCity ?? 'Select a city'),
                style: const TextStyle(
                  fontSize: 16.0, // Font size
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Labels',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            // Text field for label input
            Expanded(
              child: TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  hintText: 'Enter label',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Add button
            ElevatedButton(
              onPressed: () {
                if (_labelController.text.trim().isNotEmpty) {
                  setState(() {
                    _labels.add(_labelController.text.trim());
                    _labelController.clear();
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Display labels as chips
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: _labels.map((label) {
            return Chip(
              label: Text(label),
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  _labels.remove(label);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
