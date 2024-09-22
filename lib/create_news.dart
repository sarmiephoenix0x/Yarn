import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:image_picker/image_picker.dart';

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
  final FocusNode _titleFocusNode = FocusNode();

  Future<void> _pickCoverPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _coverPhoto = image;
    });
  }

  Future<void> _insertImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageBytes = await image.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);
      final imageUrl = 'data:image/png;base64,$imageBase64';

      // Create a Delta to insert the image
      final delta = Delta()
        ..insert('\n') // Optional: Add a new line before the image
        ..insert(imageUrl, {'image': imageUrl}); // Embed the image

      // Use the insert method instead
      _controller.document.insert(_controller.selection.baseOffset, delta);

      // Optionally, update the selection to be at the end of the inserted image
      _controller.updateSelection(
        TextSelection.collapsed(offset: _controller.selection.baseOffset + 1),
        ChangeSource.local,
      );
    }
  }




  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.format_quote),
                title: Text('Insert Quote'),
                onTap: () {
                  // Logic to insert quote
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.link),
                title: Text('Insert Link'),
                onTap: () {
                  // Logic to insert link
                  Navigator.pop(context);
                },
              ),
              // Add more options here
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Image.asset(
                                  'images/BackButton.png',
                                  height: 25,
                                  color:
                                  Theme.of(context).colorScheme.onSurface,
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
                                    color:
                                    Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.more_vert),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
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
                              child: const Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _titleController,
                            focusNode: _titleFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Enter news title',
                              border: const OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 10.0),
                            ),
                            onSubmitted: (_) {
                              _titleFocusNode
                                  .unfocus(); // Unfocus title when submitted
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Colors.grey[300]!)),
                              // Only top border
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: QuillEditor.basic(
                              controller: _controller,
                              configurations: const QuillEditorConfigurations(),
                              focusNode: FocusNode(),
                              scrollController: ScrollController(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 0.5,
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomToolbar(
                      controller: _controller,
                      onImagePressed: _insertImage,
                      onMorePressed: () => _showMoreOptions(context),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Handle publish action
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white;
                            }
                            return const Color(0xFF500450);
                          },
                        ),
                        foregroundColor:
                        MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return const Color(0xFF500450);
                            }
                            return Colors.white;
                          },
                        ),
                        elevation: MaterialStateProperty.all<double>(4.0),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomToolbar extends StatelessWidget {
  final QuillController controller;
  final VoidCallback onImagePressed;
  final VoidCallback onMorePressed;

  const CustomToolbar({
    Key? key,
    required this.controller,
    required this.onImagePressed,
    required this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconColor = Theme.of(context).iconTheme.color ?? Colors.black;

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.format_bold, color: iconColor),
          onPressed: () => controller.formatSelection(Attribute.bold),
        ),
        IconButton(
          icon: Icon(Icons.format_italic, color: iconColor),
          onPressed: () => controller.formatSelection(Attribute.italic),
        ),
        IconButton(
          icon: Icon(Icons.format_underline, color: iconColor),
          onPressed: () => controller.formatSelection(Attribute.underline),
        ),
        IconButton(
          icon: Icon(Icons.image, color: iconColor),
          onPressed: onImagePressed,
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, color: iconColor),
          onPressed: onMorePressed,
        ),
      ],
    );
  }
}
