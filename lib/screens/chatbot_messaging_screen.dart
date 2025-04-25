import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dialog_flowtter_plus/dialog_flowtter_plus.dart';
import 'package:parkhub/screens/home_page_screen.dart';
import 'package:parkhub/screens/profile_screen.dart';
import 'package:parkhub/screens/booking_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatBotConversationScreen extends StatefulWidget {
  const ChatBotConversationScreen({super.key});

  @override
  State<ChatBotConversationScreen> createState() =>
      _ChatBotConversationScreen();
}

class _ChatBotConversationScreen extends State<ChatBotConversationScreen> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];

  Future<void> pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageMessage = Message(payload: {'image': pickedFile.path});

      addMessage(imageMessage, true);
    }
  }

  @override
  void initState() {
    DialogFlowtter.fromFile().then(
      (instance) => setState(() {
        dialogFlowtter = instance;
      }),
    );
    super.initState();
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;
    addMessage(Message(text: DialogText(text: [text])), true);

    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );

    if (response.message != null) {
      addMessage(response.message!);
    }
  }

  void addMessage(Message message, [bool isUserMessage = false]) {
    final newMessage = {
      'message': message,
      'isUserMessage': isUserMessage,
      'timestamp': DateTime.now(),
    };
    messages.add(newMessage);
    _listKey.currentState?.insertItem(messages.length - 1);
  }

  Widget buildMessage(
    Map<String, dynamic> messageData,
    Animation<double> animation,
  ) {
    final message = messageData['message'] as Message;
    final isUser = messageData['isUserMessage'] as bool;
    final timestamp = messageData['timestamp'] as DateTime;
    final bgColor = isUser ? Colors.white : Colors.black;
    final textColor = isUser ? Colors.black : Colors.white;
    final imagePath = message.payload?['image'];
    final bool isLocalImage =
        imagePath != null && !imagePath.toString().startsWith('http');

    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 20 : 0),
                  topRight: Radius.circular(isUser ? 0 : 20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
              ),
              child: Text(
                message.text?.text?.first ?? '',
                style: TextStyle(color: textColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                DateFormat('hh:mm a').format(timestamp),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
            if (imagePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      isLocalImage
                          ? Image.file(File(imagePath))
                          : Image.network(imagePath),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Hero
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Hero(
                    tag: 'chat-title',
                    child: Text(
                      'ParkHub Smart Assistant',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder:
                        (BuildContext context) => [
                          PopupMenuItem(
                            value: 'chat',
                            child: Row(
                              children: const [
                                Icon(Icons.history, color: Colors.black54),
                                SizedBox(width: 8),
                                Text('Chat History'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'settings',
                            child: Row(
                              children: const [
                                Icon(Icons.settings, color: Colors.black54),
                                SizedBox(width: 8),
                                Text('Settings'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'report',
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.report_problem,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 8),
                                Text('Report an Issue'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: AnimatedList(
                key: _listKey,
                controller: _scrollController,
                initialItemCount: messages.length,
                itemBuilder: (context, index, animation) {
                  return buildMessage(messages[index], animation);
                },
              ),
            ),

            // Input Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.blue),
                    onPressed: pickAndSendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      sendMessage(_controller.text);
                      _controller.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (index) {
          Widget page;
          switch (index) {
            case 0:
              page = const HomepageScreen();
              break;
            case 1:
              page = const BookingScreen();
              break;
            case 3:
              page = const ProfileScreen();
              break;
            default:
              return;
          }
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => page,
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },


        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Nearby",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Booking"),
          BottomNavigationBarItem(icon: Icon(Icons.android), label: "ChatBot"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
