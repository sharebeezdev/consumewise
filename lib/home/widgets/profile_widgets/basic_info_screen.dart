import 'package:flutter/material.dart';

import '../../../datamodel/utils/database_helper.dart';
import 'healthinfo_screen.dart';

class BasicInfoScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final VoidCallback onProfileComplete;

  BasicInfoScreen({required this.profileData, required this.onProfileComplete});

  @override
  _BasicInfoScreenState createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _age;
  late String _gender;

  @override
  void initState() {
    super.initState();
    _age = widget.profileData['age'] ?? 0;
    _gender = widget.profileData['gender'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'Basic Information',
            style: TextStyle(color: Colors.white),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Age Input
              TextFormField(
                initialValue: _age != 0 ? _age.toString() : '',
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _age = int.parse(value ?? '0');
                },
              ),
              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _gender.isNotEmpty ? _gender : null,
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value ?? ''),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _saveDataAndNavigate(context);
                  }
                },
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Save data and navigate to the next step
  Future<void> _saveDataAndNavigate(BuildContext context) async {
    final newProfileData = {
      'age': _age,
      'gender': _gender,
      ...widget.profileData, // Keep other data intact
    };

    await DatabaseHelper.updateProfile(newProfileData);
    widget.onProfileComplete(); // Trigger the profile reload

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthInfoScreen(
          profileData: newProfileData,
          onProfileComplete: widget.onProfileComplete, // Pass callback
        ),
      ),
    );
  }
}
