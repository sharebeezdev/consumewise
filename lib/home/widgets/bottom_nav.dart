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
  bool _shouldRefreshProducts = false; // Track whether to refresh products

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // This will trigger when we need to refresh HomeScreen products
  void _refreshHomeProducts() {
    if (_shouldRefreshProducts) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _shouldRefreshProducts = false; // Reset the flag after refresh
        });
      });
    }
  }

  Future<void> _navigateToScanScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanScreen(
          onBackToHome: () {
            // When coming back from ScanScreen, set the index to HomeScreen
            setState(() {
              _shouldRefreshProducts = true; // Trigger refresh on return
              _selectedIndex = 0; // Switch back to HomeScreen
            });
          },
        ),
      ),
    );

    if (result == true) {
      // If scan operation succeeded, trigger refresh of HomeScreen
      setState(() {
        _shouldRefreshProducts = true;
        _selectedIndex = 0; // Ensure HomeScreen is active
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = <Widget>[
      HomeScreen(onRefreshProducts: _refreshHomeProducts),
      ScanScreen(onBackToHome: () {
        setState(() {
          _shouldRefreshProducts = true; // Set flag to refresh on return
          _selectedIndex = 0; // Switch to HomeScreen
        });
      }),
      ProfileSetupFlow(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _selectedIndex == 1
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(null), // Placeholder for the middle scan button
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _selectedIndex == 1
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1; // Navigate to ScanScreen
                });
              },
              child: Icon(Icons.qr_code_scanner, size: 36),
            ),
    );
  }
}
