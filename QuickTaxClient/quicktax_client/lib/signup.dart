import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'menu.dart';
import 'user_type.dart';
import 'dart:io';



class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}



class _SignupPageState extends State<SignupPage>  {
  final _businessIdController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String businessId = '';
  String businessName = '';
  String username = '';
  String password = '';


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
                    controller: _businessIdController,
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
                    controller: _businessNameController,
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
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'User Name',
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
                    controller: _passwordController,
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
                    onPressed: () async {
                      businessId = _businessIdController.text;
                      businessName = _businessNameController.text;
                      username = _usernameController.text;
                      password = _passwordController.text;

                      final response = await sendRequestToServer();
                      final responseCode = response["responseCode"];
                      final responseMessage = response["responseMessage"];

                      if (responseCode == 404)
                      {
                        Map<String, String> errMsg = Map<String, String>.from(json.decode(responseMessage));
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: Text(errMsg['_message']!),
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
                      else if(responseCode == 201)
                      {
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MenuPage(userType: UserType.Manager)),
                        );
                      }
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

  Future<Map<String, dynamic>> sendRequestToServer() async 
  {
    final completer = Completer<Map<String, dynamic>>();

    String registrationDate = '';
    int? responseCode;
    String? responseMessage;

    final client = await Socket.connect('192.168.1.133', 5555);

    final requestData = BusinessRegistrationRequest(
      businessId: int.parse(businessId),
      businessName: businessName,
      username: username,
      password: password,
      registrationDate: registrationDate,
    );

    String msg = "101" + jsonEncode(requestData.toJson()).length.toString().padLeft(4, '0') + jsonEncode(requestData.toJson());    
    client.write(msg);

    // Create a List<int> buffer to store the response data
    final responseBuffer = <int>[];

    // Listen to the socket and collect response data
    await client.listen((data) {
      responseBuffer.addAll(data);
      
      // Check if the response is complete (at least 7 bytes)
      if (responseBuffer.length >= 7) {
        responseCode = int.parse(String.fromCharCodes(responseBuffer.sublist(0, 3)));
        final responseSize = int.parse(String.fromCharCodes(responseBuffer.sublist(3, 7)));
        responseMessage = utf8.decode(responseBuffer.sublist(7, 7 + responseSize));
        completer.complete({"responseCode": responseCode, "responseMessage": responseMessage});

        client.close(); // Close the socket
      }
    });

    return completer.future;
  }
  
}
