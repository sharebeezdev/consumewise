import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home/widgets/bottom_nav.dart';

void main() {
  runApp(ConsumeWiseApp());
}

class ConsumeWiseApp extends StatelessWidget {
  const ConsumeWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConsumeWise',
      theme: ThemeData(
        primarySwatch: Colors.blue,  // Primary color
        brightness: Brightness.light, // Light theme
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18.0, color: Colors.black),
          headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.blue, // Elevated button color
          ),
        ),
      ),
      home: BottomNav(),
      debugShowCheckedModeBanner: false,
    );
  }
}
