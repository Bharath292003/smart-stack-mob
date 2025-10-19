import 'package:flutter/material.dart';
import '../camera_scanner.dart';
import '../profile_screen.dart';
import '../home_page.dart';
import '../user_session.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap ?? (index) => _defaultOnTap(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF0F172A),
      unselectedItemColor: const Color(0xFF94A3B8),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: 'Scanner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _defaultOnTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Navigate to Home - Get userName from UserSession
        _navigateToHome(context);
        break;
      case 1:
        // Navigate to Scanner
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraScannerPage()),
        );
        break;
      case 2:
        // Navigate to Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  void _navigateToHome(BuildContext context) async {
    final userName = await UserSession.getUserName();
    final phoneNumber = await UserSession.getUserPhone();
    
    if (userName != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: userName,
            phoneNumber: phoneNumber,
          ),
        ),
        (route) => false,
      );
    }
  }
}