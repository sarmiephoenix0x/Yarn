import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/create_post_controller.dart';
import 'widgets/bottom_options.dart';
import 'widgets/collapsible_filters.dart';
import 'widgets/content_field.dart';
import 'widgets/cover_photo_section.dart';
import 'widgets/image_preview_section.dart';
import 'widgets/label_input.dart';
import 'widgets/location_section.dart';
import 'widgets/title_section.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  CreatePostState createState() => CreatePostState();
}

class CreatePostState extends State<CreatePost> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreatePostController(postContext: context),
      child: Consumer<CreatePostController>(
          builder: (context, createPostController, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Yarn'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover Photo Section
                        CoverPhotoSection(
                          coverPhoto: createPostController.coverPhoto,
                          pickCoverPhotoMethod:
                              createPostController.pickCoverPhoto,
                        ),
                        const SizedBox(height: 20),
                        // Title Section
                        TitleSection(
                          titleController: createPostController.titleController,
                        ),
                        const SizedBox(height: 20),
                        // Post Type Dropdown
                        CollapsibleFilters(
                          isAnonymous: createPostController.isAnonymous,
                          context: context,
                          setIsAnonymous: createPostController.setIsAnonymous,
                          setPostType: createPostController.setPostType,
                          setPostCategory: createPostController.setPostCategory,
                        ),
                        const SizedBox(height: 20),
                        LocationSection(
                          isLoadingCity: createPostController.isLoadingCity,
                          cities: createPostController.cities,
                          setSelectedCity: createPostController.setSelectedCity,
                        ),
                        const SizedBox(height: 20),
                        LabelInput(
                          labels: createPostController.labels,
                          labelController: createPostController.labelController,
                          removeLabel: createPostController.removeLabel,
                          clearLabelController:
                              createPostController.clearLabelController,
                        ), // Add label input here
                        const SizedBox(height: 20),
                        // Image Preview Section
                        if (createPostController.selectedImages!.isNotEmpty)
                          ImagePreviewSection(
                            selectedImages: createPostController.selectedImages,
                            selectedVideos: createPostController.selectedVideos,
                            removeVideoMethod: createPostController.removeVideo,
                          ),
                        const SizedBox(height: 20),
                        // Body Section (Text Field)
                        ContentField(
                          textController: createPostController.textController,
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Options Section
                BottomOptions(
                  isLoading: createPostController.isLoading,
                  publishPostMethod: createPostController.publishPost,
                  pickImage: createPostController.pickImage,
                  pickVideo: createPostController.pickVideo,
                  context: context,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
