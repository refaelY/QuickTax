import 'package:flutter/material.dart';
import 'signup.dart';
import 'menu.dart';
import 'user_type.dart';

void main() {
  runApp(QuickTax());
}

class QuickTax extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
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
                  
                  SizedBox(height: 32), //Space between logo and username
                  // Username Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Username',
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
                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage(userType: UserType.Employee)),
                    );
                  },
                  child: Text('Login'),
                  ),
                  SizedBox(height: 8),
                  // Signup Button
                  TextButton(
                    onPressed: () {
                    // Navigate to the SignupPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
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