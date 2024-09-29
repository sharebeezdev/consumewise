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
        useMaterial3: true, // Enable Material You (Material 3)
        colorSchemeSeed: Colors.blue, // Use a seed color for dynamic theming
        brightness:
            Brightness.light, // You can also support dark mode dynamically
        textTheme: GoogleFonts
            .interTextTheme(), // Optional: Set custom fonts using Google Fonts
      ),
      home: BottomNav(),
      debugShowCheckedModeBanner: false,
    );
  }
}
