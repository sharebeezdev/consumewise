import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../datamodel/utils/database_helper.dart';
import '../bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PrivacyInfoScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final VoidCallback onProfileComplete;

  PrivacyInfoScreen(
      {required this.profileData, required this.onProfileComplete});

  @override
  _PrivacyInfoScreenState createState() => _PrivacyInfoScreenState();
}

class _PrivacyInfoScreenState extends State<PrivacyInfoScreen> {
  bool _personalizedInsights = false;

  @override
  void initState() {
    super.initState();
    _personalizedInsights =
        widget.profileData['dataSharingPreference'] == 'yes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy and Data Sharing Preferences',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Why we need your profile information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We collect this data to provide you with personalized insights and recommendations based on your profile and preferences. Your data is secure and will never be shared with third parties without your consent.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text(
                'I would like to receive personalized insights and recommendations',
                style: TextStyle(fontSize: 16),
              ),
              value: _personalizedInsights,
              onChanged: (value) {
                setState(() {
                  _personalizedInsights = value ?? false;
                });
              },
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              width: double.infinity,
              child: FloatingActionButton.extended(
                onPressed: () => _saveDataAndComplete(context),
                label: Text('Finish'),
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

  Future<void> _saveDataAndComplete(BuildContext context) async {
    final updatedProfileData = {
      ...widget.profileData,
      'dataSharingPreference': _personalizedInsights ? 'yes' : 'no',
    };

    await DatabaseHelper.updateProfile(updatedProfileData);

    widget.onProfileComplete(); // Trigger profile reload

    // Call _generateKeywordsByProfile and store in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final keywordsResponse =
        await _generateKeywordsByProfile(updatedProfileData);
    if (keywordsResponse != null && keywordsResponse['keywords'] != null) {
      final keywords =
          (keywordsResponse['keywords'] as List<dynamic>).join(' ');
      await prefs.setString('cached_keywords', keywords); // Store keywords
    }

    // Check if the user is in profile setup flow
    bool isProfileSetupFlow = prefs.getBool('isProfileSetupFlow') ?? false;

    if (isProfileSetupFlow) {
      await prefs.remove('isProfileSetupFlow');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNav()),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  Future<Map<String, dynamic>?> _generateKeywordsByProfile(
      Map<String, dynamic> profileData) async {
    final response = await http.post(
      Uri.parse(
          'https://google-gemini-api-v2-837715105352.us-central1.run.app/generateKeywordsByProfile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "personalInfo": {
          "dietPreference": profileData['dietPreference'] ?? '',
          "allergies": profileData['allergies'] ?? '',
          "medicalCondition": profileData['medicalCondition'] ?? '',
          "nutritionalGoal": profileData['nutritionalGoal'] ?? '',
          "productInterests": profileData['productInterests'] ?? 'Snacks',
        }
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to generate keywords');
      return null;
    }
  }
}
