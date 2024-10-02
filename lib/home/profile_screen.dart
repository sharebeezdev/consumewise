import 'package:flutter/material.dart';
import '../datamodel/utils/database_helper.dart';
import 'widgets/profile_widgets/basic_info_screen.dart';

class ProfileSetupFlow extends StatefulWidget {
  @override
  _ProfileSetupFlowState createState() => _ProfileSetupFlowState();
}

class _ProfileSetupFlowState extends State<ProfileSetupFlow> {
  Map<String, dynamic> _profileData = {};
  String _selectedLanguage = 'English'; // Default language selection
  final List<String> _languages = [
    'English',
    'Telugu',
    'Spanish',
    'French',
    'German',
    'Hindi'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load profile data if it exists
  Future<void> _loadProfile() async {
    final profile = await DatabaseHelper.fetchProfile();
    if (profile != null) {
      setState(() {
        _profileData = profile;
        _selectedLanguage = profile['language'] ?? 'English'; // Set language
      });
      print('Fetched profile: $_profileData');
    } else {
      print('No profile found in the database');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Profile Setup'),
        actions: [
          if (_profileData.isNotEmpty)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit screen
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BasicInfoScreen(
                            profileData: _profileData,
                            onProfileComplete: _loadProfile)));
              },
            ),
        ],
      ),
      body: _profileData.isEmpty
          ? _buildProfileSetupPrompt() // If profile doesn't exist, show setup prompt
          : _showProfile(), // If profile exists, show profile
    );
  }

  // Display saved profile in a modern card-style view
  Widget _showProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern profile card
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Profile Information",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  _buildProfileDetailRow(
                      "Age", _profileData['age']?.toString() ?? 'N/A'),
                  _buildProfileDetailRow(
                      "Gender", _profileData['gender'] ?? 'N/A'),
                  _buildProfileDetailRow(
                      "Diet", _profileData['dietPreference'] ?? 'N/A'),
                  _buildMultilineProfileDetailRow(
                      "Allergies", _profileData['allergies'] ?? 'N/A'),
                  _buildMultilineProfileDetailRow("Medical Condition",
                      _profileData['medicalCondition'] ?? 'N/A'),
                  _buildProfileDetailRow(
                    "Environmentally Conscious",
                    _profileData['environmentallyConscious'] == 1
                        ? 'Yes'
                        : 'No',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildProfileDetailRow(
                          "Preferred Language",
                          _profileData['language'] ?? 'English',
                        ),
                      ),
                      // IconButton(
                      //   icon: Icon(Icons.edit),
                      //   onPressed: _showLanguageChangeDialog,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _showLanguageChangeDialog();
            },
            child: Text('Change Preferred Language'),
          ),
        ],
      ),
    );
  }

  // Modern row-style for profile details
  Widget _buildProfileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis, // Handle long text by ellipsis
            ),
          ),
        ],
      ),
    );
  }

  // Multiline profile details for longer text fields like Allergies, Medical Conditions
  Widget _buildMultilineProfileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis, // Show ellipsis if too long
          ),
        ],
      ),
    );
  }

  // Method to show a dialog for changing the language
  Future<void> _showLanguageChangeDialog() async {
    String newLanguage = _selectedLanguage;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Preferred Language'),
          content: DropdownButtonFormField<String>(
            value: newLanguage,
            items: _languages.map((language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (value) {
              newLanguage = value!;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Update the selected language in the profile
                setState(() {
                  _selectedLanguage = newLanguage;
                });

                // Update the database with the new language
                await _updatePreferredLanguage(newLanguage);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to update the preferred language in the database
  Future<void> _updatePreferredLanguage(String language) async {
    print('Updating preferred language to: $language');
    final updatedProfileData = {
      ..._profileData,
      'language': language,
    };

    // Update the database with the new language
    await DatabaseHelper.updateProfile(updatedProfileData);

    // Reload the profile data after update
    await _loadProfile();
  }

  // Profile setup prompt with language selection and informative text
  Widget _buildProfileSetupPrompt() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Set up your profile for personalized insights!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "We use this information to provide you with personalized suggestions, insights on your nutrition, and better product recommendations. "
            "This helps Gemini AI to tailor recommendations and provide a more enhanced experience, without collecting any personally identifiable information (PII). "
            "Your data is completely safe and won't be shared with third parties.",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          // Language selection dropdown
          Text("Preferred Language", style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            items: _languages.map((language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          SizedBox(height: 30),
          // Start profile setup button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BasicInfoScreen(
                          profileData: {'language': _selectedLanguage},
                          onProfileComplete: _loadProfile)));
            },
            child: Text('Set Up Profile'),
          ),
        ],
      ),
    );
  }
}
