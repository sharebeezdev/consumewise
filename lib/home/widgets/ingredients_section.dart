import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ingrediant_nutritional_info.dart';

class IngredientsSection extends StatelessWidget {
  final List<dynamic> ingredients;

  IngredientsSection({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Ingredients",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: ingredients
          .map(
            (ingredient) => _buildIngredientCard(ingredient, context),
          )
          .toList(),
    );
  }

  // Build each Ingredient card
  Widget _buildIngredientCard(dynamic ingredient, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ingredient['name'] ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Common Name: ${ingredient['commonName'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Nutritional Data",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IngredientNutritionalInfo(
                nutritionalData: ingredient['nutritionalData']),
            if (ingredient['sideEffects'] != null &&
                (ingredient['sideEffects'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text("Side Effects",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...ingredient['sideEffects']
                      .map<Widget>((effect) => Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text("- $effect",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.red[700])),
                          ))
                      .toList(),
                ],
              ),
            SizedBox(height: 8),
            // Check if externalSources is not empty before rendering the section
            if (ingredient['externalSources'] != null &&
                (ingredient['externalSources'] as List).isNotEmpty)
              _buildExternalSources(ingredient['externalSources'], context),
          ],
        ),
      ),
    );
  }

  // Build external sources for ingredients
  void _openSourceUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Use the passed context to show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Widget _buildExternalSources(
      List<dynamic> externalSources, BuildContext context) {
    if (externalSources.isEmpty) return SizedBox.shrink(); // Hide if empty

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("External Sources",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...externalSources.map<Widget>((source) {
          return GestureDetector(
            onTap: () => _openSourceUrl(context, source), // Pass context here
            child: Text(source,
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline)),
          );
        }).toList(),
      ],
    );
  }
}
