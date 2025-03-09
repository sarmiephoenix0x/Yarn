import 'package:flutter/material.dart';

import 'bottom_sheets/post_category_sheet.dart';

class PostCategoryDropDown extends StatelessWidget {
  final String? postCategory;
  final BuildContext context;
  final void Function(String) setPostCategory;

  const PostCategoryDropDown({
    super.key,
    required this.postCategory,
    required this.context,
    required this.setPostCategory,
  });

  @override
  Widget build(BuildContext context) {
    Icon categoryIcon;
    Color categoryColor;

    if (postCategory == 'announcement') {
      categoryIcon = Icon(Icons.info, color: Colors.blue);
      categoryColor = Colors.blue;
    } else if (postCategory == 'warning') {
      categoryIcon = Icon(Icons.warning, color: Colors.orange);
      categoryColor = Colors.orange;
    } else if (postCategory == 'alert') {
      categoryIcon = Icon(Icons.warning, color: Colors.red);
      categoryColor = Colors.red;
    } else {
      categoryIcon =
          Icon(Icons.arrow_drop_down, color: Theme.of(context).iconTheme.color);
      categoryColor = Theme.of(context).colorScheme.onSurface;
    }

    return ListTile(
      title: const Text('Yarn Category'),
      subtitle: Row(
        children: [
          categoryIcon,
          const SizedBox(width: 8),
          Text(
            postCategory != null ? postCategory! : 'Choose a category...',
            style: TextStyle(color: categoryColor),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () => showPostCategorySheet(context, setPostCategory),
    );
  }
}
