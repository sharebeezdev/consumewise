import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'bottom_nav.dart';
import 'product_card_search_result.dart';

class SearchResultsPage extends StatelessWidget {
  final List<dynamic> searchResults;
  final TextEditingController searchController;
  final Function searchFunction;
  final String query;
  final bool isLoading; // Added to track the loading state

  SearchResultsPage({
    required this.query,
    required this.searchResults,
    required this.searchController,
    required this.searchFunction,
    required this.isLoading, // Pass the loading state
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Colors.transparent, // Transparent background for modern look
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.greenAccent.shade100, Colors.lightGreen.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 3), // Shadow effect for app bar
              ),
            ],
          ),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search for food products...',
              hintStyle: TextStyle(
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              // suffixIcon: Icon(Icons.search, color: Colors.green.shade700),
            ),
            onSubmitted: (value) {
              searchFunction();
            },
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green.shade700),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // Safely pop the current route
            } else {
              // If there's nothing to pop, navigate back to the main page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BottomNav(), // Replace with your main page widget
                ),
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.green.shade700),
            onPressed: () {
              searchFunction();
            },
          ),
        ],
      ),
      body: isLoading
          ? _buildShimmerEffect() // Show shimmer while loading
          : searchResults.isEmpty
              ? _buildEmptyResults() // Show empty results if no data
              : _buildSearchResults(), // Show actual results if available
    );
  }

  // Function to display shimmer effect while loading
  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 6, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 2.0,
              child: ListTile(
                leading: Container(
                  width: 60.0,
                  height: 60.0,
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

  // Function to build search results
  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final product = searchResults[index];
        return ProductCard(product: product);
      },
    );
  }

  // Function to show a modern empty results widget
  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Try adjusting your search terms or check back later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
