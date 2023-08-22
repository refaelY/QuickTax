import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'Communicator.dart';

import 'package:flutter/material.dart';
import 'user_type.dart'; 
import 'camera.dart';
import 'receipt_history.dart';

class AddEmployeePage extends StatefulWidget {
  final UserType userType;

  const AddEmployeePage({required this.userType});

  // ignore: library_private_types_in_public_api
  _AddEmployeePage createState() => _AddEmployeePage();
}

class _AddEmployeePage extends State<AddEmployeePage>
{
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  
  String username = '';
  String password = '';

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
              opacity: 0.6,
              child: Image.asset(
                'assets/images/logo.png',
                height: 200,
              ),
            ),
          ),
          // Rest of the Content
          Padding(
            padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, 
                crossAxisAlignment: CrossAxisAlignment.stretch,
                
                children: [
                  const SizedBox(height: 26),

                  const Text(
                    'To add an employee:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Form to input employee details
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  // Button to add employee
                  ElevatedButton(
                    onPressed: () async {

                      final communicator = Communicator();
                      username = _usernameController.text;
                      password = _passwordController.text;

                      Map<String, dynamic> requestData = {
                        "_username": username,
                        "_password": password,
                        "_userId": widget.userType.userId,
                      };

                      String msg = "107" + jsonEncode(requestData).length.toString().padLeft(4, '0') + jsonEncode(requestData);
                      
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
                        else if(responseCode == 207)
                        {
                          Map<String, int> res = Map<String, int>.from(json.decode(responseMessage));
                          if (res['_status'] == 400)
                          {
                            // ignore: use_build_context_synchronously
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('success'),
                                  content: Text("Employee has been added"),
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
                          else
                          {
                            // ignore: use_build_context_synchronously
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: Text("Employee hasn't been added"),
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
                      });
                    },
                    child: const Text('Add Employee'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'List of employee:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ),
          // Bottom Section - List of Users
          Positioned(
            top: 400, // Adjust the top position based on your design
            left: 16,
            right: 16,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: FutureBuilder<List<Employee>>(
                  // Use fetchEmployeeData() to retrieve employee data
                  future: fetchEmployeeData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      // Display your custom widget here, passing the employee list
                      return YourCustomEmployeeWidget(employeeList: snapshot.data!);
                    } else {
                      return const Center(child: Text('No data available.'));
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 3,
            onTap: (index) {
              // Define the logic for handling navigation when the user taps on each item
              // index 0: Scan, index 1: Receipt History, index 2: Profile Settings
              switch (index) {
                case 0:
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanScreen(userType: widget.userType),
                          ),
                        );
                  break;

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

  

  Future<List<Employee>> fetchEmployeeData() async {
    final communicator = Communicator();
    Map<String, dynamic> requestData = {
      "_userId": widget.userType.userId,
    };

    String msg = "104" + jsonEncode(requestData).length.toString().padLeft(4, '0') + jsonEncode(requestData);

    return communicator.sendRequestToServer(msg).then((response) {
      final responseCode = response["responseCode"];
      final responseMessage = response["responseMessage"];

      if (responseCode == 404) {
        throw Exception("Error fetching employee data");
      } else if (responseCode == 204) {
        String modifiedResponseMessage = responseMessage.replaceAll("\"_receipts\":null", "\"_receipts\":[]");
        final jsonResponse = jsonDecode(modifiedResponseMessage);
        List<Employee> employeeList = [];

        for (var employeeJson in jsonResponse) {
          Employee employee = Employee.fromJson(employeeJson);
          employeeList.add(employee);
        }

        return employeeList; // Return the employee list here
      } else {
        throw Exception("Unknown response code");
      }
    });
  }

}


class YourCustomEmployeeWidget extends StatelessWidget {
  final List<Employee> employeeList;

  YourCustomEmployeeWidget({required this.employeeList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var employee in employeeList)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(employee.userName),
                subtitle: Text(employee.storeName),
              ),
            ),
          ),
      ],
    );
  }
}
