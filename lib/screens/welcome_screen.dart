import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parkhub/screens/signin_screen.dart';
import 'package:parkhub/screens/signup_screen.dart';
import 'package:parkhub/widgets/custom_scaffold.dart';
import 'package:parkhub/widgets/welcome_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, String>> slides = [
    {
      'image': 'assets/images/parkingreservation.png',
      'header': 'Parking Reservation',
      'description':
          'Reserve your parking space and enjoy a stress-free arrival!',
    },
    {
      'image': 'assets/images/Arnavigation.png',
      'header': 'AR Navigation',
      'description': 'Navigate parking areas with real-time AR guidance!',
    },
    {
      'image': 'assets/images/cashlesspayment.png',
      'header': 'Seamless & Secure Transactions',
      'description': 'Pay seamlessly with cashless system—secure!',
    },
    {
      'image': 'assets/images/Allinoneapp.png',
      'header': 'All-in-One Parking App',
      'description': 'Everything you need in one powerful app!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentPage < slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // PageView for slides
            SizedBox(
              height:
                  450, // Increased the height to accommodate larger images and spacing
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        slide['image']!,
                        height: 250, // Enlarged images
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 30), // Added more spacing
                      Text(
                        slide['header']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (slide['description']!.isNotEmpty)
                        Text(
                          slide['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color.fromARGB(255, 74, 73, 73),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 15), // Added spacing between text and slider
            // Pagination dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  height: 10.0,
                  width: _currentPage == index ? 20.0 : 10.0,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? Colors.blue
                            // ignore: deprecated_member_use
                            : Colors.blue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),

            // Welcome text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome to ParkHub!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  WelcomeButton(
                    buttonText: 'Create Account',
                    onTap: const SignUpScreen(),
                    color: const Color.fromARGB(255, 65, 111, 223),
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 15),
                  WelcomeButton(
                    buttonText: 'Login',
                    onTap: SignInScreen(),
                    color: Colors.white,
                    textColor: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
