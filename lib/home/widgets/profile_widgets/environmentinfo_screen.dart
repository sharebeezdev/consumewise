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
    _environmentallyConscious =
        widget.profileData['environmentallyConscious'] == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Environmental Preferences',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CheckboxListTile(
              title: Text('Are you environmentally conscious?'),
              value: _environmentallyConscious,
              onChanged: (value) {
                setState(() {
                  _environmentallyConscious = value ?? false;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Spacer(),
            // Floating Action Button for 'Next'
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              width: double.infinity,
              child: FloatingActionButton.extended(
                onPressed: () => _saveDataAndNavigate(context),
                label: Text('Next'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _saveDataAndNavigate(BuildContext context) async {
    final updatedProfileData = {
      ...widget.profileData,
      'environmentallyConscious': _environmentallyConscious ? 1 : 0,
    };

    await DatabaseHelper.updateProfile(updatedProfileData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductInfoScreen(
          profileData: updatedProfileData,
          onProfileComplete: widget.onProfileComplete,
        ),
      ),
    );
  }
}
