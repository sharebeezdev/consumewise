import 'package:flutter/material.dart';

class RecentProductsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductItem(
            context, // Pass context here
            'Organic Granola',
            'Calories: 200 per serving',
            'https://via.placeholder.com/120',
          ),
          const SizedBox(height: 10),
          _buildProductItem(
            context, // Pass context here
            'Vegan Protein Bar',
            'Calories: 150 per serving',
            'https://via.placeholder.com/120',
          ),
        ],
      ),
    );
  }

  // Pass context as a parameter to this method
  Widget _buildProductItem(
      BuildContext context, String title, String subtitle, String imageUrl) {
    return Card(
      color: Colors.white,
      elevation: 2, // Material You elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.network(imageUrl, width: 64, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
