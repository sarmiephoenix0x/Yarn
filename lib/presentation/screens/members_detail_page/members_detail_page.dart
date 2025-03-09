import 'package:flutter/material.dart';

import '../../../data/model/member_model.dart';
import 'widgets/member_ltem.dart';

class MembersListPage extends StatelessWidget {
  final List<Member> members;
  final int senderId;

  const MembersListPage(
      {super.key, required this.members, required this.senderId});

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
