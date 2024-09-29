import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../datamodel/utils/database_helper.dart';
import 'product_details_screen.dart';

class FeaturedProductSection extends StatefulWidget {
  @override
  _FeaturedProductSectionState createState() => _FeaturedProductSectionState();
}

class _FeaturedProductSectionState extends State<FeaturedProductSection> {
  List<Map<String, dynamic>> _topProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTopProducts();
  }

  Future<void> _fetchTopProducts() async {
    final topProducts = await DatabaseHelper.fetchTopScannedProducts(3);
    setState(() {
      _topProducts =
          List<Map<String, dynamic>>.from(topProducts); // Ensure correct type
      _isLoading = false; // Stop loading once data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox.shrink(); // Hide section when loading
    }

    // Hide section if no products found
    if (_topProducts.isEmpty) {
      return SizedBox.shrink(); // Return nothing if no products found
    }

    return Container(
      height: 250,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _topProducts.length,
        itemBuilder: (context, index) {
          final product = _topProducts[index];

          // Debug: Print the entire product to understand its structure
          debugPrint('Product $index: ${product.toString()}', wrapWidth: 1024);

          // Try parsing the apiResponse
          Map<String, dynamic> productDetails;
          try {
            // Handle if apiResponse is already a Map or is a String
            if (product['apiResponse'] is String) {
              debugPrint('apiResponse is a String: ${product['apiResponse']}',
                  wrapWidth: 1024);
              productDetails =
                  Map<String, dynamic>.from(jsonDecode(product['apiResponse']));
              debugPrint('Decoded apiResponse: $productDetails');
            } else if (product['apiResponse'] is Map) {
              debugPrint('apiResponse is a Map');
              productDetails =
                  Map<String, dynamic>.from(product['apiResponse']);
            } else {
              debugPrint(
                  'Unexpected apiResponse format: ${product['apiResponse']}');
              productDetails =
                  {}; // Default to empty map if format is unexpected
            }
          } catch (e) {
            // Print detailed error message and apiResponse content
            debugPrint('Error decoding apiResponse: $e');
            debugPrint('apiResponse content: ${product['apiResponse']}',
                wrapWidth: 1024);
            productDetails = {}; // Default to empty map on error
          }

          final imagePath = product['imagePath'];
          final productTitle = productDetails['productTitle'] ?? 'No Title';
          final category = productDetails['category'] ?? 'No Category';
          final manufacturer =
              productDetails['manufacturer'] ?? 'No Manufacturer';

          // Extracting overallAssessment and keyInsights from summary
          final summary = productDetails['summary'];
          final overallAssessment =
              summary != null && summary is Map<String, dynamic>
                  ? summary['overallAssessment'] ?? 'No Assessment'
                  : 'No Assessment';
          final keyInsights = summary != null && summary is Map<String, dynamic>
              ? summary['keyInsights'] as List<dynamic>? ?? []
              : [];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(
                    productDetails: productDetails,
                    imagePath: imagePath,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                surfaceTintColor: Colors.white, // Material 3 Card background
                elevation: 1, // Material You Card elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '$category | $manufacturer',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 10),
                            Text(
                              overallAssessment,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: 10),
                            // Show key insights, wrapped inside the available height of the card
                            Expanded(
                              child: ListView.builder(
                                physics:
                                    NeverScrollableScrollPhysics(), // Disable scrolling inside the card
                                shrinkWrap: true,
                                itemCount: keyInsights.length,
                                itemBuilder: (context, index) {
                                  return Text(
                                    '- ${keyInsights[index]}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Image.file(
                        File(imagePath), // Display the product image
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
