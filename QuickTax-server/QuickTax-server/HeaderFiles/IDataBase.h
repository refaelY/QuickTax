#pragma once
#ifndef IDATABASE_H
#define IDATABASE_H

#ifdef __cplusplus
extern "C" {
#endif

#include "sqlite3.h"

#ifdef __cplusplus
}
#endif



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
#include "base64.hpp"


using namespace std;


class IDataBase
{

private:
	sqlite3* db;
    
    static int doesItemExistsCallback(void* data, int argc, char** argv, char** azColName);

	static int getReceiptListCallback(void* data, int argc, char** argv, char** azColName);
    static int getEmployeeListCallback(void* data, int argc, char** argv, char** azColName, IDataBase* dbInstance);
	static int getUserIdCallback(void* data, int argc, char** argv, char** azColName);
	static int getBusinessNameCallback(void* data, int argc, char** argv, char** azColName);
    static int getEmployeeListCallbackWrapper(void* data, int argc, char** argv, char** azColName);
    int getEmployeeListCallback(std::list<Employee>* employeeList, int argc, char** argv, char** azColName);
    
public:

	IDataBase();
	~IDataBase();

    bool open();
    void close();
    
    bool doesUserExists(LoginRequest loginRequest);
    bool doesUserDirector(LoginRequest loginRequest);
    bool doesUserDirectorById(int id);
    bool doesUsernameExists(string username);
    
	int getUserId(std::string username, std::string password);
	std::string getBusinessName(int userId);
    std::list<Receipt> getReceiptList(GetReceiptListRequest);
    std::list<Employee> getEmployeeList(GetEmployeeListRequest);
    int getUniqueReceiptId();
    std::string getImg(const std::string& imagePath);
    
	void createBusiness(BusinessRegistrationRequest request);
	void addEmployee(AddEmployeeRequest request);
    std::string uploadReceipt(UploadReceiptRequest request);
	void deleteReceipt(DeleteReceiptRequest);
	void removeEmployee(RemoveEmployeeRequest);


};

struct EmployeeListCallbackData {
    IDataBase* dbInstance;
    std::list<Employee>* employeeList;
};


#endif
