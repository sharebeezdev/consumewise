import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // To get temp directory
import 'dart:convert';
// Assuming this exists already for IngredientListScreen
import 'package:shimmer/shimmer.dart';

import '../../datamodel/utils/database_helper.dart';
import '../../util/common_utils.dart';
import 'ingrediants_list.dart';

class LoadingScreen extends StatefulWidget {
  final File imageFile;

  LoadingScreen({required this.imageFile});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _apiResponse = '';

  @override
  void initState() {
    super.initState();
    _callAnalyzeAPI();
  }

  Future<void> _callAnalyzeAPI() async {
    try {
      // Fetch the profile data from the SQLite database
      final profileData = await DatabaseHelper.fetchProfile();
      String personalInfoJson =
          profileData != null ? jsonEncode(profileData) : '{}';

      // Create the multipart request for the API
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://google-gemini-api-v2-837715105352.us-central1.run.app/analyze'),
      );

      // Add the image file to the request
      request.files.add(
          await http.MultipartFile.fromPath('image', widget.imageFile.path));

      // Add the personalInfo JSON string as a field in the request
      request.fields['personalInfo'] = personalInfoJson;

      // Send the request to the API
      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        String cleanedResponse =
            respStr.replaceAll('```json', '').replaceAll('```', '').trim();
        setState(() {
          _apiResponse = cleanedResponse;
        });

        // Generate the unique ID for the scanned product image
        final Uint8List imageBytes = await widget.imageFile.readAsBytes();
        String uniqueId = generateImageHash(imageBytes);

        // Asynchronously store the scanned product image and response in the database
        _storeScannedProductInDB(
            widget.imageFile.path, cleanedResponse, uniqueId);

        // Navigate to the IngredientListScreen with the API response
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                IngredientListScreen(apiResponse: _apiResponse),
          ),
        );
      } else {
        _showErrorSnackbar();
      }
    } catch (e) {
      _showErrorSnackbar();
    }
  }

  Future<void> _storeScannedProductInDB(
      String imagePath, String apiResponse, String uniqueId) async {
    // Check if the product has been scanned before
    final existingProduct =
        await DatabaseHelper.fetchScannedProductById(uniqueId);

    if (existingProduct == null) {
      // If the product hasn't been scanned, insert it into the database
      await DatabaseHelper.insertScannedProduct({
        'uniqueId': uniqueId,
        'imagePath': imagePath,
        'apiResponse': apiResponse,
        'creationDate': DateTime.now().toUtc().toIso8601String(),
        'lastUpdateDate': DateTime.now().toUtc().toIso8601String(),
        'createdBy': 'ConsumeWise' // Default createdBy
      });
      print('Product stored in the database.');
    } else {
      print('Product already exists in the database.');
      // Optionally, you can show a suggestion that the product has already been scanned
      _showSimilarProductSnackbar();
    }
  }

  void _showSimilarProductSnackbar() {
    final snackBar = SnackBar(
      content: Text('You have scanned a similar product before.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Show error snackbar if API fails
  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Unable to process your request. This might be due to a scanned image issue or network error.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _callAnalyzeAPI, // Retry API call
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loadingAnimation(), // Show shimmer animation and text
      ),
    );
  }

  // Shimmer and animated text while loading
  Widget _loadingAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 200,
            height: 200,
            color: Colors.grey[300], // Placeholder shimmer rectangle
          ),
        ),
        SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.blueAccent,
          child: Text(
            'Processing your request...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
