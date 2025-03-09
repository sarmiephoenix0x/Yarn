import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

import '../../controllers/news_sources_controller.dart';
import 'widgets/community.dart';

class NewsSources extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String email;
  final String surname;
  final String firstName;
  final String phoneNumber;
  final String dob;
  final String state;
  final String country;
  final String occupation;
  final String? jobTitle;
  final String? company;
  final int? yearJoined;
  final String selectedGender;
  final String profileImage;

  const NewsSources(
      {super.key,
      required this.onToggleDarkMode,
      required this.isDarkMode,
      required this.email,
      required this.surname,
      required this.firstName,
      required this.phoneNumber,
      required this.dob,
      required this.state,
      required this.country,
      required this.occupation,
      this.jobTitle,
      this.company,
      this.yearJoined,
      required this.selectedGender,
      required this.profileImage});

  @override
  NewsSourcesState createState() => NewsSourcesState();
}

class NewsSourcesState extends State<NewsSources>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NewsSourcesController(
          onToggleDarkMode: widget.onToggleDarkMode,
          isDarkMode: widget.isDarkMode,
          emailWidget: widget.email,
          surnameWidget: widget.surname,
          firstNameWidget: widget.firstName,
          phoneNumberWidget: widget.phoneNumber,
          dobWidget: widget.dob,
          stateWidget: widget.state,
          countryWidget: widget.country,
          occupationWidget: widget.occupation,
          selectedGenderWidget: widget.selectedGender,
          profileImageWidget: widget.profileImage),
      child: Consumer<NewsSourcesController>(
          builder: (context, newsSourcesController, child) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      // Wrap SingleChildScrollView with Expanded
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Image.asset(
                                    'images/BackButton.png',
                                    height: 25,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                Expanded(
                                  flex: 10,
                                  child: Text(
                                    'Communities To Join',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextFormField(
                              controller:
                                  newsSourcesController.searchController,
                              focusNode: newsSourcesController.searchFocusNode,
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Search',
                                labelStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Poppins',
                                  fontSize: 12.0,
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () {
                                    newsSourcesController.filterCommunities(
                                        newsSourcesController
                                            .searchController.text);
                                  },
                                ),
                              ),
                              cursorColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          newsSourcesController.isLoading2
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF500450)))
                              : newsSourcesController.isError
                                  ? const Center(
                                      child: Text(
                                          'Failed to load communities. Please try again later.'))
                                  : newsSourcesController
                                          .filteredCommunities.isEmpty
                                      ? const Center(
                                          child:
                                              Text('No communities available.'))
                                      : Expanded(
                                          child: ListView.builder(
                                            itemCount: newsSourcesController
                                                .filteredCommunities.length,
                                            itemBuilder: (context, index) {
                                              var communityData =
                                                  newsSourcesController
                                                          .filteredCommunities[
                                                      index];
                                              return Community(
                                                img: communityData[
                                                        'communityProfilePictureUrl'] ??
                                                    'images/default.png',
                                                name: communityData['name'],
                                                username:
                                                    communityData['creator'],
                                                followers:
                                                    "${communityData['members'].length} followers",
                                                isFollowingMap:
                                                    newsSourcesController
                                                        .isFollowingMap,
                                                setIsFollowingMap:
                                                    newsSourcesController
                                                        .setIsFollowingMap, // Adjust as needed
                                              );
                                            },
                                          ),
                                        ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              width: 0.5,
                              color: Colors.black.withOpacity(0.15))),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        width: double.infinity,
                        height: (60 / MediaQuery.of(context).size.height) *
                            MediaQuery.of(context).size.height,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            newsSourcesController.registerUser(context);
                          },
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
                                    BorderRadius.all(Radius.circular(35)),
                              ),
                            ),
                          ),
                          child: newsSourcesController.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Next',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
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
