import 'package:flutter/material.dart';
import '../../../datamodel/utils/database_helper.dart';

class PrivacyInfoScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final VoidCallback onProfileComplete;

  PrivacyInfoScreen(
      {required this.profileData, required this.onProfileComplete});

  @override
  _PrivacyInfoScreenState createState() => _PrivacyInfoScreenState();
}

class _PrivacyInfoScreenState extends State<PrivacyInfoScreen> {
  String _dataSharingPreference = '';

  @override
  void initState() {
    super.initState();
    _dataSharingPreference = widget.profileData['dataSharingPreference'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'Privacy and Data Sharing Preferences',
            style: TextStyle(color: Colors.white),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                initialValue: _dataSharingPreference,
                decoration:
                    InputDecoration(labelText: 'Data Sharing Preference'),
                onChanged: (value) {
                  setState(() {
                    _dataSharingPreference = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _saveDataAndComplete(context);
                },
                child: Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveDataAndComplete(BuildContext context) async {
    final updatedProfileData = {
      'dataSharingPreference': _dataSharingPreference,
    };

    await DatabaseHelper.updateProfile(updatedProfileData);

    widget.onProfileComplete(); // Trigger profile reload

    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
