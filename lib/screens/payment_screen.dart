import 'package:flutter/material.dart';
import 'package:parkhub/screens/reservationconfirmation_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double upfrontPayment;

  const PaymentMethodScreen({super.key, required this.upfrontPayment});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? selectedMethod;

  final List<Map<String, dynamic>> paymentMethods = [
    {'name': 'Credit Card', 'icon': Icons.credit_card, 'id': 'credit_card'},
    {
      'name': 'Online Banking',
      'icon': Icons.account_balance,
      'id': 'online_banking',
    },
    {
      'name': "Touch 'n Go Ewallet",
      'icon': Icons.phone_android,
      'id': 'touch_n_go',
    },
    {'name': 'Ewallet', 'icon': Icons.wallet, 'id': 'ewallet'},
  ];

  // Show an alert if no payment method is selected
  void _showNoPaymentMethodAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("No Payment Method Selected"),
          content: const Text(
            "Please select a payment method before continuing.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Text("Payment Method"),
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
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMethod = method['id'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              selectedMethod == method['id']
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Payment method icon
                          Icon(method['icon'], size: 40, color: Colors.blue),
                          const SizedBox(width: 12),
                          // Payment method name
                          Text(
                            method['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // Selection indicator
                          Icon(
                            selectedMethod == method['id']
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color:
                                selectedMethod == method['id']
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Total Payment Display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Reservation Payment:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "RM ${widget.upfrontPayment.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Space for the button
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedMethod == null) {
                    _showNoPaymentMethodAlert();
                  } else {
                    // Navigate to the next screen or perform an action
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingConfirmationScreen(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
