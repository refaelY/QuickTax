import 'dart:convert';

import 'package:flutter/material.dart';
import 'menu.dart';
import 'user_type.dart';
import 'Communicator.dart';



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
                    onPressed: () async
                    {

                      final communicator = Communicator();
                      businessId = _businessIdController.text;
                      businessName = _businessNameController.text;
                      username = _usernameController.text;
                      password = _passwordController.text;


                      final requestData = BusinessRegistrationRequest(
                        businessId: int.parse(businessId),
                        businessName: businessName,
                        username: username,
                        password: password,
                        registrationDate: ' ',
                      );

                      String msg = "101" + jsonEncode(requestData.toJson()).length.toString().padLeft(4, '0') + jsonEncode(requestData.toJson());    
                    
                      communicator.sendRequestToServer(msg).then((response)
                      {
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
                          LoginResponse res = LoginResponse.fromJson(json.decode(responseMessage));

                          if (res.status == 1)
                          {
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MenuPage(userType: UserType(type: UserTypeValue.Manager, userId: res.userId, storeName: res.storeName))),
                            );
                          }
                          else
                          {
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MenuPage(userType: UserType(type: UserTypeValue.Employee, userId: res.userId, storeName: res.storeName))),
                            );
                          }
                        }
                      });
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
