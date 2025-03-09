import 'package:flutter/material.dart';

class CommunityDetailPage extends StatelessWidget {
  final int communityId;

  const CommunityDetailPage({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community Details')),
      body: Center(child: Text('Details for community $communityId')),
    );
  }
}
