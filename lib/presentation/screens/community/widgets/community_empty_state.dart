import 'package:flutter/material.dart';

class CommunityEmptyState extends StatelessWidget {
  final String title;
  final Future<List<dynamic>> Function(String) refreshCommunitiesMethod;
  final void Function() refreshState;

  const CommunityEmptyState({
    super.key,
    required this.title,
    required this.refreshCommunitiesMethod,
    required this.refreshState,
  });

  @override
  Widget build(BuildContext context) {
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
              await refreshCommunitiesMethod(''); // Retry fetching communities
              refreshState();
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
}
