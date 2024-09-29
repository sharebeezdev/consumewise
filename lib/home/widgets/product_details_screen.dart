import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'ingredients_section.dart';
import 'nutritional_info_section.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> productDetails;
  final String imagePath;

  ProductDetailsPage({required this.productDetails, required this.imagePath});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  dynamic productData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _parseApiResponse();
  }

  // Parse the API response (already passed as a Map, no need to decode JSON)
  void _parseApiResponse() {
    try {
      productData = widget.productDetails;
      if (productData == null) {
        errorMessage = 'Failed to load product data.';
      }
    } catch (e, stackTrace) {
      errorMessage = 'Failed to parse the product data.';
      debugPrint("Error: $e\nStackTrace: $stackTrace");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'Product Details',
            style: TextStyle(color: Colors.white), // Setting the text color to white
          )),
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
        _buildProductImage(), // Product Image
        SizedBox(height: 16),
        _buildProductInfoCard(), // Product Info Card (title, category, manufacturer)
        SizedBox(height: 16),
        if (productData['summary'] != null)
          _buildInsightsCard(), // Insights Card only if available
        SizedBox(height: 16),
        // Safely pass nutritionalInfo only if not null
        if (productData['nutritionalInfo'] != null)
          NutritionalInfoSection(
              nutritionalInfo: productData['nutritionalInfo']),
        SizedBox(height: 16),
        if (productData['ingredients'] != null)
          IngredientsSection(ingredients: productData['ingredients']),
      ],
    );
  }

  // Product Image Section
  Widget _buildProductImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(widget.imagePath), // Display the product image from the file
          width: double.infinity,
          height: 250,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // Product Information Section
  Widget _buildProductInfoCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productData['productTitle'] != null)
              Text(productData['productTitle'] ?? '',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (productData['category'] != null) SizedBox(height: 10),
            Text("Category: ${productData['category'] ?? ''}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            if (productData['manufacturer'] != null) SizedBox(height: 10),
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
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (summary != null && summary['overallAssessment'] != null)
              Text("Overall Assessment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (summary != null && summary['overallAssessment'] != null)
              Text(summary['overallAssessment'] ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800])),
            SizedBox(height: 10),
            if (summary != null && summary['keyInsights'] != null)
              Text("Key Insights",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (summary != null && summary['keyInsights'] != null)
              ...List<Widget>.from(
                  summary['keyInsights'].map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child:
                            Text("- $insight", style: TextStyle(fontSize: 16)),
                      ))),
            SizedBox(height: 10),
            if (summary != null && summary['recommendation'] != null)
              Text("Recommendation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (summary != null && summary['recommendation'] != null)
              Text(summary['recommendation'] ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }
}
