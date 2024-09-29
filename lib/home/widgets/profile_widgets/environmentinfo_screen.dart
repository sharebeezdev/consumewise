import 'package:flutter/material.dart';
import '../../../datamodel/utils/database_helper.dart';
import 'productinfo_screen.dart';

class EnvironmentInfoScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final VoidCallback onProfileComplete;

  EnvironmentInfoScreen(
      {required this.profileData, required this.onProfileComplete});

  @override
  _EnvironmentInfoScreenState createState() => _EnvironmentInfoScreenState();
}

class _EnvironmentInfoScreenState extends State<EnvironmentInfoScreen> {
  bool _environmentallyConscious = false;

  @override
  void initState() {
    super.initState();
    // Ensure the value is properly converted to a boolean
    _environmentallyConscious =
        widget.profileData['environmentallyConscious'] == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
          title: Text(
            'Environmental Preferences',
            style: TextStyle(color: Colors.white),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CheckboxListTile(
              title: Text('Are you environmentally conscious?'),
              value: _environmentallyConscious,
              onChanged: (value) {
                setState(() {
                  _environmentallyConscious = value ?? false;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                _saveDataAndNavigate(context);
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDataAndNavigate(BuildContext context) async {
    // Merge updated data with existing profile data
    final updatedProfileData = {
      ...widget.profileData, // Retain all existing profile data
      'environmentallyConscious':
          _environmentallyConscious ? 1 : 0, // Update only the relevant field
    };

    try {
      await DatabaseHelper.updateProfile(
          updatedProfileData); // Update the profile
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductInfoScreen(
              profileData: updatedProfileData,
              onProfileComplete: widget.onProfileComplete),
        ),
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }
}
