import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final String baseUrl = 'https://yarnapi-n2dw.onrender.com/communities/';
  final storage = const FlutterSecureStorage();

  Future<List<dynamic>> fetchCommunities(String endpoint) async {
    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
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
      setState(() {}); // Refresh the UI
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
      setState(() {}); // Refresh the UI
    } else {
      _showCustomSnackBar(
        context,
        'Failed to leave community: ${response.reasonPhrase}',
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

  Widget communityItem(dynamic community) {
    return author(
      community['communityProfilePictureUrl'] ?? 'images/ProfileImg.png',
      community['name'],
      community['description'],
      "${community['members'].length} members",
      false, // Placeholder for isFollowing
      community['communityId'],
    );
  }

  Widget author(String img, String name, String description, String followers,
      bool isFollowing, int pageId) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityDetailPage(communityId: pageId),
          ),
        );
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
                  Text(followers,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

  Widget buildSection(String title, Future<List<dynamic>> future) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF500450)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load $title'));
                } else {
                  final communities = snapshot.data!;
                  return ListView.builder(
                    itemCount: communities.length,
                    itemBuilder: (context, index) {
                      return communityItem(communities[index]);
                    },
                  );
                }
              },
            ),
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
          buildSection('All Communities', fetchCommunities('')),
          buildSection('Created Communities', fetchCommunities('created')),
          buildSection('Joined Communities', fetchCommunities('joined')),
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
