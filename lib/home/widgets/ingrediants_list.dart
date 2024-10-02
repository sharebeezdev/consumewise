import 'dart:convert';
import 'package:flutter/material.dart';

import 'ingredients_section.dart';
import 'nutritional_info_section.dart';

class IngredientListScreen extends StatefulWidget {
  final String apiResponse;

  IngredientListScreen({required this.apiResponse});

  @override
  _IngredientListScreenState createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen> {
  dynamic productData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _parseApiResponse();
  }

  // Safely parse the API response
  void _parseApiResponse() {
    try {
      debugPrint("Full API Response: ${widget.apiResponse}");
      String sanitizedResponse = _extractJson(widget.apiResponse);
      productData = jsonDecode(sanitizedResponse);
      if (productData == null) {
        errorMessage = 'Failed to load product data.';
      }
    } catch (e, stackTrace) {
      errorMessage = 'Failed to parse the API response.';
      debugPrint("Error: $e\nStackTrace: $stackTrace");
    }
    setState(() {});
  }

  // Extract only valid JSON part from the response
  String _extractJson(String response) {
    int jsonEndIndex = response.lastIndexOf('}');
    return jsonEndIndex != -1
        ? response.substring(0, jsonEndIndex + 1)
        : response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Analysis')),
      body: errorMessage != null
          ? _buildErrorMessage()
          : productData != null
              ? _buildProductDetails()
              : Center(child: CircularProgressIndicator()), // Show loading
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMessage!,
              style: TextStyle(fontSize: 18, color: Colors.red)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        _buildProductInfoCard(),
        SizedBox(height: 16),
        _buildInsightsCard(),
        SizedBox(height: 16),
        // Safely pass nutritionalInfo only if not null
        if (productData['nutritionalInfo'] != null)
          NutritionalInfoSection(
              nutritionalInfo: productData['nutritionalInfo']),
        SizedBox(height: 16),
        IngredientsSection(ingredients: productData['ingredients']),
      ],
    );
  }

  // Product Information Section
  Widget _buildProductInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(productData['productTitle'] ?? '',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Category: ${productData['category'] ?? ''}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 10),
            Text("Manufacturer: ${productData['manufacturer'] ?? ''}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // Insights Section
  Widget _buildInsightsCard() {
    final summary = productData['summary'];
    final allergyDetection = productData['ingredientAllergyDetection'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Assessment Section
            Text(
              "Overall Assessment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              summary['overallAssessment'] ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 10),

            // Key Insights Section
            Text(
              "Key Insights",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...List<Widget>.from(
              summary['keyInsights'].map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            SizedBox(height: 10),

            // Recommendation Section
            Text(
              "Recommendation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              summary['recommendation'] ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 20),

            // Ingredient Allergy and Sensitivity Detection (Optional)
            if (allergyDetection != null &&
                allergyDetection['hasAllergiesOrSensitivities'] == true) ...[
              Text(
                "Allergy and Sensitivity Alerts",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
              SizedBox(height: 10),
              ...List<Widget>.from(
                allergyDetection['alerts'].map((alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alert,
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              SizedBox(height: 20),
            ],

            // Safe Alternatives (Optional)
            if (allergyDetection != null &&
                allergyDetection['safeAlternatives'] != null &&
                allergyDetection['safeAlternatives'].isNotEmpty) ...[
              Text(
                "Safe Alternatives",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 10),
              ...List<Widget>.from(
                allergyDetection['safeAlternatives']
                    .map((alternative) => Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 20, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  alternative,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        )),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
