import 'package:flutter/material.dart';
import 'nutritional_datacard.dart';

class IngredientNutritionalInfo extends StatelessWidget {
  final Map<String, dynamic> nutritionalData;

  IngredientNutritionalInfo({required this.nutritionalData});

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
    if (nutritionalData.isEmpty) {
      return SizedBox.shrink(); // Hide if no data available
    }

    final entries =
        nutritionalData.entries.toList(); // Convert map to list of entries

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: List.generate(entries.length, (index) {
        final entry = entries[index]; // Get the MapEntry at the index
        if (entry.value != null && entry.value is String) {
          final parts = entry.value.split(' '); // Split value and unit

          // Check if parts[0] exists and is not empty or null
          if (parts.isNotEmpty && parts[0].isNotEmpty && parts[0] != 'null') {
            return NutritionalDataCard(
              title: entry.key, // Nutrient name (e.g., Energy, Protein)
              value: parts[0], // Extract value (e.g., '77')
              unit: parts.length > 1
                  ? parts[1]
                  : '', // Extract unit (e.g., 'g'), handle missing unit
              color: cardColors[index % cardColors.length], // Cycle colors
            );
          }
        }
        return SizedBox.shrink(); // Skip if value is invalid or empty
      }),
    );
  }
}
