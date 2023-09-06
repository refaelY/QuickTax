import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quicktax_client/add_employee.dart';
import 'user_type.dart';
import 'camera.dart';
import 'add_employee.dart';
import 'Communicator.dart';
import 'commonLayout.dart';

class ReceiptHistoryScreen extends StatefulWidget {
  final UserType userType;

  const ReceiptHistoryScreen({required this.userType});

  // ignore: library_private_types_in_public_api
  _ReceiptHistoryScreen createState() => _ReceiptHistoryScreen();
}

class _ReceiptHistoryScreen extends State<ReceiptHistoryScreen>
{
  late Future<List<Receipt>> _receiptsFuture;

  @override
  void initState() {
    super.initState();
    _receiptsFuture = fetchReceiptsData();
  }

  @override
@override
Widget build(BuildContext context) {
  return CommonLayout(
    userType: widget.userType,
    body: FutureBuilder<List<Receipt>>(
      future: _receiptsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return YourCustomReceiptWidget(receiptList: snapshot.data!);
        } else {
          return Center(child: Text('No data available.'));
        }
      },
    ),
  );
}



  
  Future<List<Receipt>> fetchReceiptsData() async {
  final communicator = Communicator();
  Map<String, dynamic> requestData = {
    "_userId": widget.userType.userId,
  };

  String msg = "110" + jsonEncode(requestData).length.toString().padLeft(10, '0') + jsonEncode(requestData);

  final response = await communicator.sendRequestToServer(msg);

  final responseCode = response["responseCode"];
  final responseMessage = response["responseMessage"];

  if (responseCode == 404) 
  {
    throw Exception("Error fetching receipt data");
  } 
  else if (responseCode == 210) 
  {
    try {
      final jsonString = responseMessage.replaceAll('null', '[]');
      final jsonResponse = jsonDecode(jsonString);
      List<Receipt> receiptList = [];

      for (var receiptJson in jsonResponse) {
        Receipt receipt = Receipt.fromJson(receiptJson);

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
            receipt = Receipt(
              image: imgRes['_img'] ?? ' ', // This is the base64 img
              userId: receipt.userId,
              storeName: receipt.storeName,
              amount: receipt.amount,
              dateTime: receipt.dateTime,
            );
          } catch (e) {
            // Handle non-image response scenario here
          }
        }

        receiptList.add(receipt);
      }
      return receiptList;
    } catch (e) {
      // Handle non-receipt response scenario here
      return [];
    }
  } else {
    throw Exception("Unknown response code");
  }
}

}

class YourCustomReceiptWidget extends StatelessWidget {
  final List<Receipt> receiptList;

  YourCustomReceiptWidget({required this.receiptList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: receiptList.length,
      itemBuilder: (context, index) {
        final receipt = receiptList[index];

        return ListTile(
          leading: receipt.image.isNotEmpty
          ? Image.memory(
              base64Decode(receipt.image),
            )
          : Icon(Icons.image), // Placeholder icon if the image string is empty
          title: Text(receipt.storeName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount: \$${receipt.amount.toStringAsFixed(2)}'),
              Text('Date: ${receipt.dateTime}'),
            ],
          ),
          onTap: () {
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
        );
      },
    );
  }
}



