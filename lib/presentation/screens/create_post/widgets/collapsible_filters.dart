import 'package:flutter/material.dart';

import 'anonymous_switch.dart';
import 'post_category_drop_down.dart';
import 'type_drop_down.dart';

class CollapsibleFilters extends StatelessWidget {
  final bool isAnonymous;
  final BuildContext context;
  final void Function(bool) setIsAnonymous;
  final String? postType;
  final String? postCategory;
  final void Function(String) setPostType;
  final void Function(String) setPostCategory;

  const CollapsibleFilters({
    super.key,
    required this.isAnonymous,
    required this.context,
    required this.setIsAnonymous,
    this.postType,
    this.postCategory,
    required this.setPostType,
    required this.setPostCategory,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filters'),
      children: [
        TypeDropDown(
          postType: postType,
          context: context,
          setPostType: setPostType,
        ),
        const SizedBox(height: 10),
        AnonymousSwitch(
          isAnonymous: isAnonymous,
          context: context,
          setIsAnonymous: setIsAnonymous,
        ),
        const SizedBox(height: 10),
        PostCategoryDropDown(
          postCategory: postCategory,
          context: context,
          setPostCategory: setPostCategory,
        ), // Add the new filter here
      ],
    );
  }
}
