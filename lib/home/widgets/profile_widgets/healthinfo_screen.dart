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
      appBar: AppBar(
        title: Text(
          'Health Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _dietPreference.isNotEmpty ? _dietPreference : null,
                decoration: InputDecoration(
                  labelText: 'Dietary Preference',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['Vegetarian', 'Vegan', 'Paleo', 'Keto', 'Gluten-Free']
                    .map((diet) => DropdownMenuItem(
                          value: diet,
                          child: Text(diet),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _dietPreference = value ?? ''),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _allergies,
                decoration: InputDecoration(
                  labelText: 'Allergies (if any)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _allergies = value ?? '',
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _medicalCondition,
                decoration: InputDecoration(
                  labelText: 'Medical Conditions (if any)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _medicalCondition = value ?? '',
              ),
              Spacer(),
              // Floating Action Button for 'Next'
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                width: double.infinity,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _saveDataAndNavigate(context);
                    }
                  },
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Save data and navigate to the next step
  Future<void> _saveDataAndNavigate(BuildContext context) async {
    final updatedProfileData = {
      ...widget.profileData,
      'dietPreference': _dietPreference,
      'allergies': _allergies,
      'medicalCondition': _medicalCondition,
    };

    await DatabaseHelper.updateProfile(updatedProfileData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnvironmentInfoScreen(
          profileData: updatedProfileData,
          onProfileComplete: widget.onProfileComplete,
        ),
      ),
    );
  }
}
