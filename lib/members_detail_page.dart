import 'package:flutter/material.dart';
import 'package:yarn/user_profile.dart';

class MembersListPage extends StatelessWidget {
  final List<Member> members;
  final int senderId;

  MembersListPage({required this.members, required this.senderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Members')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            return MemberItem(member: members[index]);
          },
        ),
      ),
    );
  }
}

class Member {
  final int id;
  final String username;
  final String profilePictureUrl; // This can be nullable
  final String description;
  final int senderId; // Add senderId field

  Member({
    required this.id,
    required this.username,
    String? profilePictureUrl, // Make this nullable
    required this.description,
    required this.senderId, // Add senderId as a required parameter
  }) : this.profilePictureUrl =
            profilePictureUrl ?? ''; // Default to empty string if null
}

class MemberItem extends StatelessWidget {
  final Member member;

  MemberItem({required this.member});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfile(
              key: UniqueKey(),
              userId: member.id,
              senderId: member.senderId,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipOval(
                child: member.profilePictureUrl.isNotEmpty
                    ? Image.network(
                        member.profilePictureUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'images/ProfileImg.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    // Text(
                    //   member.description,
                    //   style: const TextStyle(color: Colors.grey),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
