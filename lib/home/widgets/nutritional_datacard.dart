import 'package:flutter/material.dart';

class NutritionalDataCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color; // New property to accept color

  NutritionalDataCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color, // Use the passed color
        borderRadius: BorderRadius.circular(10),
      ),
      width: 100, // Fixed width for consistency across all cards
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title, // Nutrient title (e.g., Energy, Protein)
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            value, // Bold numeric value (e.g., 77)
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2),
          Text(
            unit, // Smaller unit text (e.g., kcal, g)
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
