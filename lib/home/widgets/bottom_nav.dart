import 'package:flutter/material.dart';

import '../home_screen.dart';
import '../profile_screen.dart';
import '../scan_screen.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _screens = <Widget>[
    HomeScreen(),
    ScanScreen(),
    ProfileSetupFlow(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white, // Color for selected item (icon and label)
        unselectedItemColor: Colors.white, // Color for unselected item (icon and label)
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(null), // Placeholder for the middle scan button
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(top: 8.0), // Add padding to prevent overflow
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16)), // Adds Material You flair
          child: Icon(Icons.qr_code_scanner, size: 36, color: Colors.white,), // Larger scan button
          onPressed: () {
            setState(() {
              _selectedIndex = 1; // Set to Scan Screen
            });
          },
        ),
      ),
    );
  }
}
