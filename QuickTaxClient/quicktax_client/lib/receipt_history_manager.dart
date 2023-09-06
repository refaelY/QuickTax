import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quicktax_client/add_employee.dart';
import 'user_type.dart';
import 'camera.dart';
import 'add_employee.dart';
import 'Communicator.dart';
import 'commonLayout.dart';

class ReceiptHistoryManagerScreen extends StatefulWidget {
  final UserType userType;

  const ReceiptHistoryManagerScreen({required this.userType});

  // ignore: library_private_types_in_public_api
  _ReceiptHistoryManagerScreenState createState() => _ReceiptHistoryManagerScreenState();
}

class _ReceiptHistoryManagerScreenState extends State<ReceiptHistoryManagerScreen>
{
  late Future<List<Employee>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = fetchEmployeesData();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      userType: widget.userType,
      body: FutureBuilder<List<Employee>>(
        future: _employeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final employee = snapshot.data![index];
                return EmployeeReceiptList(employee: employee);
              },
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  
  Future<List<Employee>> fetchEmployeesData() async {
    final communicator = Communicator();
    Map<String, dynamic> requestData = {
      "_userId": widget.userType.userId,
    };

    String msg = "104" +
        jsonEncode(requestData).length.toString().padLeft(10, '0') +
        jsonEncode(requestData);


    final response = await communicator.sendRequestToServer(msg);

    final responseCode = response["responseCode"];
    final responseMessage = response["responseMessage"];

    if (responseCode == 404) 
    {
      throw Exception("Error fetching receipt data");
    } 
    else if (responseCode == 204)
    {
      final jsonString = responseMessage.replaceAll('null', '[]');
      final jsonResponse = jsonDecode(jsonString);
      List<Employee> employeeList = [];

      for (var employeeJson in jsonResponse) 
      {
        Employee employee = Employee.fromJson(employeeJson);
        
        List<Receipt> receiptList = [];
        for (var receipt in employee.receipts) {

          Map<String, dynamic> requestData = {
            "_pathImg": receipt.image, // This is the path of the img
          };

          String imgRequestMsg = "111" + jsonEncode(requestData).length.toString().padLeft(10, '0') + jsonEncode(requestData);

          final imgResponse = await communicator.sendRequestToServer(imgRequestMsg);

          final imgResponseCode = imgResponse["responseCode"];
          final imgResponseMessage = imgResponse["responseMessage"];

          if (imgResponseCode == 404) {
            throw Exception("Error fetching receipt image");
          } 
          else if (imgResponseCode == 211) 
          {
            try
            {
              Map<String, String> imgRes = Map<String, String>.from(json.decode(imgResponseMessage));            
              Receipt updatedReceipt = Receipt(
                image: imgRes['_img'] ?? ' ', // This is the base64 img
                userId: receipt.userId,
                storeName: receipt.storeName,
                amount: receipt.amount,
                dateTime: receipt.dateTime,
              );
              receiptList.add(updatedReceipt);
            } catch (e) {
              // Handle non-image response scenario here
            }
          }
        }
        // Assign the updated receipt list to the employee
        employee = Employee(
          userId: employee.userId,
          userName: employee.userName,
          storeName: employee.storeName,
          receipts: receiptList,
        );
        employee.receiptCount = employee.receipts.length;
        employeeList.add(employee);
      }

      return employeeList;
    } else {
      throw Exception("Unknown response code");
    }
  }

}


class EmployeeReceiptList extends StatelessWidget {
  final Employee employee;

  const EmployeeReceiptList({required this.employee});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(employee.userName),
      subtitle: Text('Store: ${employee.storeName}'),
      children: [
        if (employee.receipts.isNotEmpty) // Check if there are receipts
          for (var receipt in employee.receipts)
            GestureDetector(
              onTap: () {
                // Handle opening the receipt image here
                if (receipt.image.isNotEmpty) {
                  // Add code here to open the image, e.g., show a dialog with the image
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Image.memory(
                        base64Decode(receipt.image),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Delete'),
                          onPressed: () async {
                            final communicator = Communicator();
                            Map<String, dynamic> requestData = {
                              "_receipt": receipt,
                            };
                            String msg = "105" + jsonEncode(requestData).length.toString().padLeft(10, '0') + jsonEncode(requestData);
                            final response = await communicator.sendRequestToServer(msg);

                            final responseCode = response["responseCode"];
                            final responseMessage = response["responseMessage"];

                            if (responseCode == 404) 
                            {
                              throw Exception("Error fetching receipt data");
                            } 
                            else if (responseCode == 205) 
                            {
                              // ignore: use_build_context_synchronously
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: Text('The receipt has been deleted'),
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
                          },

                        ),
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
              child: ListTile(
                leading: receipt.image.isNotEmpty
                    ? Image.memory(
                        base64Decode(receipt.image),
                      )
                    : Icon(Icons.image),
                title: Text('Store: ${receipt.storeName}' + '\nAmount: \$${receipt.amount.toStringAsFixed(2)}'),
                subtitle: Text('Date: ${receipt.dateTime}'),
              ),
            ),
        if (employee.receipts.isEmpty) // Display a message if there are no receipts
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('No receipts available for this employee.'),
          ),
      ],
    );
  }
}
