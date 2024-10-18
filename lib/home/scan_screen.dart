import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/loading_screen.dart';

class ScanScreen extends StatefulWidget {
  final VoidCallback onBackToHome;

  ScanScreen({required this.onBackToHome});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  CameraDescription? _selectedCamera;
  bool _isFlashOn = false; // Flash control
  bool _isFocusLocked = false; // Focus control

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _selectedCamera = _cameras.first;
      _cameraController = CameraController(
        _selectedCamera!,
        ResolutionPreset
            .max, // Maximize the resolution for higher image quality
        imageFormatGroup: ImageFormatGroup.jpeg, // Ensure high-quality image
      );

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

  Future<void> _captureAndAnalyzeImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final File imageFile = File(image.path);

      // Navigate to LoadingScreen with imageFile and listen for result
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(imageFile: imageFile),
        ),
      );

      // If result is true (data added), notify HomeScreen and go back
      if (result == true) {
        widget.onBackToHome();
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);

      // Navigate to LoadingScreen with the selected image file
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(imageFile: imageFile),
        ),
      );

      if (result == true) {
        widget.onBackToHome();
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    setState(() {
      _isFlashOn = !_isFlashOn;
    });

    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  void _handleTapFocus(TapDownDetails details, BoxConstraints constraints) {
    if (_cameraController == null) return;

    final offset = details.localPosition;

    _cameraController!.setFocusMode(FocusMode.auto);
    _cameraController!.setFocusPoint(
      Offset(
        offset.dx / constraints.maxWidth,
        offset.dy / constraints.maxHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTapDown: (details) {
          if (!_isFocusLocked) {
            _handleTapFocus(details, BoxConstraints());
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            ),
            _buildScanOverlay(),
            _buildCustomTitleBar(),
            _buildFlashControl(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              heroTag: "scanButton",
              onPressed: _captureAndAnalyzeImage,
              icon: Icon(Icons.camera_alt),
              label: Text('Scan'),
              backgroundColor: Colors.blue,
            ),
            FloatingActionButton.extended(
              heroTag: "uploadButton",
              onPressed: _pickImageFromGallery,
              icon: Icon(Icons.photo_library),
              label: Text('Upload'),
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCustomTitleBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                widget.onBackToHome();
              },
              child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
            ),
            SizedBox(width: 16),
            Text(
              "Product Scanner",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildFlashControl() {
    return Positioned(
      top: 40,
      right: 16,
      child: GestureDetector(
        onTap: _toggleFlash,
        child: Icon(
          _isFlashOn ? Icons.flash_on : Icons.flash_off,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
