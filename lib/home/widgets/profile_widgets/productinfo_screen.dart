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
    _productInterests = widget.profileData['productInterests'] ?? '';
    _nutritionalGoal = widget.profileData['nutritionalGoal'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product and Lifestyle Preferences',
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
              // Product Interests
              TextFormField(
                initialValue: _productInterests,
                decoration: InputDecoration(
                  labelText: 'Product Interests',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _productInterests = value ?? '',
              ),
              SizedBox(height: 16),
              // Nutritional Goal
              TextFormField(
                initialValue: _nutritionalGoal,
                decoration: InputDecoration(
                  labelText: 'Nutritional Goal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _nutritionalGoal = value ?? '',
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

  Future<void> _saveDataAndNavigate(BuildContext context) async {
    final updatedProfileData = {
      ...widget.profileData,
      'productInterests': _productInterests,
      'nutritionalGoal': _nutritionalGoal,
    };

    await DatabaseHelper.updateProfile(updatedProfileData); // Save to DB
    widget.onProfileComplete(); // Trigger the profile reload

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
