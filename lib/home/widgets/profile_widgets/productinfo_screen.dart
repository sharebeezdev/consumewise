import 'package:flutter/material.dart';
import '../../../datamodel/utils/database_helper.dart';
import 'privacyinfo_screen.dart';

class ProductInfoScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final VoidCallback onProfileComplete;

  ProductInfoScreen({
    required this.profileData,
    required this.onProfileComplete,
  });

  @override
  _ProductInfoScreenState createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _productInterests;
  late String _nutritionalGoal;

  @override
  void initState() {
    super.initState();

    // Debug: Log the passed profileData
    debugPrint('Passed Profile Data: ${widget.profileData}');

    // Initialize with the values from the profileData or use empty strings
    _productInterests = widget.profileData['productInterests'] ?? '';
    _nutritionalGoal = widget.profileData['nutritionalGoal'] ?? '';

    // Debug: Log the initialized form values
    debugPrint('Initial Product Interests: $_productInterests');
    debugPrint('Initial Nutritional Goal: $_nutritionalGoal');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product and Lifestyle Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Product Interests
              TextFormField(
                initialValue: _productInterests,
                decoration: InputDecoration(labelText: 'Product Interests'),
                onSaved: (value) {
                  _productInterests = value ?? '';
                  debugPrint('Updated Product Interests: $_productInterests');
                },
              ),
              SizedBox(height: 16),
              // Nutritional Goal
              TextFormField(
                initialValue: _nutritionalGoal,
                decoration: InputDecoration(labelText: 'Nutritional Goal'),
                onSaved: (value) {
                  _nutritionalGoal = value ?? '';
                  debugPrint('Updated Nutritional Goal: $_nutritionalGoal');
                },
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

  Future<void> _saveDataAndNavigate(BuildContext context) async {
    // Debug: Log form data before updating the profile
    debugPrint(
        'Saving Data: Product Interests: $_productInterests, Nutritional Goal: $_nutritionalGoal');

    // Merge the updated data with the existing profileData
    final updatedProfileData = {
      ...widget.profileData, // Merge the existing data
      'productInterests': _productInterests,
      'nutritionalGoal': _nutritionalGoal,
    };

    // Debug: Log the updated profile data before saving
    debugPrint('Updated Profile Data to be Saved: $updatedProfileData');

    // Save updated profile to the database
    try {
      await DatabaseHelper.updateProfile(updatedProfileData);
      debugPrint('Profile updated successfully');
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }

    // Navigate to the next screen and pass the updated profile data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivacyInfoScreen(
          profileData: updatedProfileData,
          onProfileComplete: widget.onProfileComplete, // Pass callback
        ),
      ),
    );
  }
}
