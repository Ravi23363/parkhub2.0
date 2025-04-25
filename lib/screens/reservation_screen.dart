import 'package:flutter/material.dart';
import 'package:parkhub/screens/selectvehicle_screen.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  String selectedSlot = "A-13";
  String selectedFloor = "1st Floor";
  String selectedZone = "A";

  final List<String> floors = [
    "1st Floor",
    "2nd Floor",
    "3rd Floor",
    "4th Floor",
  ];

  final Map<String, List<String>> zonesByFloor = {
    "1st Floor": ["A", "B", "VIP"],
    "2nd Floor": ["C", "D", "VIP"],
    "3rd Floor": ["E", "F", "VIP"],
    "4th Floor": ["G", "VIP"],
  };

  final Map<String, List<String>> bookedSlotsByZone = {
    "1st Floor-A": ["A-11", "A-12", "A-14", "A-15", "A-16"],
    "1st Floor-B": ["B-11", "B-12", "B-13", "B-14", "B-15"],
    "1st Floor-VIP": ["V-11", "V-12", "V-13"],
    "2nd Floor-C": ["C-11", "C-13", "C-14"],
    "2nd Floor-D": ["D-12", "D-14", "D-15"],
    "2nd Floor-VIP": ["V-21", "V-22", "V-23"],
    "3rd Floor-E": ["E-13", "E-14", "E-15"],
    "3rd Floor-F": ["F-11", "F-12", "F-13"],
    "3rd Floor-VIP": ["V-31", "V-32", "V-33"],
    "4th Floor-G": ["G-11", "G-14", "G-15"],
    "4th Floor-VIP": ["V-41", "V-42", "V-43"],
  };

  List<List<String>> getSlotRows(String zone) {
    return List.generate(
      3,
      (i) => List.generate(4, (j) => "$zone-${11 + i * 4 + j}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentZones = zonesByFloor[selectedFloor] ?? [];
    final bookedSlots = bookedSlotsByZone["$selectedFloor-$selectedZone"] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Parking Spot"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Floor",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _buildFloorDropdown(),
            const SizedBox(height: 16),
            const Text(
              "Select Zone",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _buildZoneTabs(currentZones),
            const SizedBox(height: 20),
            const Center(
              child: Text("ENTRANCE", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 6),
            ...getSlotRows(selectedZone).asMap().entries.expand((entry) {
              final index = entry.key;
              final row = entry.value;

              return [
                _buildSlotRow(row, bookedSlots),
                if (index < 2) ...[
                  const SizedBox(height: 6),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: Image.asset(
                        'assets/images/road.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ];
            }),

            const Center(
              child: Text("EXIT", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 12),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectVehicleScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Pick Parking Spot ($selectedSlot)",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: selectedFloor,
        isExpanded: true,
        underline: const SizedBox(),
        items:
            floors.map((floor) {
              return DropdownMenuItem<String>(value: floor, child: Text(floor));
            }).toList(),
        onChanged: (value) {
          setState(() {
            selectedFloor = value!;
            selectedZone = zonesByFloor[selectedFloor]!.first;
          });
        },
      ),
    );
  }

  Widget _buildZoneTabs(List<String> zones) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            zones.map((zone) {
              final isSelected = zone == selectedZone;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => setState(() => selectedZone = zone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Colors.blue.shade100,
                                  blurRadius: 4,
                                ),
                              ]
                              : [],
                    ),
                    child: Text(
                      zone,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSlotRow(List<String> row, List<String> bookedSlots) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: row.map((slot) => _buildSlot(slot, bookedSlots)).toList(),
      ),
    );
  }

  Widget _buildSlot(String slot, List<String> bookedSlots) {
    final isBooked = bookedSlots.contains(slot);
    final isSelected = slot == selectedSlot;
    final isVIP = selectedZone == "VIP";

    return GestureDetector(
      onTap: isBooked ? null : () => setState(() => selectedSlot = slot),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color:
                  isBooked
                      ? Colors.grey.shade300
                      : (isVIP ? Colors.amber.shade100 : Colors.white),
              border: Border.all(
                color:
                    isSelected
                        ? Colors.blue
                        : (isVIP ? Colors.amber : Colors.grey.shade400),
                width: isSelected ? 2.5 : 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                isBooked
                    ? Image.asset(
                      'assets/images/car_top_view.png',
                      fit: BoxFit.contain,
                    )
                    : Center(
                      child: Text(
                        isVIP ? "VIP" : "Available",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isVIP
                                  ? Colors.amber.shade800
                                  : Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          ),
          const SizedBox(height: 4),
          Text(slot, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
