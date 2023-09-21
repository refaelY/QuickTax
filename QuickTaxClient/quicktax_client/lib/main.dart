import 'dart:convert';

import 'package:flutter/material.dart';
import 'signup.dart';
import 'menu.dart';
import 'user_type.dart';
import 'Communicator.dart';

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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage>  {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/background.jpg', 
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo image at the top
                    SizedBox(height: 100),

                    Image.asset(
                      'assets/images/logo.png',
                      height: 300,
                    ),
                    
                    SizedBox(height: 2), //Space between logo and username
                    // Username Field
                    TextFormField(
                      controller: _usernameController,
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
                    SizedBox(height: 60),

                    // Login Button
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          colors: [Color.fromARGB(255, 56, 131, 202), Color.fromARGB(255, 40, 102, 217)])),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          alignment: Alignment.center,
                          padding: MaterialStateProperty.all(const EdgeInsets.only(
                              right: 75, left: 75, top: 15, bottom: 15)),
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      )
                    ),
                    onPressed: () async {
                      final communicator = Communicator();

                      username = _usernameController.text;
                      password = _passwordController.text;

                      Map<String, dynamic> requestData = {
                        "_username": username,
                        "_password": password,
                      };

                      String msg = "100" + jsonEncode(requestData).length.toString().padLeft(10, '0') + jsonEncode(requestData);
                      
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
                        else if(responseCode == 200)
                        {
                          LoginResponse res = LoginResponse.fromJson(json.decode(responseMessage));

                            if (res.status == 2)
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
                        }
                      );
                      },
                      child: const Text(
                            "Login",
                            style: TextStyle(color: Color(0xffffffff), fontSize: 16),
                        )
                      )
                    ),
                    SizedBox(height: 16),

                    // Signup Button
                    TextButton(
                      onPressed: () {
                      // Navigate to the SignupPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255), // You can use your preferred color
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}