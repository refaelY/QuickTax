#pragma once
#include <iostream>
#include "RequestStruct.h"

enum ResponseCode
{
	LOGINRESPONSE = 200,
	BUSINESSREGISTRATIONRESPONSE = 201,
	UPLOADRECEIPTRESPONSE = 202,
	GETEMPLOYEELISTRESPONSE = 204,
	DELETERECEIPTRESPONSE = 205,
	REMOVEEMPLOYEERESPONS = 208,
	GETRECEIPTLISTRESPONSE = 210,
    GETIMGRESPONSE = 211,
	ADDEMPLOYEERESPONSE = 207,

	ERRORRESPONSE = 404,
	SUCCEED = 400
};

struct RequestResult
{
	std::vector<std::uint8_t> _response;
	int _code;
};


struct LoginResponse
{
	unsigned int _status;
	std::string _storeName;
	int _userId;
};


struct UploadReceiptResponse
{
	unsigned int _status;
};

struct AddEmployeeResponse
{
	unsigned int _status;
};


struct GetEmployeeListResponse
{
	std::list<Employee> _employeeList;
};

struct DeleteReceiptResponse
{
	unsigned int _status;
};

struct RemoveEmployeeResponse
{
	unsigned int _status;
};

struct GetReceiptListResponse
{
	std::list<Receipt> _receiptList;
};


struct ErrorResponse
{
	std::string _message;
};

struct LogoutResponse
{
	unsigned int _status;
};

struct GetImgResponse
{
    std::string _img;
};
