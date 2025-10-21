import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'user_session.dart';

void main() {
  runApp(const SmartStackApp());
}

class SmartStackApp extends StatelessWidget {
  const SmartStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart-Stack',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: const Color(0xFF6C63FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF5A52E8),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
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
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash screen delay
    
    // Use UserSession for consistent session management
    final isLoggedIn = await UserSession.isLoggedIn();
    final userName = await UserSession.getUserName() ?? '';
    final phoneNumber = await UserSession.getUserPhone() ?? '';

    if (mounted) {
      if (isLoggedIn && userName.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userName: userName,
              phoneNumber: phoneNumber,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed to white background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo using SVG
            SvgPicture.asset(
              'assets/logo.svg',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 32),
            // App Name
            const Text(
              'Smart-Stack',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w300,
                color: Color(0xFF0F172A), // Changed to dark color for white background
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 12),
            // Slogan
            const Text(
              'Your Digital Business Card Manager',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B), // Adjusted for white background
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect • Share • Grow',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Color(0xFF94A3B8), // Adjusted for white background
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 60),
            // Loading indicator
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)), // Changed to dark color
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
