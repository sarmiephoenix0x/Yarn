import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yarn/members_detail_page.dart';

class CommunityPage extends StatefulWidget {
  final int senderId;
  const CommunityPage({super.key, required this.senderId});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final String baseUrl = 'https://yarnapi-n2dw.onrender.com/api/communities/';
  final storage = const FlutterSecureStorage();
  Map<int, bool> _isFollowingMap = {};

  Future<List<dynamic>> fetchCommunities(String endpoint) async {
    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        return decodedResponse['data']; // Extract the list from the 'data' key
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showCustomSnackBar(
        context,
        e.toString(),
        isError: true,
      );
      return [];
    }
  }

  Future<void> joinCommunity(int communityId) async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final response = await http.patch(
      Uri.parse('$baseUrl$communityId/join'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      _showCustomSnackBar(
        context,
        'Joined community successfully',
        isError: false,
      );
      setState(() {
        // Update the isFollowing state for the community
        // Assuming you have a way to identify the community in your state
        // For example, you could maintain a Map<int, bool> to track isFollowing state
        _isFollowingMap[communityId] = true; // Mark as following
      });
    } else {
      _showCustomSnackBar(
        context,
        'Failed to join community: ${response.reasonPhrase}',
        isError: true,
      );
    }
  }

  Future<void> leaveCommunity(int communityId) async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final response = await http.patch(
      Uri.parse('$baseUrl$communityId/leave'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      _showCustomSnackBar(
        context,
        'Left community successfully',
        isError: false,
      );
      setState(() {
        // Update the isFollowing state for the community
        _isFollowingMap[communityId] = false; // Mark as not following
      });
    } else {
      _showCustomSnackBar(
        context,
        'Failed to leave community: ${response.reasonPhrase}',
        isError: true,
      );
    }
  }

  Future<List<dynamic>> refreshCommunities(String endpoint) async {
    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        return decodedResponse['data']; // Extract the list from the 'data' key
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      return []; // Return an empty list on error
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

  Widget communityItem(dynamic community) {
    bool isFollowing = _isFollowingMap[community['communityId']] ?? false;
    return author(
      img: community['communityProfilePictureUrl'] != null
          ? community['communityProfilePictureUrl'] +
              '/download?project=66e4476900275deffed4'
          : '',
      name: community['name'],
      description: community['description'],
      followers:
          "${community['members'].length} members", // Updated to show member count
      isFollowing: isFollowing, // Placeholder for isFollowing
      pageId:
          community['communityId'], // Assuming the community ID is available
      members: community['members'], // Pass members data
      context: context, // Pass the BuildContext
    );
  }

  Widget author({
    required String img,
    required String name,
    required String description,
    required String followers,
    required bool isFollowing,
    required int pageId,
    required List<dynamic> members,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => CommunityDetailPage(communityId: pageId),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(55),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.grey,
                child: img.isNotEmpty
                    ? Image.network(img, fit: BoxFit.cover)
                    : Image.asset('images/ProfileImg.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(followers,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  // Display member images in a stacked manner
                  SizedBox(
                    height: 40, // Set a fixed height for the stack
                    child: Stack(
                      children: members.asMap().entries.map<Widget>((entry) {
                        int index = entry.key;
                        var member = entry.value;
                        return Positioned(
                          left: index * 20.0, // Adjust the offset for stacking
                          child: GestureDetector(
                            onTap: () {
                              // When the icon is tapped, navigate to the Members List Page
                              List<Member> membersList =
                                  members.map<Member>((memberData) {
                                return Member(
                                  id: memberData['memberId'],
                                  username: memberData['username'],
                                  profilePictureUrl: memberData[
                                              'profilePictureUrl'] !=
                                          null
                                      ? memberData['profilePictureUrl'] +
                                          '/download?project=66e4476900275deffed4'
                                      : '',
                                  description:
                                      'Member description here', // Placeholder
                                  senderId:
                                      widget.senderId, // Pass the senderId here
                                );
                              }).toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MembersListPage(
                                    members: membersList,
                                    senderId: widget.senderId,
                                  ),
                                ),
                              );
                            },
                            child: ClipOval(
                              child: member['profilePictureUrl'] != null
                                  ? Image.network(
                                      member['profilePictureUrl'] +
                                          '/download?project=66e4476900275deffed4',
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'images/ProfileImg.png',
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isFollowing
                  ? () => leaveCommunity(pageId)
                  : () => joinCommunity(pageId),
              child: Text(isFollowing ? 'Leave' : 'Join'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, String endpoint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        FutureBuilder<List<dynamic>>(
          future: refreshCommunities(
              endpoint), // Fetch communities for the first time
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: Color(0xFF500450)));
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load $title'));
            } else {
              final communities = snapshot.data!;
              if (communities.isEmpty) {
                return _buildEmptyState(title);
              } else {
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(), // Prevent scrolling
                  shrinkWrap:
                      true, // Allow ListView to take only necessary space
                  itemCount: communities.length,
                  itemBuilder: (context, index) {
                    return communityItem(communities[index]);
                  },
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 100, color: Colors.grey.shade600),
          const SizedBox(height: 20),
          Text('No communities available at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await refreshCommunities(''); // Retry fetching communities
              setState(() {}); // Trigger a rebuild
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF500450),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Communities')),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {}); // Trigger a rebuild to refresh all communities
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildSection('All Communities', ''),
                    buildSection('Created Communities', 'created'),
                    buildSection('Joined Communities', 'joined'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityDetailPage extends StatelessWidget {
  final int communityId;

  CommunityDetailPage({required this.communityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community Details')),
      body: Center(child: Text('Details for community $communityId')),
    );
  }
}
