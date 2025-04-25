import 'package:flutter/material.dart';
import 'package:parkhub/screens/reservationtime_screen.dart';

class ViewDetailScreen extends StatelessWidget {
  const ViewDetailScreen({super.key});

  Widget _buildFeature(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLabeledText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/images/ioiparkingP1.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(Icons.bookmark_border, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and More Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "IOI City Mall Parking",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "More images",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Lebuh IRC, IOI Resort City, 62502 Putrajaya, Sepang, Selangor",
                        style: TextStyle(color: Colors.black54),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "RM3 (1st hour)",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 20),
                          Icon(Icons.directions_car, color: Colors.blue),
                          SizedBox(width: 5),
                          Text("24 Slots"),
                          Spacer(),
                          Icon(Icons.star, color: Colors.amber),
                          Text("4.5"),
                        ],
                      ),

                      const Divider(height: 30),

                      // About Sectio
                      const SizedBox(height: 4),

                      // Features
                      Text(
                        "Features",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeature(Icons.accessible, "Disabled"),
                          _buildFeature(Icons.height, "Height: 2.1m"),
                          _buildFeature(Icons.electric_car, "EV Charge"),
                          _buildFeature(Icons.local_parking, "Covered"),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Prices
                      Text(
                        "Prices",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildLabeledText(
                        "Mon–Fri",
                        "1st Hour: MYR2.00, Additional: MYR1.00/hr",
                      ),
                      _buildLabeledText(
                        "Sat–Sun",
                        "1st Hour: MYR4.00, Additional: MYR1.00/hr",
                      ),

                      const SizedBox(height: 20),

                      // Payment
                      Text(
                        "Payment Options",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Pay On Foot, Credit/Debit Cards, E-Wallets (Touch ‘n Go, Boost), Cash",
                        style: TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 20),

                      // Premier Parking
                      Text(
                        "Premier Parking",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildLabeledText(
                        "Weekdays",
                        "RM15.00 / 3 hrs, RM2.00 each subsequent hr",
                      ),
                      _buildLabeledText(
                        "Weekends & Holidays",
                        "RM20.00 / 3 hrs, RM2.00 each subsequent hr",
                      ),

                      SizedBox(height: 100), // Space for bottom buttons
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
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReservationtimeScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.event_available),
                        label: Text("Reserve"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ), // Or any color you like
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Add navigation to map
                        },
                        icon: Icon(Icons.directions, size: 20),
                        label: Text("Directions"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}
