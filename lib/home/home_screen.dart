import 'package:consume_wise/home/app_bar.dart';
import 'package:flutter/material.dart';
import 'widgets/food_search_section.dart';
import 'widgets/featured_product_section.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../datamodel/utils/database_helper.dart';
import 'widgets/insights_section.dart';
import 'widgets/product_card_search_result.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onRefreshProducts;

  HomeScreen({required this.onRefreshProducts});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FeaturedProductSectionState> _featuredProductKey =
      GlobalKey<FeaturedProductSectionState>();
  List<dynamic> _recommendedProducts = [];
  bool _isLoading = true;
  static const String _keywordsKey = 'cached_keywords';
  static const int _maxRetries = 2; // Limit retries to 2
  int _retryCount = 0; // Track the number of retries

  @override
  void initState() {
    super.initState();
    widget.onRefreshProducts();
    _loadRecommendedProducts();
  }

  // Step 1: Load recommended products by first checking SharedPreferences for keywords
  Future<void> _loadRecommendedProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedKeywords = prefs.getString(_keywordsKey);

      if (cachedKeywords != null) {
        // Use cached keywords to fetch recommendations
        await _fetchAndDisplayRecommendations(cachedKeywords);
      } else {
        // Fetch user profile and generate keywords if no cache exists
        final profileData = await DatabaseHelper.fetchProfile();

        if (profileData != null) {
          final keywordsResponse =
              await _generateKeywordsByProfile(profileData);
          if (keywordsResponse != null &&
              keywordsResponse['keywords'] != null) {
            final keywords =
                (keywordsResponse['keywords'] as List<dynamic>).join(' ');

            // Save the generated keywords in SharedPreferences
            await prefs.setString(_keywordsKey, keywords);

            // Fetch recommendations based on the new keywords
            await _fetchAndDisplayRecommendations(keywords);
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading recommended products: $e');
    }
  }

  // Step 2: Fetch and display recommendations with a retry mechanism
  Future<void> _fetchAndDisplayRecommendations(String keywords) async {
    try {
      final profileData = await DatabaseHelper.fetchProfile();
      final recommendedProducts =
          await _fetchRecommendations(keywords, profileData!);

      if (recommendedProducts.isEmpty) {
        _retryCount++;

        if (_retryCount < _maxRetries) {
          // Retry with a fallback query if no products are found
          await _fetchAndDisplayRecommendations('suggest some food to eat');
        } else {
          // Show a custom no results widget after 2 tries
          setState(() {
            _recommendedProducts = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _recommendedProducts = recommendedProducts.take(10).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching recommendations: $e');
    }
  }

  Future<Map<String, dynamic>?> _generateKeywordsByProfile(
      Map<String, dynamic> profileData) async {
    final response = await http.post(
      Uri.parse(
          'https://google-gemini-api-v2-837715105352.us-central1.run.app/generateKeywordsByProfile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "personalInfo": {
          "dietPreference": profileData['dietPreference'] ?? '',
          "allergies": profileData['allergies'] ?? '',
          "medicalCondition": profileData['medicalCondition'] ?? '',
          "nutritionalGoal": profileData['nutritionalGoal'] ?? '',
          "productInterests": profileData['productInterests'] ?? 'Snacks',
        }
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to generate keywords');
      return null;
    }
  }

  Future<List<dynamic>> _fetchRecommendations(
      String query, Map<String, dynamic> profileData) async {
    final response = await http.post(
      Uri.parse(
          'https://google-gemini-api-v2-837715105352.us-central1.run.app/recommendations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "query": query,
        "personalInfo": {
          "dietPreference": profileData['dietPreference'] ?? '',
          "allergies": profileData['allergies'] ?? '',
          "medicalCondition": profileData['medicalCondition'] ?? '',
          "nutritionalGoal": profileData['nutritionalGoal'] ?? '',
          "environmentallyConscious":
              profileData['environmentallyConscious'] ?? false,
        }
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch recommendations');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ConsumeWiseAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoodSearchSection(),
            InsightsSection(),
            FeaturedProductSection(
              key: _featuredProductKey,
            ),
            _buildRecentProductsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProductsSection() {
    if (_isLoading) {
      return _buildShimmerEffect();
    }

    if (_recommendedProducts.isEmpty) {
      return _buildNoRecommendationsWidget();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Products',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _recommendedProducts.length,
            itemBuilder: (context, index) {
              final product = _recommendedProducts[index];
              return ProductCard(product: product);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              elevation: 2,
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.white,
                ),
                title: Container(
                  width: double.infinity,
                  height: 10.0,
                  color: Colors.white,
                ),
                subtitle: Container(
                  width: double.infinity,
                  height: 10.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoRecommendationsWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No recommended products found.',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
