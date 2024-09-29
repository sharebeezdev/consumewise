import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../datamodel/utils/database_helper.dart';
import 'product_details_screen.dart';

class FeaturedProductSection extends StatefulWidget {
  const FeaturedProductSection({Key? key}) : super(key: key);

  @override
  FeaturedProductSectionState createState() => FeaturedProductSectionState();
}

class FeaturedProductSectionState extends State<FeaturedProductSection> {
  // Function to fetch top products from database
  Future<List<Map<String, dynamic>>> fetchTopProducts() async {
    print('Fetching product again');
    final topProducts = await DatabaseHelper.fetchTopScannedProducts(3);

    // Debugging: Print the fetched products from the database
    print("Fetched Products: ${topProducts.length}");
    for (var product in topProducts) {
      print(product); // Check individual product data
    }

    return List<Map<String, dynamic>>.from(topProducts); // Ensure correct type
  }

  // Helper function to sanitize and extract JSON part from the response
  String _sanitizeApiResponse(String response) {
    int jsonStartIndex = response.indexOf('{');
    int jsonEndIndex = response.lastIndexOf('}');

    if (jsonStartIndex != -1 && jsonEndIndex != -1) {
      return response.substring(
          jsonStartIndex, jsonEndIndex + 1); // Extract the JSON content
    } else {
      return '{}'; // Return an empty JSON object if the format is unexpected
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Build start');
    return FutureBuilder<List<Map<String, dynamic>>>(
      future:
          fetchTopProducts(), // Call fetchTopProducts every time build is executed
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator()); // Show loading indicator
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading products'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink(); // Return nothing if no products are found
        }

        final _topProducts = snapshot.data!;

        return Container(
          height: 250,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _topProducts.length,
            itemBuilder: (context, index) {
              final product = _topProducts[index];

              // Try parsing the apiResponse
              Map<String, dynamic> productDetails;
              try {
                if (product['apiResponse'] is String) {
                  String sanitizedResponse =
                      _sanitizeApiResponse(product['apiResponse']);
                  productDetails =
                      Map<String, dynamic>.from(jsonDecode(sanitizedResponse));
                } else if (product['apiResponse'] is Map) {
                  productDetails =
                      Map<String, dynamic>.from(product['apiResponse']);
                } else {
                  productDetails = {};
                }
              } catch (e) {
                debugPrint('Error decoding apiResponse: $e');
                productDetails = {};
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
              final keyInsights =
                  summary != null && summary is Map<String, dynamic>
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
                    elevation: 1,
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
                                Expanded(
                                  child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
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
                          imagePath != null
                              ? Image.file(
                                  File(imagePath),
                                  width: 120,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey,
                                  child: Center(child: Text('No Image')),
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
      },
    );
  }
}
