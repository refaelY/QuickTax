import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'user_type.dart';
import 'dart:io';
import 'receipt_history.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';



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
  late FlutterTesseractOcr _tesseractOcr;


  TextEditingController storeController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _tesseractOcr = FlutterTesseractOcr();

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
      final imagePath = image.path;

      await _processImage(imagePath);

      setState(() {
        _capturedImage = File(imagePath);
        _showCameraPreview = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error capturing photo: $e'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _importFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      final imagePath = image!.path;

      await _processImage(imagePath);

      setState(() {
        _capturedImage = File(imagePath);
        _showCameraPreview = false;
      });
    } catch (e) {
      print('Error importing photo: $e');
    }
  }

 Future<void> _processImage(String imagePath) async {
    final extractedText = await FlutterTesseractOcr.extractText(imagePath, language: 'eng');

    // Implement text parsing to extract purchase date, purchase volume, and store name
    String purchaseDate = "";
    double purchaseVolume = 0.0;
    String storeName = "";

    // Example regular expressions (you'll need to adjust these based on your receipt format)
    final datePattern = RegExp(r'\d{2}/\d{2}/\d{4}');
    final volumePattern = RegExp(r'\d+(\.\d+)?\s*(L|l|G|g|KG|kg)');
    final storePattern = RegExp(r'Store: (.+)');

    final dateMatch = datePattern.firstMatch(extractedText);
    if (dateMatch != null) {
      purchaseDate = dateMatch.group(0)!;
    }

    final volumeMatch = volumePattern.firstMatch(extractedText);
    if (volumeMatch != null) {
      purchaseVolume = double.parse(volumeMatch.group(0) ?? '0');
    }

    final storeMatch = storePattern.firstMatch(extractedText);
    if (storeMatch != null) {
      storeName = storeMatch.group(1)!;
    }

    // Update the text controllers with extracted information
    storeController.text = storeName;
    amountController.text = purchaseVolume.toString();
    dateController.text = purchaseDate;

    // Show extracted information using a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Extracted Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: storeController,
                decoration: const InputDecoration(labelText: 'Store Name'),
              ),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                // Implement your update logic here
                // You can access edited values using storeController.text, amountController.text, dateController.text
                
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
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
              const SizedBox(height: 50),
              // "Scan" Text
              const Text(
                'Scan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 32),
              if (_capturedImage != null) ...[
                // Display the captured/uploaded image
                Expanded(
                  child: Center(
                    child: Image.file(_capturedImage!),
                  ),
                ),
                const SizedBox(height: 16),
                // Buttons to save and retake photo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _savePhoto,
                      child: const Text('Save'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _retakePhoto,
                      child: const Text('Retake'),
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
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Buttons for taking a photo and importing a photo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _takePhoto,
                      child: const Text('Take a Picture'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _importFromGallery,
                      child: const Text('Import from Gallery'),
                    ),
                  ],
                ),
              ] else ...[
                // Processed Image (after taking or importing) - No photo captured
                const Expanded(
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Receipt History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Profile Settings',
          ),
          if (widget.userType == UserType.Manager) // Show this item only for managers
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              label: 'Additional User',
            ),
        ],
      ),
    );
  }
}
