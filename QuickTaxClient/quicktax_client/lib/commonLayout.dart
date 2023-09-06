import 'dart:convert';
import 'dart:io';
import 'package:quicktax_client/add_employee.dart';

import 'Communicator.dart';

import 'package:flutter/material.dart';
import 'user_type.dart'; 
import 'camera.dart';
import 'receipt_history.dart';
import 'receipt_history_manager.dart';


class CommonLayout extends StatelessWidget {
  final Widget body;
  final UserType userType;

  CommonLayout({required this.body, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Receipt History',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/images/logo.png',
                height: 400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 150.0, bottom: 70.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: body,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Define the logic for handling navigation when the user taps on each item
          // index 0: Scan, index 1: Receipt History, index 2: Profile Settings
          switch (index) {
            case 1:
              Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanScreen(userType: userType),
                      ),
                    );
              break;

            case 2:
              break;

            case 3:
             if (userType.type == UserTypeValue.Manager) {
                // Navigate to the Additional User screen
                Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEmployeePage(userType: userType),
                      ),
                    );
              }
              break;

          }
        },
        selectedItemColor: Colors.blue, // Set your custom color for selected item here
        unselectedItemColor: Colors.grey,
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
          if (userType.type == UserTypeValue.Manager)
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_add),
              label: 'Additional User',
            ),
        ],
      ),
    );
  }
}
