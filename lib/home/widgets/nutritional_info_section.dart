import 'dart:convert';
import 'package:flutter/material.dart';

import 'nutritional_datacard.dart';

class NutritionalInfoSection extends StatelessWidget {
  final List<dynamic> nutritionalInfo;

  NutritionalInfoSection({required this.nutritionalInfo});

  // List of colors to cycle through for the cards
  final List<Color> cardColors = [
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.yellow.shade50,
    Colors.pink.shade50,
    Colors.purple.shade50,
  ];

  @override
  Widget build(BuildContext context) {
    if (nutritionalInfo.isEmpty) {
      return SizedBox.shrink(); // Return nothing if no data
    }

    print("Nutritional Info is ");
    String prettyJson =
        const JsonEncoder.withIndent('  ').convert(nutritionalInfo);
    debugPrint(prettyJson, wrapWidth: 1024);
    print("Nutritional Info is End");

    // Check which sections (per 100g, per serving, %RDA) should be shown
    bool containsPer100g = nutritionalInfo.any((info) =>
        info is Map<String, dynamic> && _isValidNumeric(info['per100g']));
    bool containsPerServing = nutritionalInfo.any((info) =>
        info is Map<String, dynamic> && _isValidNumeric(info['perServing']));

    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nutritional Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      children: [
        if (containsPer100g) _buildSection(context, "Per 100g Data", 'per100g'),
        if (containsPerServing)
          _buildSection(context, "Per Serving Data", 'perServing'),
      ],
    );
  }

  // Helper function to check if a value is a valid numeric (either String or double)
  bool _isValidNumeric(dynamic value) {
    return value != null &&
        (value is String && value.isNotEmpty || value is double);
  }

  // Function to build different sections based on the data type
  Widget _buildSection(BuildContext context, String title, String dataKey) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Wrap(
            spacing: 10.0, // Space between cards horizontally
            runSpacing: 10.0, // Space between cards vertically
            children: List.generate(nutritionalInfo.length, (index) {
              final info = nutritionalInfo[index];

              // Ensure the key (dataKey) exists and is either a valid String or a double
              if (info is Map<String, dynamic> &&
                  info[dataKey] != null &&
                  (info[dataKey] is String && info[dataKey].isNotEmpty ||
                      info[dataKey] is double)) {
                final value = info[dataKey].toString();
                String unit = ''; // Default to empty string

                // Handle per100g and perServing, both might have value and unit separated by space
                if (dataKey == 'per100g' || dataKey == 'perServing') {
                  List<String> parts = value.split(' ');
                  unit = parts.length > 1
                      ? parts[1]
                      : ''; // Extract unit if present
                }

                return NutritionalDataCard(
                  title: info['nutrient'] ??
                      info['name'] ??
                      '', // Use 'name' key for nutrient
                  value: value.split(' ')[0], // Extract value
                  unit: unit, // Extract unit (if available)
                  color: cardColors[index % cardColors.length], // Cycle colors
                );
              }

              // If no valid data, return an empty widget
              return SizedBox.shrink();
            }),
          ),
        ],
      ),
    );
  }
}
