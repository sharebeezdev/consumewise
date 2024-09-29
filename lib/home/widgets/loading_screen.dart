import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      final profileData = await DatabaseHelper.fetchProfile();
      String personalInfoJson =
          profileData != null ? jsonEncode(profileData) : '{}';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://google-gemini-api-v2-837715105352.us-central1.run.app/analyze'),
      );
      request.files.add(
          await http.MultipartFile.fromPath('image', widget.imageFile.path));
      request.fields['personalInfo'] = personalInfoJson;

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        String cleanedResponse =
            respStr.replaceAll('```json', '').replaceAll('```', '').trim();
        setState(() {
          _apiResponse = cleanedResponse;
        });

        final Uint8List imageBytes = await widget.imageFile.readAsBytes();
        String uniqueId = generateImageHash(imageBytes);

        // Store product in database
        await _storeScannedProductInDB(
            widget.imageFile.path, cleanedResponse, uniqueId);

        // Navigate to Ingredients List Screen
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
    final existingProduct =
        await DatabaseHelper.fetchScannedProductById(uniqueId);

    if (existingProduct == null) {
      await DatabaseHelper.insertScannedProduct({
        'uniqueId': uniqueId,
        'imagePath': imagePath,
        'apiResponse': apiResponse,
        'creationDate': DateTime.now().toUtc().toIso8601String(),
        'lastUpdateDate': DateTime.now().toUtc().toIso8601String(),
        'createdBy': 'ConsumeWise'
      });
    } else {
      _showSimilarProductSnackbar();
    }
  }

  void _showSimilarProductSnackbar() {
    final snackBar = SnackBar(
      content: Text('You have scanned a similar product before.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Unable to process your request. This might be due to a scanned image issue or network error.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _callAnalyzeAPI,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loadingAnimation(),
      ),
    );
  }

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
            color: Colors.grey[300],
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
