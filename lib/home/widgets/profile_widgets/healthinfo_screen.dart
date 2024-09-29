import 'package:flutter/material.dart';
import '../../../datamodel/utils/database_helper.dart';
import 'environmentinfo_screen.dart';

class HealthInfoScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final VoidCallback onProfileComplete;

  HealthInfoScreen(
      {required this.profileData, required this.onProfileComplete});

  @override
  _HealthInfoScreenState createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends State<HealthInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _dietPreference;
  late String _allergies;
  late String _medicalCondition;

  @override
  void initState() {
    super.initState();
    _dietPreference = widget.profileData['dietPreference'] ?? '';
    _allergies = widget.profileData['allergies'] ?? '';
    _medicalCondition = widget.profileData['medicalCondition'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'Health Information',
            style: TextStyle(color: Colors.white),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Dietary Preferences Dropdown
              DropdownButtonFormField<String>(
                value: _dietPreference.isNotEmpty ? _dietPreference : null,
                decoration: InputDecoration(labelText: 'Dietary Preference'),
                items: ['Vegetarian', 'Vegan', 'Paleo', 'Keto', 'Gluten-Free']
                    .map((diet) => DropdownMenuItem(
                          value: diet,
                          child: Text(diet),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _dietPreference = value ?? ''),
              ),
              // Allergies Input
              TextFormField(
                initialValue: _allergies,
                decoration: InputDecoration(labelText: 'Allergies (if any)'),
                onSaved: (value) {
                  _allergies = value ?? '';
                },
              ),
              // Medical Conditions Input
              TextFormField(
                initialValue: _medicalCondition,
                decoration:
                    InputDecoration(labelText: 'Medical Conditions (if any)'),
                onSaved: (value) {
                  _medicalCondition = value ?? '';
                },
              ),
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

  // Save data and navigate to next step
  Future<void> _saveDataAndNavigate(BuildContext context) async {
    final updatedProfileData = {
      'dietPreference': _dietPreference,
      'allergies': _allergies,
      'medicalCondition': _medicalCondition,
      ...widget.profileData,
    };

    await DatabaseHelper.updateProfile(updatedProfileData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnvironmentInfoScreen(
          profileData: updatedProfileData,
          onProfileComplete: widget.onProfileComplete, // Pass the callback
        ),
      ),
    );
  }
}
