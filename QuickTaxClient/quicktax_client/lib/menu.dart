import 'package:flutter/material.dart';
import 'camera.dart';
import 'profile_setting.dart';
import 'receipt_history.dart';
import 'add_employee.dart';
import 'user_type.dart';


class MenuPage extends StatefulWidget {
  final UserType userType;

  MenuPage({required this.userType});

  @override
  // ignore: library_private_types_in_public_api
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/background2.jpg', 
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
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
          // Rest of the Content
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                // Replace the PlaceholderWidgets with your actual screens/pages for each button action
                PlaceholderWidget(
                  'Receipt History',
                  Icons.history,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptHistoryScreen(userType: widget.userType),
                      ),
                    );
                  },
                ),
                PlaceholderWidget(
                  'Scan',
                  Icons.camera_alt,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanScreen(userType: widget.userType),
                      ),
                    );
                  },
                ),
                PlaceholderWidget(
                  'Profile Settings',
                  Icons.settings,
                  () {
                    // Handle navigation here for Profile Settings
                  },
                ),
                if (widget.userType.type == UserTypeValue.Manager)
                  PlaceholderWidget(
                    'Additional User',
                    Icons.person_add,
                    () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEmployeePage(userType: widget.userType),
                      ),
                    );
                    },
                  ),
              ],
            ),
          ),
          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.animateToPage(
                    _currentIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              },
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Receipt History',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt),
                  label: 'Scan',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Profile Settings',
                ),
                if (widget.userType.type == UserTypeValue.Manager)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_add),
                    label: 'Additional User',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class PlaceholderWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed; // Added this callback parameter

  PlaceholderWidget(this.title, this.icon, this.onPressed); // Updated constructor

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Wrap with GestureDetector to handle tap
      onTap: onPressed, // Call the provided onPressed function when tapped
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}