import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add SharedPreferences
import '../datamodel/utils/database_helper.dart';
import 'profile_screen.dart';
import 'widgets/bottom_nav.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfileSetup();
  }

  // Method to check if the profile is set up
  Future<void> _checkProfileSetup() async {
    final profile = await DatabaseHelper.fetchProfile();

    // Delay for 1-2 seconds for splash effect (optional)
    await Future.delayed(Duration(seconds: 2));

    if (profile != null) {
      // If profile exists, navigate to the main app (BottomNav)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNav()),
      );
    } else {
      // If no profile, set flag and navigate to profile setup page
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isProfileSetupFlow', true); // Set the flag

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileSetupFlow()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show loading indicator
      ),
    );
  }
}
