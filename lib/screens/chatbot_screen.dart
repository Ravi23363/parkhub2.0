import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parkhub/screens/home_page_screen.dart';
import 'package:parkhub/screens/profile_screen.dart';
import 'package:parkhub/screens/booking_screen.dart';
import 'package:parkhub/screens/chatbot_messaging_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInputText = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _voiceInputText = val.recognizedWords;
            });

            if (val.hasConfidenceRating && val.confidence > 0) {
              // Do something with _voiceInputText like sending it to chatbot
              debugPrint("Recognized: $_voiceInputText");
              _speech.stop();
              setState(() => _isListening = false);
              // You can navigate or show result
            }
          },
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: colorScheme.onSurface,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          String message = '';
                          if (value == 'chat') message = 'Chat History clicked';
                          if (value == 'settings') message = 'Settings clicked';
                          if (value == 'report') message = 'Report clicked';

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        },
                        itemBuilder:
                            (BuildContext context) => [
                              const PopupMenuItem(
                                value: 'chat',
                                child: ListTile(
                                  leading: Icon(Icons.history),
                                  title: Text('Chat History'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'settings',
                                child: ListTile(
                                  leading: Icon(Icons.settings),
                                  title: Text('Settings'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'report',
                                child: ListTile(
                                  leading: Icon(Icons.report_problem),
                                  title: Text('Report an Issue'),
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                  const Text(
                    'ParkHub Smart Assistant',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Animated ChatBot Image
            Hero(
              tag: 'chatbot-hero',
              child: Image.asset('assets/images/chatbot1.png', height: 180),
            ),

            const SizedBox(height: 30),

            // Prompt Text
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'I’m your smart assistant from ParkHub.\n\n',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Ask me anything about parking spots, bookings, or directions to your destination!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 139, 139, 139),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Suggestion Chips
            // Suggestions Headline
            // Suggestions Headline
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10),
              child: Text(
                "Need help with something?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // Suggestion Chips with bounce animation
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                // Common actions
                _buildAnimatedChip("Nearby Parking", Icons.local_parking),
                _buildAnimatedChip("My Bookings", Icons.bookmark_border),
                _buildAnimatedChip("Get Directions", Icons.directions),

                // Help & support
                _buildAnimatedChip("Report Misuse", Icons.report_gmailerrorred),
                _buildAnimatedChip("Payment Problem", Icons.payment),
                _buildAnimatedChip("Technical Issue", Icons.bug_report),

                // General inquiries
                _buildAnimatedChip("How to Use ParkHub?", Icons.help_outline),
              ],
            ),

            const SizedBox(height: 30),

            // Beautiful glass-like draggable bottom control handle
            GestureDetector(
              onTap: () => _showControlsSheet(context, colorScheme),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 120,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.6),
                      Colors.white.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.expand_less,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomepageScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BookingScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
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

  Widget _buildAnimatedChip(String label, IconData icon) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        HapticFeedback.lightImpact();
        // You can show a snackbar or trigger a real query here
      },
      child: Chip(
        avatar: Icon(icon, size: 18, color: Colors.black54),
        label: Text(label),
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        backgroundColor: Colors.grey.shade200,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showControlsSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatBotConversationScreen(),
                    ),
                  );
                },
                child: Icon(
                  Icons.keyboard,
                  color: colorScheme.onSurface,
                  size: 30,
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.outlineVariant,
                child: IconButton(
                  icon: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: colorScheme.onPrimary,
                    size: 28,
                  ),
                  onPressed: _listen,
                ),
              ),
              Icon(Icons.more_horiz, color: colorScheme.onSurface, size: 30),
            ],
          ),
        );
      },
    );
  }
}
