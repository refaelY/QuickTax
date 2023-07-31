import 'package:flutter/material.dart';

enum UserType { Employee, Manager }

class MenuPage extends StatelessWidget {
  final UserType userType;

  MenuPage({required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/background.jpg', // Replace with your background image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Logo at the Top
          Positioned(
            top: 32,
            left: 16,
            right: 16,
            child: Image.asset(
              'assets/images/logo.png', // Replace with your logo image path
              height: 100, // Adjust height as needed
            ),
          ),
          // Buttons and Widgets
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle scan photo button press
                    // Add your scan photo logic here
                  },
                  child: Text('Scan Photo'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle receipt history button press
                    // Add your receipt history logic here
                  },
                  child: Text('Receipt History'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle profile settings button press
                    // Add your profile settings logic here
                  },
                  child: Text('Profile Settings'),
                ),
                if (userType == UserType.Manager) ...[
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Handle add employee button press
                      // Add your add employee logic here
                    },
                    child: Text('Add Employee'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
