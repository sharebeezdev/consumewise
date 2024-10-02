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
      appBar: AppBar(
        title: Text(
          'Basic Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Age Input
              TextFormField(
                initialValue: _age != 0 ? _age.toString() : '',
                decoration: InputDecoration(
                  labelText: 'Age',
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
                onSaved: (value) {
                  _age = int.parse(value ?? '0');
                },
              ),
              SizedBox(height: 16),
              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _gender.isNotEmpty ? _gender : null,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value ?? ''),
              ),
              SizedBox(height: 16),
              Spacer(), // Push content upwards
              // Information
              Text(
                'This information will help us customize your experience.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              _saveDataAndNavigate(context);
            }
          },
          label: Text(
            'Next',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _saveDataAndNavigate(BuildContext context) async {
    final newProfileData = {
      ...widget.profileData,
      'age': _age,
      'gender': _gender,
    };

    await DatabaseHelper.updateProfile(newProfileData);
    widget.onProfileComplete();

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
