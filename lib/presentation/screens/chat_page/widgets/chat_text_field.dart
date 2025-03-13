import 'package:flutter/material.dart' hide CarouselController;

import 'animated_button.dart';

class ChatTextField extends StatelessWidget {
  final bool isRecording;
  final String? selectedAudioFile;
  final bool isPlaying;
  final String currentPlayingFilePath;
  final TextEditingController messageController;
  final Future<void> Function() stopRecordingMethod;
  final Future<void> Function() startRecordingMethod;
  final Future<void> Function() selectImagesFromGalleryMethod;
  final Future<void> Function(String) togglePlayPauseMethod;
  final Future<void> Function() sendMessageMethod;
  final void Function() deleteVoiceNoteMethod;

  const ChatTextField({
    super.key,
    required this.isRecording,
    required this.selectedAudioFile,
    required this.isPlaying,
    required this.currentPlayingFilePath,
    required this.messageController,
    required this.stopRecordingMethod,
    required this.startRecordingMethod,
    required this.selectImagesFromGalleryMethod,
    required this.togglePlayPauseMethod,
    required this.sendMessageMethod,
    required this.deleteVoiceNoteMethod,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          if (isRecording)
            InkWell(
              onTap: () async {
                if (isRecording) {
                  await stopRecordingMethod();
                } else {
                  await startRecordingMethod();
                }
              },
              child: const Icon(
                Icons.stop,
              ),
            )
          else
            InkWell(
              onTap: () async {
                if (isRecording) {
                  await stopRecordingMethod();
                } else {
                  await startRecordingMethod();
                }
              },
              child: const Icon(
                Icons.mic,
              ),
            ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          IconButton(
            icon: Icon(Icons.image,
                color: isDarkMode ? Color(0xFF7A0D7D) : Color(0xFF500450)),
            onPressed: () async {
              await selectImagesFromGalleryMethod();
            }, // Implement this method
          ),
          Expanded(
            child: selectedAudioFile == null
                ? TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                    ),
                  )
                : Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying &&
                                  currentPlayingFilePath == selectedAudioFile
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () =>
                            togglePlayPauseMethod(selectedAudioFile!),
                      ),
                      const Text(
                        'Voice Note',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Inter',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: deleteVoiceNoteMethod,
                      ),
                    ],
                  ),
          ),
          if (selectedAudioFile == null)
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          AnimatedButton(
              icon: Icons.send,
              onTap: () {
                sendMessageMethod(); // Implement send message functionality
              }),
        ],
      ),
    );
  }
}
