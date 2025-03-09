import 'package:flutter/material.dart' hide CarouselController;

class InteractionRow extends StatelessWidget {
  bool isLiked;
  final List<String> postImg;

  InteractionRow({
    super.key,
    required this.isLiked,
    required this.postImg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey),
            onPressed: () {
              isLiked = !isLiked;
            },
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.comment), onPressed: () {}),
          const Spacer(),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
    );
  }
}
