import 'package:flutter/material.dart';
import 'widgets/food_search_section.dart';
import 'widgets/featured_product_section.dart';
import 'widgets/recent_products_section.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onRefreshProducts; // Add this callback

  HomeScreen({required this.onRefreshProducts});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FeaturedProductSectionState> _featuredProductKey =
      GlobalKey<FeaturedProductSectionState>();

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // This ensures the products are refreshed when the callback is triggered
    widget.onRefreshProducts();
  }

  @override
  void initState() {
    super.initState();
    widget
        .onRefreshProducts(); // Trigger refresh when the screen is initialized or revisited
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ConsumeWise'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoodSearchSection(),
            FeaturedProductSection(
              key: _featuredProductKey,
            ),
            RecentProductsSection(),
          ],
        ),
      ),
    );
  }
}
