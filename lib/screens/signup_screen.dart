import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:parkhub/screens/signin_screen.dart';
import 'package:parkhub/theme/theme.dart';
import 'package:parkhub/widgets/custom_scaffold.dart';
import 'package:parkhub/screens/verification_screen.dart';
import 'package:parkhub/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool agreePersonalData = true;
  bool _obscurePassword = true;

  final Auth _auth = Auth();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formSignupKey.currentState!.validate() && agreePersonalData) {
      try {
        await _auth.createUserWithEmailandPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseAuth.instance.currentUser?.updateDisplayName(
          _nameController.text.trim(),
        );

        await FirebaseAuth.instance.currentUser?.sendEmailVerification();

        // Ensure widget is still in tree
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => VerificationScreen(
                  email: _emailController.text.trim(),
                  name: _nameController.text.trim(),
                ),
          ),
        );
      } catch (e) {
        debugPrint("Signup error: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
      }
    } else if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the processing of personal data'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: Form(
              key: _formSignupKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w900,
                      color: lightColorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Full name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: const Text('Full Name'),
                      hintText: 'Enter Full Name',
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an Email';
                      }
                      String pattern =
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value)) {
                        return 'Please enter a valid Email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: const Text('Email'),
                      hintText: 'Enter Email',
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    obscuringCharacter: '*',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: const Text('Password'),
                      hintText: 'Enter Password',
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Row(
                    children: [
                      Checkbox(
                        value: agreePersonalData,
                        onChanged: (bool? value) {
                          setState(() {
                            agreePersonalData = value!;
                          });
                        },
                        activeColor: lightColorScheme.primary,
                      ),
                      const Text(
                        'I agree to the processing of ',
                        style: TextStyle(color: Colors.black45),
                      ),
                      Text(
                        'Personal data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: lightColorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      child: const Text('Sign up'),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.7,
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Sign up with',
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.7,
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Brand(Brands.facebook_f),
                      Brand(Brands.twitter),
                      Brand(Brands.google),
                      Brand(Brands.apple_logo),
                    ],
                  ),
                  const SizedBox(height: 25.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.black45),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (e) => const SignInScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: lightColorScheme.primary,
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
      ),
    );
  }
}
