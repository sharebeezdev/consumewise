import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ingrediant_nutritional_info.dart';

class IngredientsSection extends StatelessWidget {
  final List<dynamic> ingredients;

  IngredientsSection({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      debugPrint("IngredientsSection: No ingredients provided.");
      return SizedBox.shrink(); // Hide section if no ingredients
    }

    debugPrint(
        "IngredientsSection: Ingredients data - ${ingredients.toString()}");

    return ExpansionTile(
      title: Text(
        "Ingredients",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: ingredients
          .map(
            (ingredient) => _buildIngredientCard(ingredient, context),
          )
          .toList(),
    );
  }

  // Build each Ingredient card with full device width
  Widget _buildIngredientCard(dynamic ingredient, BuildContext context) {
    // Debug print the entire ingredient to see what we are working with
    debugPrint("Ingredient: ${ingredient.toString()}");

    return Container(
      width: MediaQuery.of(context).size.width, // Full width of the device
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ingredient['name'] ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                "Common Name: ${ingredient['commonName'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                "Nutritional Data",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // Pass nutritional data safely with null check
              IngredientNutritionalInfo(
                nutritionalData: ingredient['nutritionalData'] ?? {},
              ),
              if (_isValidList(ingredient['sideEffects']))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      "Side Effects",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ..._buildSideEffects(ingredient['sideEffects']),
                  ],
                ),
              SizedBox(height: 8),
              if (_isValidList(ingredient['externalSources']))
                _buildExternalSources(ingredient['externalSources'], context),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build side effects safely
  List<Widget> _buildSideEffects(dynamic sideEffects) {
    if (_isValidList(sideEffects)) {
      return (sideEffects as List)
          .map<Widget>((effect) => Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  "- $effect",
                  style: TextStyle(fontSize: 14, color: Colors.red[700]),
                ),
              ))
          .toList();
    } else {
      debugPrint("Side effects are invalid or not a list: $sideEffects");
      return [];
    }
  }

  // Helper function to validate if a variable is a non-empty list
  bool _isValidList(dynamic value) {
    return value != null && value is List && value.isNotEmpty;
  }

  // Build external sources for ingredients
  Widget _buildExternalSources(dynamic externalSources, BuildContext context) {
    if (!_isValidList(externalSources)) {
      debugPrint("Invalid or empty externalSources: $externalSources");
      return SizedBox.shrink(); // Return empty widget if invalid
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "External Sources",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...externalSources.map<Widget>((source) {
          return GestureDetector(
            onTap: () => _openSourceUrl(context, source), // Pass context here
            child: Text(
              source,
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Open URL function
  void _openSourceUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}
