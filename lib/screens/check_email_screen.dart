import 'package:flutter/material.dart';
import 'package:parkhub/widgets/custom_scaffold.dart';
import '../theme/theme.dart';
import 'package:parkhub/screens/set_newpassword_screen.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email; // Pass email from previous screen

  const CheckEmailScreen({super.key, required this.email});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isResendDisabled = false; // To prevent multiple resends

  void _resendEmail() {
    setState(() {
      _isResendDisabled = true;
    });

    // Simulate email resend delay
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        _isResendDisabled = false;
      });
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Resend email request sent')));
  }

  void _verifyCode() {
    if (_codeController.text.length == 5) {
      // Handle code verification logic here
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Code Verified!')));

      // Navigate to the Set New Password Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetNewPasswordScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 5-digit code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Check Your Email',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: lightColorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Icon(
                      Icons.email_outlined,
                      size: 80.0,
                      color: lightColorScheme.primary,
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'We sent a reset link to ${widget.email}\n'
                      'Enter the 5-digit code mentioned in the email.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'Enter Code',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _verifyCode,
                        child: const Text('Verify Code'),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Haven’t got the email yet? ',
                          style: TextStyle(color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: _isResendDisabled ? null : _resendEmail,
                          child: Text(
                            _isResendDisabled
                                ? 'Resend in 10s'
                                : 'Resend email',
                            style: TextStyle(
                              color:
                                  _isResendDisabled
                                      ? Colors.grey
                                      : lightColorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
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
