import 'package:flutter/material.dart';
import 'menu.dart';
import 'user_type.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/background.jpg', 
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Logo image at the top
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                  ),
                  
                  SizedBox(height: 32), //Space between logo and business id
                  // Business ID Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Business ID',
                      prefixIcon: Icon(Icons.business),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Business Name Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Business Name',
                      prefixIcon: Icon(Icons.business_center),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // User ID Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'User ID',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Password Field
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Signup Button
                  ElevatedButton(
                      onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage(userType: UserType.Manager)),
                    );
                  },
                    child: Text('Sign up'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
