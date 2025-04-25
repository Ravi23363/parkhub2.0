import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parkhub/screens/home_page_screen.dart';
import 'package:parkhub/screens/welcome_screen.dart';
import 'package:parkhub/theme/theme.dart';
import 'package:parkhub/services/geolocator_service.dart';
import 'package:parkhub/services/places_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ParkHubApp());
}

class ParkHubApp extends StatelessWidget {
  const ParkHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final geoLocatorService = GeolocatorService();
    final placesService = PlacesService();

    return MultiProvider(
      providers: [
        FutureProvider<Position?>(
          create: (context) async {
            try {
              return await geoLocatorService.determinePosition();
            } catch (e) {
              debugPrint('Location error: $e');
              return null;
            }
          },
          initialData: null,
        ),
        ProxyProvider<Position?, Future<List<Place>>?>(
          update: (context, position, previous) {
            if (position != null) {
              return placesService.getPlaces(
                position.latitude,
                position.longitude,
              );
            }
            return null;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ParkHub',
        theme: lightMode,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const HomepageScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
