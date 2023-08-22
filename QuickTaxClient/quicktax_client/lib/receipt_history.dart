import 'package:flutter/material.dart';
import 'package:quicktax_client/add_employee.dart';
import 'user_type.dart';
import 'camera.dart';
import 'add_employee.dart';

class ReceiptHistoryScreen extends StatefulWidget {
  final UserType userType;

  const ReceiptHistoryScreen({required this.userType});

  // ignore: library_private_types_in_public_api
  _ReceiptHistoryScreen createState() => _ReceiptHistoryScreen();
}

class _ReceiptHistoryScreen extends State<ReceiptHistoryScreen>
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Make the app bar transparent
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.transparent, // Make the app bar transparent
          elevation: 0, // Remove the shadow under the app bar
          title:                   // "Receipt History" Text
            const Text(
              'Receipt History',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ), 
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background2.jpg', // Replace this with the path to your background image asset.
              fit: BoxFit.cover,
            ),
          ),
          // Transparent Logo at the Center
          Center(
            child: Opacity(
              opacity: 0.6, // Set the desired transparency value here (0.0 to 1.0)
              child: Image.asset(
                'assets/images/logo.png', // Replace with your logo image path
                height: 200, // Adjust the height as needed
              ),
            ),
          ),
          // Content Layout with Padding and Rounded Edges
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 150.0, bottom: 70.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5), // White background with strong transparency
                borderRadius: BorderRadius.circular(16.0), // Rounded edges
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Receipt List with Expanded widget
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5, // Replace this with the actual number of receipts
                      itemBuilder: (context, index) {
                        // Replace the placeholder data with actual receipt information
                        final receiptImage = 'assets/images/receipt.jpeg';
                        final placeOfPurchase = 'Store $index';
                        final amount = '\$$index.00';
                        final dateOfPurchase = 'Date $index';

                        return ListTile(
                          leading: Image.asset(receiptImage),
                          title: Text(placeOfPurchase),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amount: $amount'),
                              Text('Date: $dateOfPurchase'),
                            ],
                          ),
                          onTap: () {
                            // Handle the tap on a receipt item here
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Index 1 corresponds to Receipt History
        onTap: (index) {
          // Define the logic for handling navigation when the user taps on each item
          // index 0: Scan, index 1: Receipt History, index 2: Profile Settings
          switch (index) {
            case 0:
              // Navigate to the Scan screen
              Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanScreen(userType: widget.userType),
                      ),
                    );
              break;
            case 2:
              // Navigate to the Profile Settings screen
              break;
            case 3:
              if (widget.userType.type == UserTypeValue.Manager) {
                // Navigate to the Additional User screen
                Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEmployeePage(userType: widget.userType),
                      ),
                    );
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
          if (widget.userType.type == UserTypeValue.Manager) // Show this item only for managers
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              label: 'Additional User',
            ),
        ],
      ),
    );
  }
}
