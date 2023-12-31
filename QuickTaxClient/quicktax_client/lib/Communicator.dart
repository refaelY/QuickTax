import 'dart:async';
import 'dart:convert';
import 'dart:io';


class Communicator
{
  static const String SERVER_IP = "192.168.1.133";

  Future<Map<String, dynamic>> sendRequestToServer(String msg) async
  {
    final completer = Completer<Map<String, dynamic>>();

    int? responseCode;
    String? responseMessage;

    final client = await Socket.connect(SERVER_IP, 5555);
    
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



