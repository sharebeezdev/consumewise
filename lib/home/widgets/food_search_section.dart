import 'package:flutter/material.dart';

class FoodSearchSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Food Search',
          //   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          //         fontWeight: FontWeight.bold,
          //       ),
          // ),
          // SizedBox(height: 10),
          Card(
            elevation: 1, // Material 3 card
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search for food products...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          //   SizedBox(height: 20),
          //   Center(
          //     child: Column(
          //       children: [
          //         Text(
          //           'Scan, Learn, Choose Healthier',
          //           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //         ),
          //         SizedBox(height: 8),
          //         Text(
          //           'Scan the product to learn about your food!',
          //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //                 color: Colors.grey,
          //               ),
          //         ),
          //         SizedBox(height: 20),
          //         Icon(Icons.qr_code_2, size: 64, color: Colors.blueAccent),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }
}
