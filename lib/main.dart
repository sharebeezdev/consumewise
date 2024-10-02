import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home/splash_screen.dart';

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
        useMaterial3: true,
        colorSchemeSeed: Colors.lightGreen.shade600,
        brightness: Brightness.light,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
