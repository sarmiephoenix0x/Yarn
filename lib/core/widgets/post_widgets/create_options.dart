import 'package:flutter/material.dart';

import '../../../presentation/screens/create_community/create_community.dart';
import '../../../presentation/screens/create_page/create_page.dart';
import '../../../presentation/screens/create_post/create_post.dart';

void showCreateOptions(
    BuildContext context, void Function(bool) resetHasFetchedData) {
  //resetHasFetchedData(false);
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.post_add),
            title: Text('Create Yarn'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePost(key: UniqueKey()),
                ),
              );

              // Navigator.pop(context); // Close the bottom sheet
            },
          ),
          ListTile(
            leading: Icon(Icons.pageview),
            title: Text('Create Page'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePage(key: UniqueKey()),
                ),
              );

              // Navigator.pop(context); // Close the bottom sheet
            },
          ),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text('Create Community'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateCommunity(key: UniqueKey()),
                ),
              );

              // Navigator.pop(context); // Close the bottom sheet
            },
          ),
        ],
      );
    },
  );
}
