import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/widgets/custom_snackbar.dart';
import '../../data/services/chat_service.dart';
import '../../data/services/chat_signalr_service.dart';

class ChatPageController extends ChangeNotifier {
  late ChatService chatService;
  late ChatSignalR chatSignalR;
  List<dynamic> _messages = [];
  TextEditingController _messageController = TextEditingController();
  List<File> _selectedImages = [];
  bool _messagesLoaded = false;
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String _currentPlayingFilePath = '';
  String? _selectedAudioFile;
  List<Map<String, dynamic>> _unsentMessages = [];
  List<Map<String, dynamic>> _pendingImageMessages = [];
  List<Map<String, dynamic>> _pendingAudioMessages = [];
  StreamSubscription<ConnectivityResult>? connectivitySubscription;
  bool _isLoading = true;
  final int receiverId;
  final int senderId;

  ChatPageController({required this.receiverId, required this.senderId}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  List get messages => _messages;
  bool get isPlaying => _isPlaying;
  String get currentPlayingFilePath => _currentPlayingFilePath;
  bool get isRecording => _isRecording;
  String? get selectedAudioFile => _selectedAudioFile;

  ScrollController get scrollController => _scrollController;
  TextEditingController get messageController => _messageController;

  void initialize() {
    // _recorder.openRecorder();
    _player.openPlayer();
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _retrySendingMessages(); // Retry sending text messages
        _retrySendingImageMessages(); // Retry sending image messages
        // _retrySendingAudioMessages();
        retryMessageLoad();
      }
    });
    chatService = ChatService();
    chatSignalR = ChatSignalR();

    // Initialize SignalR and listen for incoming messages
    initSignalR();
  }

  Future<void> initSignalR() async {
    await _checkPermissions();
    try {
      await chatSignalR.initSignalR(); // Wait for SignalR initialization
      chatSignalR.onMessageReceived((messageId) async {
        print('Message received with ID: $messageId');
        try {
          final newMessage = await chatService.fetchNewMessage(messageId);
          print('New message fetched: $newMessage');

          messages.add(newMessage);
          notifyListeners();
        } catch (e) {
          print('Error fetching new message: $e');
        }
      });

      // Load messages on init (for demo, fetch by a specific chatId, e.g., 1)
      await loadMessages();
    } catch (e) {
      print('Error initializing SignalR: $e');
    }
  }

  Future<void> retryMessageLoad() async {
    _messagesLoaded = false;
    await loadMessages();
  }

  Future<void> loadMessages() async {
    if (!_messagesLoaded) {
      _isLoading = true; // Show loading spinner while fetching

      try {
        final List<dynamic> chats = await chatService.fetchChats();

        // Find the chat based on both senderId and receiverId
        final chat = chats.firstWhere(
          (chat) =>
              (chat['lastMessage']['receiverId'] == receiverId &&
                  chat['lastMessage']['senderId'] == senderId) ||
              (chat['lastMessage']['receiverId'] == senderId &&
                  chat['lastMessage']['senderId'] == receiverId),
          orElse: () => null,
        );

        if (chat != null) {
          int chatId = chat['chatId']; // Get chatId from the fetched chat

          // Fetch messages for the found chatId
          final fetchedMessages = await chatService.fetchMessages(chatId);

          if (fetchedMessages.isNotEmpty) {
            _messages = fetchedMessages;
            _messagesLoaded = true;
            _isLoading = false; // Stop loading spinner
            notifyListeners();

            // Scroll to the bottom of the messages list
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          } else {
            _isLoading = false;
            notifyListeners();
            CustomSnackbar.show('No messages available.', isError: true);
          }
        } else {
          _isLoading = false;
          notifyListeners();
          CustomSnackbar.show(
            'No chats found for the selected user.',
            isError: true,
          );
        }
      } catch (e) {
        if (!_messagesLoaded) {
          _isLoading = false; // Stop loading spinner

          print("Error fetching messages: $e");
        }
      }
    }
  }

  Future<void> sendMessage() async {
    if (_messageController.text.isNotEmpty ||
        _selectedImages.isNotEmpty ||
        _selectedAudioFile != null) {
      // Create a message object to display immediately
      final message = {
        'text':
            _messageController.text.isNotEmpty ? _messageController.text : null,
        'senderId': senderId,
        'imageUrls': _selectedImages.map((image) => image.path).toList(),
        'audioUrl': _selectedAudioFile,
        'isSent': false, // Initially set to false
        'timeSent': DateTime.now(), // Add a timestamp for ordering
      };

      // Add the message to the list to display it immediately

      messages.add(message);
      _messageController.clear();
      _selectedImages.clear();
      notifyListeners();

      // Scroll to the bottom after adding the new message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      // Try sending the message to the server
      try {
        File? audioFile;
        if (_selectedAudioFile != null) {
          audioFile = File(_selectedAudioFile!); // Convert the path to a File
        }

        await chatService.sendMessage(
          receiverId: receiverId,
          text: message['text'] as String?, // Cast text to String?
          audioFile: audioFile, // Send audio file
          images: (message['imageUrls'] as List<dynamic>?)
              ?.map((imagePath) => File(imagePath as String))
              .toList(), // Convert image paths to List<File>
        );

        // If successful, update the message to "sent"

        message['isSent'] = true;
        _selectedAudioFile = null; // Clear after successful send
        notifyListeners();
      } catch (e) {
        // If sending fails, store the message in the unsent queue
        _storeUnsentMessage(message);

        _selectedAudioFile = null; // Clear if there's an error
      }
    }
  }

  void _storeUnsentMessage(Map<String, dynamic> message) {
    _unsentMessages.add(message);
    // Optionally, you can persist this queue locally using shared preferences or secure storage
  }

  Future<void> _retrySendingMessages() async {
    for (var message in List<Map<String, dynamic>>.from(_unsentMessages)) {
      try {
        File? audioFile;
        if (message['audioUrl'] != null) {
          audioFile = File(message['audioUrl']); // Convert the path to a File
        }

        await chatService.sendMessage(
          receiverId: receiverId,
          text: message['text'],
          audioFile: audioFile,
          images: message['imageUrls'].isNotEmpty ? message['imageUrls'] : null,
        );

        // Update the message to "sent" and remove it from the unsent queue

        message['isSent'] = true;
        notifyListeners();
        _unsentMessages.remove(message); // Remove from the queue
      } catch (e) {
        // If it fails again, keep it in the queue
        print("Failed to resend message: $e");
      }
    }
  }

  Future<void> retrySendingAudioMessages() async {
    List<Map<String, dynamic>> messagesToRemove = [];

    for (var pendingMessage in _pendingAudioMessages) {
      try {
        File? audioFile;
        if (pendingMessage['audioUrl'] != null) {
          audioFile = File(pendingMessage['audioUrl']); // Convert path to File
        }

        await chatService.sendMessage(
          receiverId: pendingMessage['receiverId'],
          audioFile: audioFile, // Send the audio file
        );

        // Mark the message as sent in the message list

        final index = messages.indexWhere((msg) =>
            msg['audioUrl'] != null &&
            msg['audioUrl'] == pendingMessage['audioUrl']);
        if (index != -1) {
          messages[index]['isSent'] = true; // Update to true after send
        }
        notifyListeners();

        // Remove successfully sent message from pending list
        messagesToRemove.add(pendingMessage);
      } catch (e) {
        // If sending fails, keep it in the pending list for another retry
      }
    }

    // Remove messages that have been successfully sent from the pending list

    _pendingAudioMessages.removeWhere((msg) => messagesToRemove.contains(msg));
    notifyListeners();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("Microphone permission not granted");
      return;
    }
  }

  Future<void> startRecording() async {
    try {
      // Check and request necessary permissions
      await _checkPermissions();

      // Stop any currently playing audio
      if (_isPlaying) {
        await _player.stopPlayer();

        _isPlaying = false;
        _currentPlayingFilePath = '';
        notifyListeners();
      }

      // Open the recorder
      await _recorder.openRecorder();

      // Define file path for recording
      Directory tempDir = await getTemporaryDirectory();
      String filePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

      // Start recording
      await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);

      _isRecording = true;
      _selectedAudioFile = null;
      notifyListeners();
    } catch (e) {
      print("Error while starting recorder: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      // Stop the recorder
      String? filePath = await _recorder.stopRecorder();

      _isRecording = false;
      _selectedAudioFile = filePath; // Save the recorded file path
      notifyListeners();

      if (_currentPlayingFilePath != '') {
        await _player.startPlayer(fromURI: _currentPlayingFilePath);

        _isPlaying = true;
        notifyListeners();
      }
    } catch (e) {
      print("Error while stopping recorder: $e");
    }
  }

  Future<void> togglePlayPause(String filePath) async {
    if (_isPlaying && _currentPlayingFilePath == filePath) {
      // If currently playing, stop the player
      await _player.stopPlayer();

      _isPlaying = false;
      _currentPlayingFilePath = '';
      notifyListeners();
    } else {
      // If playing a different file, stop the current audio first
      if (_isPlaying) {
        await _player.stopPlayer();

        _isPlaying = false;
        _currentPlayingFilePath = '';
        notifyListeners();
      }

      // Start playing the new file
      await _player.startPlayer(
        fromURI: filePath,
        whenFinished: () {
          _isPlaying = false;
          _currentPlayingFilePath = '';
          notifyListeners();
        },
      );

      _isPlaying = true;
      _currentPlayingFilePath = filePath;
      notifyListeners();
    }
  }

  void deleteVoiceNote() {
    _selectedAudioFile = null;
    notifyListeners();
  }

  // Helper function to determine whether to append '/download?project=66e4476900275deffed4' or not
  String getAudioPath(String audioUrl) {
    // If it's a network file (from backend), append /download?project=66e4476900275deffed4
    if (audioUrl.startsWith('http')) {
      return '$audioUrl/download?project=66e4476900275deffed4';
    } else {
      // Otherwise, return the local file path
      return audioUrl;
    }
  }

  Future<void> selectImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      _selectedImages = images.map((image) => File(image.path)).toList();
    }
  }

  Future<void> _retrySendingImageMessages() async {
    List<Map<String, dynamic>> messagesToRemove = [];

    for (var pendingMessage in _pendingImageMessages) {
      try {
        await chatService.sendMessage(
          receiverId: pendingMessage['receiverId'],
          images: [pendingMessage['imageFile']],
        );

        // Mark the message as sent in the message list

        final index = messages.indexWhere((msg) =>
            msg['imageUrls'] != null &&
            msg['imageUrls'].contains(pendingMessage['imageFile'].path));
        if (index != -1) {
          messages[index]['isSent'] = true; // Update to true after send
        }
        notifyListeners();

        // Remove successfully sent message from pending list
        messagesToRemove.add(pendingMessage);
      } catch (e) {
        // If sending fails, keep it in the pending list for another retry
      }
    }

    // Remove messages that have been successfully sent from the pending list

    _pendingImageMessages.removeWhere((msg) => messagesToRemove.contains(msg));
    notifyListeners();
  }

  Future<void> selectImagesFromGallery() async {
    final pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages != null) {
      List<Map<String, dynamic>> unsentMessages = [];

      for (var pickedImage in pickedImages) {
        File imageFile = File(pickedImage.path);

        // Add the image message to the messages list immediately

        messages.add({
          'text': null,
          'senderId': senderId,
          'imageUrls': [imageFile.path], // Add the image path
          'audioUrl': null,
          'isSent': false, // Initially set isSent to false
        });
        notifyListeners();

        // Add the unsent message to the pending list
        unsentMessages.add({
          'receiverId': receiverId,
          'imageFile': imageFile,
        });
      }

      // Send the images to the server in the background
      for (var unsentMessage in unsentMessages) {
        try {
          await chatService.sendMessage(
            receiverId: unsentMessage['receiverId'],
            images: [unsentMessage['imageFile']],
          );

          // Mark the message as sent in the message list

          final index = messages.indexWhere((msg) =>
              msg['imageUrls'] != null &&
              msg['imageUrls'].contains(unsentMessage['imageFile'].path));
          if (index != -1) {
            messages[index]['isSent'] = true; // Update to true after send
          }
          notifyListeners();
        } catch (e) {
          // Add unsent message to pendingImageMessages for retry

          _pendingImageMessages.add(unsentMessage);
          notifyListeners();
        }
      }
    }
  }
}
