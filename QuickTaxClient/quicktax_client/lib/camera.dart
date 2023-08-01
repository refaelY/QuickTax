import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'user_type.dart';
import 'dart:io';
import 'receipt_history.dart';

class ScanScreen extends StatefulWidget {
  final UserType userType;

  const ScanScreen({required this.userType});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;
  bool _showCameraPreview = true;
  int _currentIndex = 0;
  File? _capturedImage; // Variable to store the taken/uploaded image

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeCameraControllerFuture = _cameraController.initialize();

    setState(() {});
  }

  Future<void> _takePhoto() async {
    try {
      final image = await _cameraController.takePicture();
      setState(() {
        _capturedImage = File(image.path); // Store the taken photo
        _showCameraPreview = false; // Hide camera preview after taking photo
      });
    } catch (e) {
      print('Error capturing photo: $e');
    }
  }

  Future<void> _importFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        _capturedImage = File(image!.path); // Store the selected image
        _showCameraPreview = false; // Hide camera preview after importing photo
      });
    } catch (e) {
      print('Error importing photo: $e');
    }
  }

  void _savePhoto() {
    // Implement logic to save the photo (e.g., save it to storage)
    // After saving, you can show a confirmation message to the user if needed
  }

  void _retakePhoto() {
    // Implement logic to retake the photo
    setState(() {
      _capturedImage = null;
      _showCameraPreview = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color as white or any desired color.
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background2.jpg', // Replace this with the path to your background image asset.
              fit: BoxFit.cover,
            ),
          ),
          // Content Layout
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              // "Scan" Text
              Text(
                'Scan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 32),
              if (_capturedImage != null) ...[
                // Display the captured/uploaded image
                Expanded(
                  child: Center(
                    child: Image.file(_capturedImage!),
                  ),
                ),
                SizedBox(height: 16),
                // Buttons to save and retake photo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _savePhoto,
                      child: Text('Save'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _retakePhoto,
                      child: Text('Retake'),
                    ),
                  ],
                ),
              ] else if (_showCameraPreview) ...[
                // Camera Preview
                FutureBuilder<void>(
                  future: _initializeCameraControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Expanded(
                        child: Center(
                          child: CameraPreview(_cameraController),
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                SizedBox(height: 16),
                // Buttons for taking a photo and importing a photo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _takePhoto,
                      child: Text('Take a Picture'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _importFromGallery,
                      child: Text('Import from Gallery'),
                    ),
                  ],
                ),
              ] else ...[
                // Processed Image (after taking or importing) - No photo captured
                Expanded(
                  child: Center(
                    child: Text(
                      'Image Preview',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Define the logic for handling navigation when the user taps on each item
          // index 0: Scan, index 1: Receipt History, index 2: Profile Settings
          switch (index) {
            case 1:
              // Navigate to the Receipt History
              Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptHistoryScreen(userType: widget.userType),
                      ),
                    );
              break;
            case 2:
              // Navigate to the Profile Settings screen
              break;
            case 3:
              if (widget.userType == UserType.Manager) {
                // Navigate to the Additional User screen
              }
              break;
            // Add more cases if you have additional tabs
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Receipt History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Profile Settings',
          ),
          if (widget.userType == UserType.Manager) // Show this item only for managers
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              label: 'Additional User',
            ),
        ],
      ),
    );
  }
}
