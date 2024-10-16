import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'chat_provider.dart';

class ChatSignalR {
  final String serverUrl = "https://yarnapi.onrender.com/chatHub";
  late HubConnection hubConnection;
  final storage = const FlutterSecureStorage();

  Future<void> initSignalR() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    hubConnection = HubConnectionBuilder()
        .withUrl(
            serverUrl,
            HttpConnectionOptions(
              accessTokenFactory: () async => accessToken,
            ))
        .build();

    hubConnection.onclose((error) => print('Connection Closed: $error'));
    await hubConnection.start(); // Ensure start is awaited
  }

  void onMessageReceived(Function(int messageId) onMessage) {
    hubConnection.on("MessageReceived", (messageId) {
      onMessage(messageId?[0]);
    });
  }
}

// Main Chat Service class for sending/receiving messages and fetching data
class ChatService {
  final String apiUrl =
      "https://yarnapi.onrender.com/api"; // Replace with your API URL
  final Dio dio = Dio();
  final storage = const FlutterSecureStorage();

  ChatService() {
    _initialize(); // Call an async method for initialization
  }

  Future<void> _initialize() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    dio.options.headers["Authorization"] = "Bearer $accessToken";
  }

  // Send a message with optional text, audio, and images
  Future<void> sendMessage({
    required int receiverId,
    String? text,
    File? audioFile,
    List<File>? images,
  }) async {
    FormData formData = FormData();
    formData.fields.add(MapEntry("receiverId", receiverId.toString()));

    if (text != null) {
      formData.fields.add(MapEntry("text", text));
    }

    if (audioFile != null) {
      formData.files.add(MapEntry(
        "audio",
        await MultipartFile.fromFile(audioFile.path),
      ));
    }

    if (images != null) {
      for (var image in images) {
        formData.files.add(MapEntry(
          "images",
          await MultipartFile.fromFile(image.path),
        ));
      }
    }

    final response = await dio.post("$apiUrl/chats/", data: formData);

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print('Error sending message: ${response.statusCode}');
    }
  }

  // Fetch all chats
  Future<List<dynamic>> fetchChats() async {
    final response = await http.get(
      Uri.parse("$apiUrl/chats/"),
      headers: {"Authorization": dio.options.headers["Authorization"]!},
    );

    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if the response status is 'Success'
      if (responseData['status'] == 'Success') {
        final List<dynamic> chats =
            responseData['data']; // Extracting the list from 'data'

        // Sort chats by the last message's dateSent
        chats.sort((a, b) {
          return DateTime.parse(b['lastMessage']['dateSent'])
              .compareTo(DateTime.parse(a['lastMessage']['dateSent']));
        });

        return chats;
      } else {
        throw Exception('Failed to load chats: ${responseData['status']}');
      }
    } else {
      throw Exception('Failed to load chats: ${response.statusCode}');
    }
  }

  // Fetch messages in a chat
  Future<List<dynamic>> fetchMessages(int chatId) async {
    final response = await http.get(
      Uri.parse("$apiUrl/chats/messages/$chatId"),
      headers: {"Authorization": dio.options.headers["Authorization"]!},
    );
    print("Response body: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Check if 'data' is present and is a list
      if (data['status'] == 'Success' && data['data'] is List) {
        return data['data']; // Return the list of messages
      } else {
        throw Exception('Expected a list in data but got: $data');
      }
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  // Fetch the latest message using SignalR notification
  Future<Map<String, dynamic>> fetchNewMessage(int messageId) async {
    final response = await http.get(
      Uri.parse("$apiUrl/chats/message/new-message/$messageId"),
      headers: {"Authorization": dio.options.headers["Authorization"]!},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load new message');
    }
  }
}

// Main Chat Widget with UI for sending and receiving messages
class ChatPage extends StatefulWidget {
  final int receiverId;
  final int senderId;
  final String receiverName;
  final String profilePic;

  ChatPage(
      {required this.receiverId,
      required this.senderId,
      required this.receiverName,
      required this.profilePic});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatService chatService;
  late ChatSignalR chatSignalR;
  List<dynamic> messages = [];
  TextEditingController _messageController = TextEditingController();
  List<File> selectedImages = [];
  bool messagesLoaded = false;
  final ScrollController _scrollController = ScrollController();
  bool isSending = false;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String _currentPlayingFilePath = '';
  String? selectedAudioFile;

  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    messagesLoaded = false; // Reset to load messages again
    await loadMessages(); // Load the messages when returning to the chat
  }

  @override
  void initState() {
    super.initState();
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
        final newMessage = await chatService.fetchNewMessage(messageId);
        setState(() {
          messages.add(newMessage);
        });
      });

      // Load messages on init (for demo, fetch by a specific chatId, e.g., 1)
      await loadMessages();
    } catch (e) {
      print('Error initializing SignalR: $e');
    }
  }

  Future<void> loadMessages() async {
    if (!messagesLoaded) {
      try {
        final List<dynamic> chats = await chatService.fetchChats();

        // Find the chatId based on the receiverId
        final chat = chats.firstWhere(
          (chat) => chat['lastMessage']['receiverId'] == widget.receiverId,
          // Access receiverId from lastMessage
          orElse: () => null,
        );

        if (chat != null) {
          int chatId = chat['chatId']; // Get chatId from the fetched chat

          // Fetch messages for the found chatId
          final fetchedMessages = await chatService.fetchMessages(chatId);
          setState(() {
            messages = fetchedMessages;
            messagesLoaded = true; // Set the flag after loading
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        } else {
          print('Chat not found for receiverId: ${widget.receiverId}');
        }
      } catch (e) {
        print("Error fetching messages: $e");
      }
    }
  }

  Future<void> sendMessage() async {
    if (_messageController.text.isNotEmpty ||
        selectedImages.isNotEmpty ||
        selectedAudioFile != null) {
      setState(() {
        isSending = true; // Start sending animation
      });

      File? audioFile;
      if (selectedAudioFile != null) {
        audioFile = File(selectedAudioFile!); // Convert the path to a File
      }

      await chatService.sendMessage(
        receiverId: widget.receiverId,
        text:
            _messageController.text.isNotEmpty ? _messageController.text : null,
        audioFile: audioFile,
        images: selectedImages.isNotEmpty ? selectedImages : null,
      );

      // Add the message directly to the list after sending
      setState(() {
        messages.add({
          'text': _messageController.text,
          'senderId': widget.senderId,
          'imageUrls': selectedImages.map((image) => image.path).toList(),
          'audioUrl': selectedAudioFile,
          'isSent': false, // Initially set to false
        });
        _messageController.clear();
        selectedImages.clear();
        selectedAudioFile = null;
        isSending = false;
      });

      setState(() {
        messages.last['isSent'] = true; // Update to true after send
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Microphone permission not granted");
    }
  }

  Future<void> _startRecording() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Microphone permission not granted");
    }

    Directory tempDir = await getTemporaryDirectory();
    String filePath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    // Start recording using startRecorder
    await _recorder.startRecorder(toFile: filePath);

    setState(() {
      _isRecording = true;
      selectedAudioFile = null;
    });
  }

  Future<void> _stopRecording() async {
    String? filePath = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      selectedAudioFile = filePath; // Save the file path
    });
  }

  Future<void> _togglePlayPause(String filePath) async {
    if (_isPlaying && _currentPlayingFilePath == filePath) {
      // Stop playing
      await _player.stopPlayer();
      setState(() {
        _isPlaying = false;
        _currentPlayingFilePath = '';
      });
    } else {
      // Start playing
      await _player.startPlayer(
        fromURI: filePath,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _currentPlayingFilePath = '';
          });
        },
      );
      setState(() {
        _isPlaying = true;
        _currentPlayingFilePath = filePath;
      });
    }
  }

  void _deleteVoiceNote() {
    setState(() {
      selectedAudioFile = null;
    });
  }

  Future<void> selectImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      setState(() {
        selectedImages = images.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<void> selectImagesFromGallery() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages != null) {
      for (var pickedImage in pickedImages) {
        File imageFile = File(pickedImage.path);
        await chatService.sendMessage(
          receiverId: widget.receiverId,
          images: [imageFile],
        );

        setState(() {
          messages.add({
            'text': null,
            'senderId': widget.senderId,
            'imageUrls': [imageFile.path],
            'audioUrl': null,
          });
        });
      }
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isSentByMe) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors for sender (right) and receiver (left)
    Color senderBubbleColor =
        isDarkMode ? Color(0xFF7A0D7D) : Color(0xFF500450);
    Color receiverBubbleColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

    Color senderTextColor = Colors.white;
    Color receiverTextColor = isDarkMode ? Colors.white : Colors.black87;

    // Ensure isSent is not null and provide a default value (false if null)
    // bool isSent = message['isSent'] ?? false;

    // Define the sent status icon
    // Icon sentStatusIcon = isSent
    //     ? Icon(Icons.check_circle, color: Colors.green, size: 16)
    //     : Icon(Icons.hourglass_empty, color: Colors.orange, size: 16);

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        decoration: BoxDecoration(
          color: isSentByMe ? senderBubbleColor : receiverBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: isSentByMe ? Radius.circular(15) : Radius.zero,
            bottomRight: isSentByMe ? Radius.zero : Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audio message handling
            if (message['audioUrl'] != null)
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying &&
                              _currentPlayingFilePath ==
                                  '${message['audioUrl']}/download'
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () =>
                        _togglePlayPause('${message['audioUrl']}/download'),
                  ),
                  const Text(
                    'Voice Note',
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),

            // Image message handling (can be multiple images)
            if (message['imageUrls'] != null && message['imageUrls'].isNotEmpty)
              Column(
                children: message['imageUrls'].map<Widget>((imageUrl) {
                  return imageUrl.startsWith('http')
                      ? Image.network(
                          '$imageUrl/download',
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(imageUrl),
                          fit: BoxFit.cover,
                        );
                }).toList(),
              ),

            // Text message handling
            if (message['text'] != null && message['text'].isNotEmpty)
              Text(
                message['text'],
                style: TextStyle(
                  color: isSentByMe ? senderTextColor : receiverTextColor,
                  fontSize: 16,
                ),
              ),

            // Uncomment if you want to show the sent status icon
            // SizedBox(height: 8),
            // sentStatusIcon,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false, // Change this to false for top-to-bottom display
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isLastMessage = index == messages.length - 1;

                if (isLastMessage) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // Check if the "audioUrl" is not null and not empty
                    if (message["audioUrl"] != null &&
                        message["audioUrl"]!.isNotEmpty) {
                      final newChat = Chat(
                        id: widget.receiverId.toString(),
                        username: widget.receiverName,
                        chatPreviewText: "Sent An Audio",
                        imageUrl: widget.profilePic,
                        timeStamp:
                            DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      );
                      Provider.of<ChatProvider>(context, listen: false)
                          .addOrUpdateChat(newChat);
                    }

                    // Check if the "imageUrls" is not null and not empty
                    if (message["imageUrls"] != null &&
                        message["imageUrls"]!.isNotEmpty) {
                      final newChat = Chat(
                        id: widget.receiverId.toString(),
                        username: widget.receiverName,
                        chatPreviewText: "Sent An Image",
                        imageUrl: widget.profilePic,
                        timeStamp:
                            DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      );
                      Provider.of<ChatProvider>(context, listen: false)
                          .addOrUpdateChat(newChat);
                    }

                    // Check if the "text" is not null and not empty
                    if (message["text"] != null &&
                        message["text"]!.isNotEmpty) {
                      final newChat = Chat(
                        id: widget.receiverId.toString(),
                        username: widget.receiverName,
                        chatPreviewText: message['text']!,
                        imageUrl: widget.profilePic,
                        timeStamp:
                            DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      );

                      Provider.of<ChatProvider>(context, listen: false)
                          .addOrUpdateChat(newChat);
                    }
                  });
                }
                final isSentByMe = message['senderId'] == widget.senderId;
                return _buildMessageBubble(message, isSentByMe);
              },
            ),
          ),
          _buildTextField(), // Show input field or audio UI
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(IconData icon, Function() onTap) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode ? Color(0xFF7A0D7D) : Color(0xFF500450),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildTextField() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        if (_isRecording)
          InkWell(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: const Icon(
              Icons.mic,
            ),
          )
        else
          InkWell(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: const Icon(
              Icons.stop,
            ),
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.image,
              color: isDarkMode ? Color(0xFF7A0D7D) : Color(0xFF500450)),
          onPressed: selectImagesFromGallery, // Implement this method
        ),
        Expanded(
          child: selectedAudioFile == null
              ? TextField(
                  controller: _messageController,
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
                        _isPlaying &&
                                _currentPlayingFilePath == selectedAudioFile
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () => _togglePlayPause(selectedAudioFile!),
                    ),
                    const Text(
                      'Voice Note',
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _deleteVoiceNote,
                    ),
                  ],
                ),
        ),
        const SizedBox(width: 8),
        _buildAnimatedButton(Icons.send, () {
          sendMessage(); // Implement send message functionality
        }),
      ],
    );
  }
}
