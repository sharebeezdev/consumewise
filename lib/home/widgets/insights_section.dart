import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

import '../../datamodel/utils/database_helper.dart';

class InsightsSection extends StatefulWidget {
  @override
  _InsightsSectionState createState() => _InsightsSectionState();
}

class _InsightsSectionState extends State<InsightsSection> {
  List<dynamic> _insights = [];
  bool _isLoading = true;
  static const String _insightsKey = 'cached_insights';
  static const String _timestampKey = 'cached_timestamp';

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedInsights = prefs.getString(_insightsKey);
    String? cachedTimestamp = prefs.getString(_timestampKey);

    if (cachedInsights != null && _isSameDay(cachedTimestamp)) {
      setState(() {
        _insights = jsonDecode(cachedInsights);
        _isLoading = false;
      });
    } else {
      await _fetchInsights();
    }
  }

  bool _isSameDay(String? cachedTimestamp) {
    if (cachedTimestamp == null) return false;
    DateTime lastSaved = DateTime.parse(cachedTimestamp);
    DateTime now = DateTime.now();
    return now.year == lastSaved.year &&
        now.month == lastSaved.month &&
        now.day == lastSaved.day;
  }

  Future<void> _fetchInsights() async {
    try {
      final profileData = await DatabaseHelper.fetchProfile();
      String personalInfoJson = profileData != null
          ? jsonEncode(profileData)
          : jsonEncode({
              "dietPreference": "",
              "allergies": "",
              "medicalCondition": "",
              "nutritionalGoal": "",
              "language": "English",
            });
      final response = await http.post(
        Uri.parse(
            'https://google-gemini-api-v2-837715105352.us-central1.run.app/insights'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'personalInfo': jsonDecode(personalInfoJson),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _insights = jsonDecode(response.body);
          _isLoading = false;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(_insightsKey, response.body);
        await prefs.setString(_timestampKey, DateTime.now().toIso8601String());
      } else {
        print('Failed to fetch insights');
      }
    } catch (e) {
      print('Error fetching insights: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            _getGreeting(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: <Color>[Colors.blue, Colors.purple],
                ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
            ),
          ),
        ),
        _isLoading ? _buildShimmerEffect() : _buildInsightsList(),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInsightsList() {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _insights.length,
        itemBuilder: (context, index) {
          final insight = _insights[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                _showInsightDetail(context, insight);
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: 250,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            insight['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: _getIconForType(insight['type']),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Return icon based on insight type (food tip or health tip)
  Widget _getIconForType(String type) {
    if (type == 'food tip') {
      return Icon(
        Icons.fastfood,
        color: Colors.greenAccent,
        size: 24,
      );
    } else if (type == 'health tip') {
      return Icon(
        Icons.health_and_safety,
        color: Colors.orangeAccent,
        size: 24,
      );
    } else {
      return Icon(
        Icons.info,
        color: Colors.blueAccent,
        size: 24,
      );
    }
  }

  // Show Insight Details in Focus
  void _showInsightDetail(BuildContext context, Map<String, dynamic> insight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  insight['description'],
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
