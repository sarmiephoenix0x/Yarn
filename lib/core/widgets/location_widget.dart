import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../presentation/screens/user_profile/user_profile.dart';

class LocationWidget extends StatelessWidget {
  // final String img;
  final String name;
  bool isFollowing;
  final int locationId;
  final int senderId;
  final Map<String, bool> isFollowingMap;
  final FlutterSecureStorage storage;
  final void Function(String, bool) setIsFollowingMap;

  LocationWidget({
    super.key,
    // required this.img,
    required this.name,
    required this.isFollowing,
    required this.locationId,
    required this.senderId,
    required this.isFollowingMap,
    required this.storage,
    required this.setIsFollowingMap,
  });

  @override
  Widget build(BuildContext context) {
    isFollowing = isFollowingMap[locationId.toString()] ?? false;
    Future<void> followLocation() async {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url =
          'https://yarnapi-fuu0.onrender.com/api/locations/$locationId/follow';
      try {
        final response = await http.patch(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({}), // Add an empty body if required
        );

        if (response.statusCode == 200) {
          // Check if response body is not empty before parsing
          if (response.body.isNotEmpty) {
            final responseData = json.decode(response.body);
            print('Follow successful: ${responseData['message']}');
          } else {
            print('Follow successful: No response body');
          }

          isFollowingMap[locationId.toString()] = true;
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (error) {
        print('Follow error: $error');
      }
    }

    Future<void> unfollowLocation() async {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url =
          'https://yarnapi-fuu0.onrender.com/api/locations/$locationId/unfollow';
      try {
        final response = await http.patch(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({}), // Add an empty body if required
        );

        if (response.statusCode == 200) {
          // Check if response body is not empty before parsing
          if (response.body.isNotEmpty) {
            final responseData = json.decode(response.body);
            print('Unfollow successful: ${responseData['message']}');
          } else {
            print('Unfollow successful: No response body');
          }

          setIsFollowingMap(locationId.toString(), false);
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (error) {
        print('Unfollow error: $error');
      }
    }

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    // Text(
                    //   followers,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: const TextStyle(
                    //     fontFamily: 'Poppins',
                    //   ),
                    // ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  if (isFollowing) {
                    unfollowLocation();
                  } else {
                    followLocation();
                  }
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: isFollowing
                      ? const Text(
                          "Following",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "+ Follow",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
