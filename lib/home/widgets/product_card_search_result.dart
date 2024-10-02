import 'package:flutter/material.dart';
import 'dart:math';

class ProductCard extends StatefulWidget {
  final dynamic product;
  final bool initiallyExpanded;

  const ProductCard({
    Key? key,
    required this.product,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  Color _getRandomLightColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      200 + random.nextInt(55),
      200 + random.nextInt(55),
      200 + random.nextInt(55),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.all(8.0),
                    child: Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.broken_image),
                    ),
                  ),
                  // Right side: Product details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 4),
                          Text('Category: ${product['category']}'),
                          Text('Type: ${product['type']}'),
                          Text('Ingredients: ${product['ingredients']}'),
                          Text('Brand: ${product['brand']}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Stats icons below the image (basic stats)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCompactStatCard(Icons.local_fire_department,
                        'Calories', product['calories'], 'kcal'),
                    _buildCompactStatCard(
                        Icons.cake, 'Sugar', product['sugar'], 'g'),
                    _buildCompactStatCard(
                        Icons.fastfood, 'Fat', product['fat'], 'g'),
                    _buildCompactStatCard(Icons.fitness_center, 'Protein',
                        product['protein'], 'g'),
                  ],
                ),
              ),
              // Expanded content with all stats
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCompactStatCard(
                              Icons.spa, 'Fiber', product['fiber'], 'g'),
                          _buildCompactStatCard(
                              Icons.opacity, 'Sodium', product['sodium'], 'mg'),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Additional stats can go here if needed
                    ],
                  ),
                ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(_isExpanded ? 'Show Less' : 'Show More'),
              ),
            ],
          ),
        ),
        // Eco-friendly badge at the top-right corner of the card
        if (product['is_eco_friendly'])
          Positioned(
            top: 8,
            right: 8,
            child: Icon(Icons.eco, color: Colors.green, size: 24),
          ),
      ],
    );
  }

  // Compact stat card with icon on top and reduced height
  Widget _buildCompactStatCard(
      IconData icon, String title, dynamic value, String unit) {
    return Expanded(
      child: Card(
        elevation: 2,
        color: _getRandomLightColor(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  icon,
                  color: Colors.black54,
                  size: 18,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  final List<dynamic> products;

  const ProductListScreen({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          initiallyExpanded:
              index == 0, // The first card will be expanded by default
        );
      },
    );
  }
}
