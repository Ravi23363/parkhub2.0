import 'package:flutter/material.dart';
import 'package:parkhub/screens/reservation_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationtimeScreen extends StatefulWidget {
  const ReservationtimeScreen({super.key});

  @override
  State<ReservationtimeScreen> createState() => _ReservationtimeScreenState();
}

class _ReservationtimeScreenState extends State<ReservationtimeScreen> {
  DateTime selectedDate = DateTime.now();
  double duration = 4;
  TimeOfDay startTime = TimeOfDay.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final double firstHourPrice = 3.00;
  final double subsequentHourPrice = 2.00;
  final double reservationFee = 5.00;

  double calculateTotalPrice() {
    if (duration <= 1) {
      return firstHourPrice + reservationFee;
    } else {
      return firstHourPrice +
          ((duration - 1) * subsequentHourPrice) +
          reservationFee;
    }
  }

  @override
  Widget build(BuildContext context) {
    TimeOfDay endTime = TimeOfDay(
      hour: (startTime.hour + duration.toInt()) % 24,
      minute: startTime.minute,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Text("Reservation Detail"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TableCalendar(
                focusedDay: selectedDate,
                firstDay: DateTime.now(),
                lastDay: DateTime(2100),
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                selectedDayPredicate: (day) {
                  return isSameDay(selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Duration",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                  ),
                  valueIndicatorTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Slider(
                  value: duration,
                  min: 1,
                  max: 12,
                  divisions: 11,
                  label: "${duration.toInt()} Hours",
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      duration = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimePicker("Start Hour", startTime, (newTime) {
                    setState(() {
                      startTime = newTime;
                    });
                  }),
                  _buildTimePicker("End Hour", endTime, null),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Price",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "RM 3.00 (1st hour)",
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Subsequent Hour Price",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "RM 2.00 per hour",
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Reservation Fee",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "RM ${reservationFee.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Price",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "RM ${calculateTotalPrice().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedDate.isBefore(DateTime.now())) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Invalid Date"),
                            content: const Text(
                              "Please select a future date for reservation.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final upfrontPayment = reservationFee;
                          return AlertDialog(
                            title: const Text("Payment Required"),
                            content: Text(
                              "You need to pay RM ${upfrontPayment.toStringAsFixed(2)} upfront for the reservation fee. Remaining parking fees can be settled during the exit.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReservationScreen(),
                                    ),
                                  );
                                },
                                child: const Text("Proceed"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Reserve",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    Function(TimeOfDay)? onTimeSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap:
              onTimeSelected != null ? () => _pickTime(onTimeSelected) : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            width: 140,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.access_time, color: Colors.blue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime(Function(TimeOfDay) onTimeSelected) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }
}
