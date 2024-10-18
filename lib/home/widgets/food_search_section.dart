import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../datamodel/utils/database_helper.dart';
import '../../util/config_util.dart';
import 'search_results_page.dart';

class FoodSearchSection extends StatefulWidget {
  @override
  _FoodSearchSectionState createState() => _FoodSearchSectionState();
}

class _FoodSearchSectionState extends State<FoodSearchSection> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchPageOpened = false; // Track if SearchResultsPage is open

  Future<void> _searchProducts(BuildContext context) async {
    final String query = _searchController.text.trim();

    // If the search query is empty, don't proceed
    if (query.isEmpty) {
      return;
    }

    // If the SearchResultsPage is not opened, open it for the first time
    if (!_isSearchPageOpened) {
      _isSearchPageOpened = true;

      // Navigate to SearchResultsPage with shimmer loading effect
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(
            query: query,
            searchResults: [], // Empty list initially for shimmer effect
            isLoading: true, // Show shimmer effect initially
            searchController: _searchController,
            searchFunction: () =>
                _searchProducts(context), // Pass the search function
          ),
        ),
      );
    }

    // Fetch profile data for the request
    final profileData = await DatabaseHelper.fetchProfile();
    String personalInfoJson = profileData != null
        ? jsonEncode(profileData)
        : jsonEncode({
            "dietPreference": "",
            "allergies": "",
            "medicalCondition": "",
            "nutritionalGoal": "",
            "environmentallyConscious": false
          });

    try {
      final response = await http.post(
        Uri.parse(
            'https://google-gemini-api-v2-837715105352.us-central1.run.app/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'personalInfo': jsonDecode(personalInfoJson),
        }),
      );

      if (response.statusCode == 200) {
        final searchResults = jsonDecode(response.body);

        // Safely replace the current SearchResultsPage with new search results
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(
              query: query,
              searchResults: searchResults, // Pass the actual search results
              isLoading: false, // Disable shimmer effect
              searchController: _searchController,
              searchFunction: () => _searchProducts(context),
            ),
          ),
        );
      } else {
        // Handle the case where the API call fails
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(
              query: query,
              searchResults: [], // Empty list if no results found
              isLoading: false, // Disable shimmer
              searchController: _searchController,
              searchFunction: () => _searchProducts(context),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(
            query: query,
            searchResults: [], // No results due to error
            isLoading: false, // Disable shimmer
            searchController: _searchController,
            searchFunction: () => _searchProducts(context),
          ),
        ),
      );
    }
  }

  void _clearSearchText() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3), // changes the shadow position
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Colors.greenAccent.shade100,
                  Colors.lightGreen.shade200,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for food products...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.green.shade700,
                      size: 28, // Slightly larger icon for modern feel
                    ),
                    onPressed: () {
                      _searchProducts(context); // Call the search function
                    },
                  ),
                  prefixIcon: IconButton(
                    icon: Icon(
                      Icons.clear_all,
                      size: 24,
                    ),
                    onPressed: _clearSearchText, // Clear the search text
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
