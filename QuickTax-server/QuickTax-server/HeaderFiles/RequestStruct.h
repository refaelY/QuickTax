#pragma once
#include <iostream>
#include <vector>
#include <list>

enum RequestCode
{
	LOGIN = 100,
	BUSINESSREGISTRATION = 101,
	UPLOADRECEIPT = 102,
	UPDATEPROFILE = 103,
	EMPLOYEELIST = 104,
	DELETERECEIPT = 105,
	GENERATEREPORT = 106,
	ADDEMPLOYEE = 107,
	REMOVEEMPLOYEE = 108,
	UPDATEEMPLOYEE = 109,
	RECEIPTLIST = 110
};

	struct Receipt
	{
		int _id;
		int _userId;
		std::string _storeName;
		double _amount;
		std::string _dateTime;
	};

struct Employee
{
	int _userId;
	std::string _username;
	std::string _storeName;
	std::list<Receipt> _receipts;
};

struct Request
{
	int _code;
	time_t _receivalTime;
	std::vector<std::uint8_t> _buffer;
};


struct LoginRequest
{
	std::string _username;
	std::string _password;
};

struct BusinessRegistrationRequest
{
	int _businessId;
	std::string _name;
	std::string _username;
	std::string _password;
	std::string _registrationDate;

};

struct UploadReceiptRequest
{
	Receipt _receipt;
};

struct AddEmployeeRequest
{
	std::string _username;
	std::string _password;
	int _userId;
};

struct GetEmployeeListRequest
{
	int _userId;
};

struct DeleteReceiptRequest
{
	Receipt _receipt;
};

struct RemoveEmployeeRequest
{
	int _userId;
	int _managerId;
};

struct GetReceiptListRequest
{
	int _userId;
};
