import 'package:flutter/material.dart';

import 'bottom_sheets/post_type_sheet.dart';

class TypeDropDown extends StatelessWidget {
  final String? postType;
  final BuildContext context;
  final void Function(String) setPostType;

  const TypeDropDown({
    super.key,
    required this.postType,
    required this.context,
    required this.setPostType,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Select Yarn Type'),
      subtitle: Text(
        postType != null ? 'Yarn to $postType' : 'Choose a type...',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () => showPostTypeSheet(context, setPostType),
    );
  }
}
