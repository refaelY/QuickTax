
class UserType {
  final UserTypeValue type;
  final int userId;
  final String storeName;


  
  UserType({
    required this.type,
    required this.userId,
    required this.storeName,
  });
}

enum UserTypeValue {
  Employee,
  Manager,
}

class Receipt {
  final String image; 
  final int userId;
  final String storeName;
  final double amount;
  final String dateTime;

  Receipt({
    required this.image,
    required this.userId,
    required this.storeName,
    required this.amount,
    required this.dateTime,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      image: json['_image'], // Use the correct JSON key
      userId: json['_userId'],
      storeName: json['_storeName'],
      amount: json['_amount'],
      dateTime: json['_dateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_image": image, // Use the correct JSON key
      "_userId": userId,
      "_storeName": storeName,
      "_amount": amount,
      "_dateTime": dateTime,
    };
  }
}


class Employee {
  final int userId;
  final String userName;
  final String storeName;
  final List<Receipt> receipts;
  int receiptCount;

  Employee({
    required this.userId,
    required this.userName,
    required this.storeName,
    required this.receipts,
  }) : receiptCount = receipts.length;

  factory Employee.fromJson(Map<String, dynamic> json) {
    var receiptsJson = json['_receipts'] as List<dynamic>;
    var receipts = receiptsJson.map((receipt) => Receipt.fromJson(receipt)).toList();

    return Employee(
      userId: json['_userId'],
      userName: json['_userName'],
      storeName: json['_storeName'],
      receipts: receipts,
    );
  }
}



class BusinessRegistrationRequest {
  final int businessId;
  final String businessName;
  final String username;
  final String password;
  final String registrationDate;

  BusinessRegistrationRequest({
    required this.businessId,
    required this.businessName,
    required this.username,
    required this.password,
    required this.registrationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      "_businessId": businessId,
      "_name": businessName,
      "_username": username,
      "_password": password,
      "_registrationDate": registrationDate,
    };
  }
}

class UploadReceiptRequest {
  final Receipt receipt;

  UploadReceiptRequest({
    required this.receipt,
  });

  Map<String, dynamic> toJson() {
    return {
      "_receipt": receipt.toJson(),
    };
  }
}


class LoginResponse
{
  final int status;
	final String storeName;
	final int userId;

  LoginResponse(
  {
    required this.status,
    required this.storeName,
    required this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['_status'] as int,
      storeName: json['_storeName'] as String,
      userId: json['_userId'] as int,
    );
  }
}
