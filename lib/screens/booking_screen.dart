import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:parkhub/screens/home_page_screen.dart';
import 'package:parkhub/screens/profile_screen.dart';
import 'package:parkhub/screens/chatbot_screen.dart';
import 'package:image_picker/image_picker.dart';

class BookingTimer extends StatefulWidget {
  final DateTime startTime;

  const BookingTimer({super.key, required this.startTime});

  @override
  // ignore: library_private_types_in_public_api
  _BookingTimerState createState() => _BookingTimerState();
}

class _BookingTimerState extends State<BookingTimer> {
  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    Color timerColor = Colors.green;
    if (_elapsed.inMinutes > 30) timerColor = Colors.orange;
    if (_elapsed.inMinutes > 60) timerColor = Colors.red;

    return Row(
      children: [
        const Icon(Icons.timer, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 6),
        Text(
          "${hours.toString().padLeft(2, '0')}h "
          "${minutes.toString().padLeft(2, '0')}m "
          "${seconds.toString().padLeft(2, '0')}s",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: timerColor,
          ),
        ),
      ],
    );
  }
}

class ParkingSpot {
  final String name;
  final String address;
  final String price;
  final String distance;
  final String slots;
  final double rating;
  final String image;
  final DateTime startTime;

  ParkingSpot({
    required this.name,
    required this.address,
    required this.price,
    required this.distance,
    required this.slots,
    required this.rating,
    required this.image,
    required this.startTime,
  });
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ParkingSpot> ongoingBookings = [];
  List<ParkingSpot> upcomingBookings = [];
  List<ParkingSpot> bookingHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add test data with future time for upcoming
    DateTime now = DateTime.now();
    ongoingBookings = [
      ParkingSpot(
        name: 'IOI City Mall Parking',
        address:
            'Lebuh IRC, IOI Resort City, 62502 Putrajaya, Sepang, Selangor',
        price: 'RM3 (1st hour)',
        distance: '1.2 km',
        slots: '45 slots',
        rating: 4.5,
        image: 'assets/images/ioiparkingP1.jpeg',
        startTime: now.subtract(const Duration(minutes: 30)),
      ),
    ];

    upcomingBookings = [
      ParkingSpot(
        name: 'Sunway Pyramid Parking',
        address:
            '3, Jalan PJS 11/15, Bandar Sunway, 47500 Subang Jaya, Selangor',
        price: 'RM3 (1st hour)',
        distance: '15.4 km',
        slots: '32 slots',
        rating: 4.3,
        image: 'assets/images/sunwayparking.png',
        startTime: now.add(const Duration(hours: 2)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("My Reservation"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: "Parking Reservations"),
            Tab(text: "Reservation history"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBookingList(), _buildBookingHistory()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomepageScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatBotScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
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

  Widget _buildBookingList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            "Ongoing Reservations",
            Icons.play_circle_fill,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          ongoingBookings.isEmpty
              ? _emptyState("No ongoing reservations", Colors.blue)
              : Column(
                children:
                    ongoingBookings
                        .asMap()
                        .entries
                        .map(
                          (entry) => _bookingCard(
                            entry.value,
                            entry.key,
                            Colors.blue.shade50,
                          ),
                        )
                        .toList(),
              ),

          const SizedBox(height: 36),

          _sectionHeader("Upcoming Reservations", Icons.upcoming, Colors.green),
          const SizedBox(height: 12),
          upcomingBookings.isEmpty
              ? _emptyState("No upcoming reservations", Colors.green)
              : Column(
                children:
                    upcomingBookings
                        .map(
                          (spot) => _upcomingCard(spot, Colors.green.shade50),
                        )
                        .toList(),
              ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Spacer(),
        // ignore: deprecated_member_use
        Container(height: 2, width: 100, color: color.withOpacity(0.3)),
      ],
    );
  }

  Widget _emptyState(String message, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _upcomingCard(dynamic spot, Color bgColor) {
    return Card(
      color: bgColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 28, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                spot.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingHistory() {
    return bookingHistory.isEmpty
        ? const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "No booking history",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: bookingHistory.length,
          itemBuilder: (context, index) {
            final spot = bookingHistory[index];
            return _historyCard(spot);
          },
        );
  }

  Widget _bookingCard(ParkingSpot spot, int index, Color shade50) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.asset(
                  spot.image,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      spot.address,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                () => _showCancelDialog(context, spot, index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Release Spot"),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showDirectionsDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(
                                33,
                                150,
                                243,
                                1,
                              ),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Directions"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BookingTimer(startTime: spot.startTime),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _showReportDialog(context, spot),
                        icon: const Icon(Icons.report, color: Colors.redAccent),
                        label: const Text(
                          "Report Issue",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showReportDialog(BuildContext context, ParkingSpot spot) {
    final TextEditingController reportController = TextEditingController();
    final ImagePicker picker = ImagePicker();
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Report Issue"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: reportController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText:
                            "Describe the issue with this parking spot...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    selectedImage == null
                        ? const Text("No image selected.")
                        : Image.file(File(selectedImage!.path), height: 150),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (image != null) {
                          setState(() {
                            selectedImage = image;
                          });
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Attach Photo"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Upload imageFile & reportText to database or backend

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Issue reported. Thank you!"),
                      ),
                    );
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _directionStep(String text, String iconPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(iconPath, width: 24, height: 24),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _historyCard(ParkingSpot spot) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                spot.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showDirectionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Directions to Your Parking Spot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _directionStep(
                "Enter through the main entrance gate",
                "assets/images/entrance.jpg",
              ),
              _directionStep(
                "Proceed to the payment kiosk",
                "assets/images/paymentsite.jpg",
              ),
              _directionStep(
                "Go straight for 150 meters",
                "assets/images/straight.jpg",
              ),
              _directionStep(
                "Turn right at the junction",
                "assets/images/turn right.jpg",
              ),
              _directionStep(
                "You have arrived at Zone A on your right",
                "assets/images/zoneA.jpg",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, ParkingSpot spot, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 50,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Release Spot?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to release the spot at",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 6),
                Text(
                  spot.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Once confirmed, your session will end and you'll be directed to the payment page.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text("Cancel"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Confirm"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            bookingHistory.add(ongoingBookings[index]);
                            ongoingBookings.removeAt(index);
                          });
                          Navigator.of(context).pop();
                          // Optionally navigate to payment page
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
