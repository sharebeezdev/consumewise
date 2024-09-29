import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'widgets/loading_screen.dart'; // For camera integration

// Add this for shimmer effect

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  CameraDescription? _selectedCamera;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _selectedCamera = _cameras.first;
      _cameraController =
          CameraController(_selectedCamera!, ResolutionPreset.medium);

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Future<void> _captureAndAnalyzeImage() async {
  //   // Emulator testing: Load image from assets
  //   final ByteData byteData = await rootBundle.load('assets/images/bingo.jpg');
  //   final Uint8List imageBytes = byteData.buffer.asUint8List();

  //   // Save the asset image to a temporary file so it can be used like a camera-captured image
  //   final Directory tempDir = await getTemporaryDirectory();
  //   final File imageFile = File('${tempDir.path}/temp_image.jpg');
  //   await imageFile.writeAsBytes(imageBytes);

  //   // Navigate to the LoadingScreen with the asset image file
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => LoadingScreen(imageFile: imageFile),
  //     ),
  //   );
  //   return;
  // }

//NEED TO UNCOMMENT BERLOW CODE AS CAMERA NOT WORKING IN EMULATOR ADDED AABOVE CODE
  // Capture image using camera
  Future<void> _captureAndAnalyzeImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    // Capture image
    final image = await _cameraController!.takePicture();
    final File imageFile = File(image.path);

    // Navigate to the LoadingScreen with imageFile to analyze
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(imageFile: imageFile),
      ),
    );
  }

  // Overlay scan area with Google Lens-like design
  Widget _buildScanOverlay() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5), // Translucent overlay
          ),
        ),
        Center(
          child: Container(
            width: 250, // Width of the scan area
            height: 250, // Height of the scan area
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Scan Product', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera Preview
          CameraPreview(_cameraController!),
          _buildScanOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "scanButton",
        // Assign a unique heroTag
        onPressed: _captureAndAnalyzeImage,
        icon: Icon(Icons.camera_alt, color: Colors.white),
        label: Text(
          'Scan & Analyze',
          style:
              TextStyle(color: Colors.white), // Setting the text color to white
        ),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// class ScanScreen extends StatefulWidget {
//   @override
//   _ScanScreenState createState() => _ScanScreenState();
// }

// class _ScanScreenState extends State<ScanScreen> {
//   CameraController? _cameraController;
//   bool _isLoading = false;
//   String _apiResponse = '';
//   late List<CameraDescription> _cameras;
//   CameraDescription? _selectedCamera;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   // Initialize the camera
//   Future<void> _initializeCamera() async {
//     _cameras = await availableCameras();
//     if (_cameras.isNotEmpty) {
//       _selectedCamera = _cameras.first;
//       _cameraController =
//           CameraController(_selectedCamera!, ResolutionPreset.medium);

//       await _cameraController!.initialize();
//       if (!mounted) return;
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

// // Capture image using camera
//   Future<void> _captureAndAnalyzeImage() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return;
//     }

//     // Capture image
//     final image = await _cameraController!.takePicture();
//     final File imageFile = File(image.path);

//     setState(() {
//       _isLoading = true;
//     });

//     await _callAnalyzeAPI(imageFile);
//   }

//   // Temporary method to use asset image for analysis
//   Future<void> _useAssetImageForAnalysis() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       // Load the asset image as byte data
//       final byteData = await rootBundle.load('assets/images/bingo.jpg');

//       // Write the byte data to a temporary file
//       final tempDir = await getTemporaryDirectory();
//       final tempFile = File('${tempDir.path}/bingo.jpg');
//       await tempFile.writeAsBytes(byteData.buffer.asUint8List());
//       print('calling api');
//       // Call the API with the temp image file
//       await _callAnalyzeAPI(tempFile);
//     } catch (e) {
//       setState(() {
//         _apiResponse = 'Error: Could not analyze the asset image';
//         _isLoading = false;
//       });
//     }
//   }

//   // Call the API to analyze the image (Asset or Camera image)
//   Future<void> _callAnalyzeAPI(File imageFile) async {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse(
//           'https://google-gemini-api-v2-837715105352.us-central1.run.app/analyze'),
//     );
//     request.files
//         .add(await http.MultipartFile.fromPath('image', imageFile.path));

//     var response = await request.send();
//     final respStr = await response.stream.bytesToString();

//     print('Full API response:');
//     print(respStr); // Log the entire response for debugging

//     if (response.statusCode == 200) {
//       try {
//         // Sanitize the response: Remove backticks and `json` prefix if present
//         String cleanedResponse =
//             respStr.replaceAll('```json', '').replaceAll('```', '').trim();
//         print('Cleaned API response:');
//         print(cleanedResponse);

//         // Try parsing the sanitized response JSON
//         setState(() {
//           _apiResponse = cleanedResponse;
//           _isLoading = false;
//         });

//         // Navigate to IngredientListScreen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 IngredientListScreen(apiResponse: _apiResponse),
//           ),
//         );
//       } catch (e) {
//         // If there's an error parsing the JSON, show an error message
//         print('Error parsing JSON: $e');
//         setState(() {
//           _apiResponse =
//               'Error: Invalid or incomplete data received from the API.';
//           _isLoading = false;
//         });
//       }
//     } else {
//       print('Invalid response code from Gemini API');
//       setState(() {
//         _apiResponse = 'Error: Could not analyze the image';
//         _isLoading = false;
//       });
//     }
//   }

//   // Animated text while loading
//   Widget _loadingText() {
//     List<String> loadingQuotes = [
//       "Let Gemini analyze and help you consume only the best!",
//       "Patience is key to making better choices!",
//       "Waiting for the best results... just for you.",
//     ];

//     return AnimatedText(loadingQuotes); // Use the AnimatedText widget
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return Center(
//           child:
//               CircularProgressIndicator()); // Display while camera initializes
//     }
//     return Scaffold(
//       appBar: AppBar(title: Text('Scan Product')),
//       body: Column(
//         children: [
//           // Placeholder for camera preview (this is skipped since we're using asset image)
//           Expanded(
//             flex: 7,
//             child: Container(
//               color: Colors.grey[200],
//               child: Center(
//                 child: Text(
//                   'Using Asset Image for Analysis',
//                   style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                 ),
//               ),
//             ),
//           ),
//           // Material You Button and loading view - 30% of screen height
//           Expanded(
//             flex: 3,
//             child: _isLoading
//                 ? Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(height: 20),
//                       _loadingText(), // Show animated text while waiting
//                     ],
//                   )
//                 : Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: ElevatedButton(
//                       onPressed:
//                           _useAssetImageForAnalysis, // Use asset image for testing
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(
//                             vertical: 16), // Material You style button
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                               24.0), // Pixel UI rounded button
//                         ),
//                         textStyle: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.image_search),
//                           SizedBox(width: 10),
//                           Text('Scan & Analyze'),
//                         ],
//                       ),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
