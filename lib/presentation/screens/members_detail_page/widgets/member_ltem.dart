import 'package:flutter/material.dart';

import '../../../../data/model/member_model.dart';
import '../../user_profile/user_profile.dart';

class MemberItem extends StatelessWidget {
  final Member member;

  const MemberItem({super.key, required this.member});

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
              viewerUserId: member.viewerUserId,
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
