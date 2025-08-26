import 'package:care_track/welcome_screen.dart';
import 'package:care_track/home_user.dart';
import 'package:care_track/home_dr.dart';
import 'package:care_track/User_login.dart';
import 'package:care_track/doctor_login.dart';
import 'package:care_track/our_doctors.dart';
import 'package:care_track/profile.dart';
import 'package:care_track/user_appo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'providers/app_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider()..initializeAuth(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/welcome': (context) => const WelcomeScreen(),
              '/login/user': (context) => const UserLogin(),
              '/login/doctor': (context) => const DoctorLogin(),
              '/home': (context) => _getHomeScreen(appProvider),
              '/doctors': (context) => OurDoctors(),
              '/profile': (context) => const Profile(),
              '/appointments': (context) => UserAppo(),
            },
          );
        },
      ),
    );
  }

  Widget _getHomeScreen(AppProvider appProvider) {
    if (appProvider.userType == 'patient') {
      return const HomeUser(); // The actual home page from home_user.dart
    } else if (appProvider.userType == 'doctor') {
      return HomeDr();
    } else {
      return const WelcomeScreen();
    }
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.initializeAuth();
    
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        if (appProvider.isLoggedIn) {
          // Navigate to appropriate home screen based on user type
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      body: Container(
        width: isSmallScreen ? screenWidth : 400,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromARGB(69, 154, 182, 230),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/ntg.png', width: 200),
              const SizedBox(height: 60),
              Image.asset('assets/images/heart.png', width: 150),
              const Text(
                'CareTrack',
                style: TextStyle(
                  color: Color(0xFF223A6A),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
