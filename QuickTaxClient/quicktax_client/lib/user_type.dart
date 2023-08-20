enum UserType {
  Employee,
  Manager,
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