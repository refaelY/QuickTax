#pragma once
#include <list>
#include <map>
#include "RequestStruct.h"
#include <vector>
#include <algorithm>
#include <iostream>
#include <fstream>
//#include <io.h>
#include <string.h>
#include <string>
#include "sqlite3.h"

using namespace std;

class IDataBase
{

private:
	sqlite3* db;
	static int doesItmeExistsCallBack(void* data, int argc, char** argv, char** azColName);
	static int getReceiptListCallback(void* data, int argc, char** argv, char** azColName);
	static int getEmployeeListCallback(void* data, int argc, char** argv, char** azColName);
	static int doesItemExistsCallback(void* data, int argc, char** argv, char** azColName);
	static int getUserIdCallback(void* data, int argc, char** argv, char** azColName);
	static int getBusinessNameCallback(void* data, int argc, char** argv, char** azColName);

public:

	IDataBase();
	~IDataBase();

	int getUserId(std::string username, std::string password);
	std::string getBusinessName(int userId);

	void createBusiness(BusinessRegistrationRequest request);
	void addEmployee(AddEmployeeRequest request);
	void uploadReceipt(UploadReceiptRequest request);
	void deleteReceipt(DeleteReceiptRequest);
	void removeEmployee(RemoveEmployeeRequest);
	
	std::list<Receipt> getReceiptList(GetReceiptListRequest);
	std::list<Employee> getEmployeeList(GetEmployeeListRequest);

	bool doesUserExists(LoginRequest loginRequest);
	bool doesUserDirector(LoginRequest loginRequest);
	bool doesUsernameExists(string username);

	bool open();
	void close();


};

