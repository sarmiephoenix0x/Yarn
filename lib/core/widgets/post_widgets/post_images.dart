import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;

import '../video_player.dart';

class PostImages extends StatelessWidget {
  final List<String> mediaUrls;
  final ValueNotifier<int> currentIndex;

  const PostImages({
    super.key,
    required this.mediaUrls,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: false,
          enlargeCenterPage: false,
          aspectRatio: 14 / 9,
          viewportFraction: 1.0,
          enableInfiniteScroll: true,
          onPageChanged: (index, reason) {
            // Update the current index directly without setState
            currentIndex.value = index;
          },
        ),
        items: mediaUrls.map((url) {
          if (url.endsWith('.mp4')) {
            // If the URL is a video
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayerWidget(url: url),
            );
          } else {
            // If the URL is an image
            return Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
            );
          }
        }).toList(),
      ),
    );
  }
}
