import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart'; // for picking images

class CreateNews extends StatefulWidget {
  const CreateNews({super.key});

  @override
  CreateNewsState createState() => CreateNewsState();
}

class CreateNewsState extends State<CreateNews> with TickerProviderStateMixin {
  QuillController _controller = QuillController.basic();
  XFile? _coverPhoto;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();

  // Function to pick a cover photo
  Future<void> _pickCoverPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _coverPhoto = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Image.asset(
                              'images/BackButton.png',
                              height: 25,
                              color:Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 10,
                            child: Text(
                              'Create News',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color:Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.more_vert),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.05),
                    // Add Cover Photo Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: _pickCoverPhoto,
                        child: _coverPhoto != null
                            ? Image.file(
                          File(_coverPhoto!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter news title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ),
                    // Quill Editor
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: QuillEditor.basic(
                            controller: _controller,
                            configurations: const QuillEditorConfigurations(),
                          ),
                        ),
                      ),
                    ),
                    // Custom Toolbar
                    SizedBox(
                      height: 50, // Adjust the height as needed
                      child: CustomToolbar(controller: _controller),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width: 0.5, color: Colors.black.withOpacity(0.15))),
                  color: Colors.white,
                ),
                child: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library),
                        onPressed: () {
                          // Handle photo attachment
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_size),
                        onPressed: () {
                          // Handle text capitalization (optional functionality)
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // Handle more options
                        },
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Handle publish action
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<
                              Color>(
                                (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return Colors.white;
                              }
                              return const Color(0xFF500450);
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<
                              Color>(
                                (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return const Color(0xFF500450);
                              }
                              return Colors.white;
                            },
                          ),
                          elevation: WidgetStateProperty.all<double>(4.0),
                          shape: WidgetStateProperty.all<
                              RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(15)),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Publish',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomToolbar extends StatefulWidget {
  final QuillController controller;

  const CustomToolbar({Key? key, required this.controller}) : super(key: key);

  @override
  _CustomToolbarState createState() => _CustomToolbarState();
}

class _CustomToolbarState extends State<CustomToolbar> {
  bool _isExpanded = false; // Track whether the toolbar is expanded

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50, // Adjust the height as needed
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                QuillIconButton(
                  icon: Icons.format_bold,
                  onPressed: () =>
                      widget.controller.formatSelection(Attribute.bold),
                ),
                QuillIconButton(
                  icon: Icons.format_italic,
                  onPressed: () =>
                      widget.controller.formatSelection(Attribute.italic),
                ),
                QuillIconButton(
                  icon: Icons.format_underline,
                  onPressed: () =>
                      widget.controller.formatSelection(Attribute.underline),
                ),
                QuillIconButton(
                  icon: Icons.format_strikethrough,
                  onPressed: () =>
                      widget.controller.formatSelection(
                          Attribute.strikeThrough),
                ),
                QuillIconButton(
                  icon: Icons.image,
                  onPressed: () {
                    // Your image insertion logic
                  },
                ),
                if (!_isExpanded) ...[
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      setState(() {
                        _isExpanded = true; // Expand the toolbar
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_isExpanded)
          SizedBox(
            height: 50, // Adjust the height as needed
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  QuillIconButton(
                    icon: Icons.format_align_left,
                    onPressed: () =>
                        widget.controller.formatSelection(
                            Attribute.leftAlignment),
                  ),
                  QuillIconButton(
                    icon: Icons.format_align_center,
                    onPressed: () =>
                        widget.controller.formatSelection(
                            Attribute.centerAlignment),
                  ),
                  QuillIconButton(
                    icon: Icons.format_align_right,
                    onPressed: () =>
                        widget.controller.formatSelection(
                            Attribute.rightAlignment),
                  ),
                  QuillIconButton(
                    icon: Icons.format_align_justify,
                    onPressed: () =>
                        widget.controller.formatSelection(
                            Attribute.justifyAlignment),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_up),
                    onPressed: () {
                      setState(() {
                        _isExpanded = false; // Collapse the toolbar
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class QuillIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const QuillIconButton({Key? key, required this.icon, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}
