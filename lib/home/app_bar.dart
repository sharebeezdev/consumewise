import 'package:flutter/material.dart';

class ConsumeWiseAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.greenAccent.shade400,
              Colors.lightGreen.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco, // Icon to match the app's eco-friendly theme
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 8),
          Text(
            'ConsumeWise',
            style: TextStyle(
              fontFamily: 'Montserrat', // Custom font for a modern feel
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.search, color: Colors.white),
      //     onPressed: () {
      //       // Add search functionality
      //     },
      //   ),
      //   IconButton(
      //     icon: Icon(Icons.notifications, color: Colors.white),
      //     onPressed: () {
      //       // Add notifications functionality
      //     },
      //   ),
      // ],
    );
  }
}
