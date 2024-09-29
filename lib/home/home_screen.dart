import 'package:flutter/material.dart';
import 'widgets/food_search_section.dart';
import 'widgets/featured_product_section.dart';
import 'widgets/recent_products_section.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('ConsumeWise',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoodSearchSection(),
            FeaturedProductSection(),
            RecentProductsSection(),
          ],
        ),
      ),
    );
  }
}
