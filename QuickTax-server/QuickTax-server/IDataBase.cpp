#include "HeaderFiles/IDataBase.h"

std::string dbFileName = "DataBaseServer2.db";

IDataBase::IDataBase() {}

IDataBase::~IDataBase() {}



///**********************************Open And Close Databases********************

bool fileExists(const std::string& filePath)
{
    std::ifstream file(filePath);
    return file.good();
}

bool IDataBase::open()
{
    int file_exist = fileExists(dbFileName);
    int res = sqlite3_open(dbFileName.c_str(), &db);
    std::string sqlStatement;

    if (res != SQLITE_OK) {
        db = nullptr;
        cout << "Failed to open DB" << endl;
        return false;
    }

    if (file_exist != 0) {
        sqlStatement = "CREATE TABLE IF NOT EXISTS BUSINESS (ID INTEGER, NAME TEXT, registrationDate TEXT, USERNAME TEXT, PASSWORD TEXT, PRIMARY KEY(ID))";
        char* errMessage = nullptr;
        res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
        if (res != SQLITE_OK) {
            cout << "Business creation error!" << endl;
            sqlite3_free(errMessage);
            system("PAUSE");
            return false;
        }

        sqlStatement = "CREATE TABLE IF NOT EXISTS EMPLOYEE (ID INTEGER, BUSINESSID INTEGER, USERNAME TEXT, PASSWORD TEXT, IS_MANAGER BOOL, PRIMARY KEY(ID))";
        errMessage = nullptr;
        res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
        if (res != SQLITE_OK) {
            cout << "Employee creation error!" << endl;
            sqlite3_free(errMessage);
            return false;
        }

        sqlStatement = "CREATE TABLE IF NOT EXISTS Receipt (ID INTEGER, AMOUNT INTEGER, DATE TEXT, EMPLOYEEID INTEGER, IMG, TEXT, PRIMARY KEY(ID))";
        errMessage = nullptr;
        res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
        if (res != SQLITE_OK) {
            cout << "Receipt creation error!" << endl;
            sqlite3_free(errMessage);
            return false;
        }
    }

    return true;
}

void IDataBase::close()
{
    if (db != nullptr) {
        sqlite3_close(db);
    }
}

///******************************End Open And Close Functions**************************



///**********************************************Callback Functions*******************************************

int IDataBase::doesItemExistsCallback(void* data, int argc, char** argv, char** azColName)
{
    bool* ans = static_cast<bool*>(data);
    if (std::stoi(argv[0]) != 0)
        *ans = true;
    else
        *ans = false;
    return 0;
}

int IDataBase::getReceiptListCallback(void* data, int argc, char** argv, char** azColName)
{
    std::list<Receipt>* receiptList = static_cast<std::list<Receipt>*>(data);
    int id = std::stoi(argv[0]);
    double amount = std::stoi(argv[1]);
    std::string date = argv[2];
    int employeeId = std::stoi(argv[3]);
    IDataBase db;

    Receipt receipt{ id, employeeId, db.getBusinessName(employeeId), amount, date};
    receiptList->push_back(receipt);
    return 0;
}

int IDataBase::getUserIdCallback(void* data, int argc, char** argv, char** azColName)
{
    int* userId = static_cast<int*>(data);
    *userId = std::stoi(argv[0]);
    return 0;
}

int IDataBase::getBusinessNameCallback(void* data, int argc, char** argv, char** azColName) {
    std::string* businessName = static_cast<std::string*>(data);
    *businessName = argv[0];
    return 0;
}

int getEmployeeListCallback(void* data, int argc, char** argv, char** azColName, IDataBase* dbInstance);

int IDataBase::getEmployeeListCallbackWrapper(void* data, int argc, char** argv, char** azColName)
{
    EmployeeListCallbackData* callbackData = static_cast<EmployeeListCallbackData*>(data);
    return callbackData->dbInstance->getEmployeeListCallback(callbackData->employeeList, argc, argv, azColName);
}

int IDataBase::getEmployeeListCallback(std::list<Employee>* employeeList, int argc, char** argv, char** azColName)
{
    int id = std::stoi(argv[0]);
    std::string username = argv[2];
    std::string password = argv[3];
    GetReceiptListRequest receiptList{id};

    Employee employee{ id, username, getBusinessName(id), getReceiptList(receiptList) };
    employeeList->push_back(employee);
    return 0;
}

///**********************************************End Callback Functions*******************************************


///******************************Get items Functions******************************************************

std::list<Employee> IDataBase::getEmployeeList(GetEmployeeListRequest request)
{
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;
    int businessid;
    std::list<Employee> employeeList;
    
    EmployeeListCallbackData callbackData;
    callbackData.dbInstance = this; // Set the IDataBase pointer
    callbackData.employeeList = &employeeList; // Set the list pointer
    
        
    sqlStatement = "SELECT businessid FROM Employee WHERE id = " + std::to_string(request._userId) + ";";

    res = sqlite3_exec(db, sqlStatement.c_str(), getUserIdCallback, static_cast<void*>(&businessid), &errMessage);
    if (res != SQLITE_OK) {
        std::cout << "Error executing SQL statement: " << errMessage << std::endl;
        sqlite3_free(errMessage);
    }
    
    
    sqlStatement = "SELECT * FROM EMPLOYEE WHERE BUSINESSID = " + std::to_string(businessid) + ";";
    res = sqlite3_exec(db, sqlStatement.c_str(), getEmployeeListCallbackWrapper, &callbackData, &errMessage);

    
    if (res != SQLITE_OK) {
        sqlite3_free(errMessage);
        cout << "Get employee list error!" << endl;
    }
    return employeeList;
}


std::list<Receipt> IDataBase::getReceiptList(GetReceiptListRequest request) {
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;
    std::list<Receipt> receiptList;
    sqlStatement = "SELECT * FROM RECEIPT WHERE EMPLOYEEID = " + std::to_string(request._userId) + ";";
    res = sqlite3_exec(db, sqlStatement.c_str(), getReceiptListCallback, static_cast<void*>(&receiptList), &errMessage);
    if (res != SQLITE_OK) {
        sqlite3_free(errMessage);
        cout << "Get receipt list error!" << endl;
    }
    return receiptList;
}


int IDataBase::getUserId(std::string username, std::string password) {
    std::string sqlStatement = "SELECT id FROM Employee WHERE userName = '" + username + "' AND password = '" + password + "';";
    char* errMessage = nullptr;
    int userId = 0;

    int res = sqlite3_exec(db, sqlStatement.c_str(), getUserIdCallback, static_cast<void*>(&userId), &errMessage);
    if (res != SQLITE_OK) {
        std::cout << "Error executing SQL statement: " << errMessage << std::endl;
        sqlite3_free(errMessage);
    }

    return userId;
}

std::string IDataBase::getBusinessName(int userId)
{
    std::string sqlStatement = "SELECT businessid FROM employee WHERE id = " + std::to_string(userId) + ";";
    char* errMessage = nullptr;
    std::string businessName = "";
    int businessID = 0;

    int res = sqlite3_exec(db, sqlStatement.c_str(), getUserIdCallback, &businessID, &errMessage);
    if (res != SQLITE_OK) {
        std::cout << "Error executing SQL statement: " << errMessage << std::endl;
        sqlite3_free(errMessage);
    }
    
    
    sqlStatement = "SELECT name FROM Business WHERE id = " + std::to_string(businessID) + ";";

    res = sqlite3_exec(db, sqlStatement.c_str(), getBusinessNameCallback, &businessName, &errMessage);
    if (res != SQLITE_OK) {
        std::cout << "Error executing SQL statement: " << errMessage << std::endl;
        sqlite3_free(errMessage);
    }

    return businessName;
}

///******************************End Get items Functions******************************************************

///******************************Question Function*************************************************************

bool IDataBase::doesUserExists(LoginRequest loginRequest) {
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;
    bool ans = false;

    sqlStatement = "SELECT COUNT(USERNAME) from EMPLOYEE where USERNAME = \"" + loginRequest._username + "\" AND PASSWORD = \"" + loginRequest._password + "\"; ";
    res = sqlite3_exec(db, sqlStatement.c_str(), doesItemExistsCallback, static_cast<void*>(&ans), &errMessage);
    if (res != SQLITE_OK) {
        cout << "user is not exists" << endl;
        sqlite3_free(errMessage);
    }

    return ans;
}

bool IDataBase::doesUserDirector(LoginRequest loginRequest) {
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;
    bool ans = false;

    sqlStatement = "SELECT IS_MANAGER from EMPLOYEE where USERNAME = \"" + loginRequest._username + "\" AND PASSWORD = \"" + loginRequest._password + "\"; ";
    res = sqlite3_exec(db, sqlStatement.c_str(), doesItemExistsCallback, static_cast<void*>(&ans), &errMessage);

    if (res != SQLITE_OK) {
        cout << "user is not director" << endl;
        sqlite3_free(errMessage);
    }

    return ans;
}

bool IDataBase::doesUserDirectorById(int id)
{
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;
    bool ans = false;

    sqlStatement = "SELECT IS_MANAGER from EMPLOYEE where ID = \"" + std::to_string(id) +  "\"; ";
    res = sqlite3_exec(db, sqlStatement.c_str(), doesItemExistsCallback, static_cast<void*>(&ans), &errMessage);

    if (res != SQLITE_OK) {
        cout << "user is not director" << endl;
        sqlite3_free(errMessage);
    }

    return ans;
}

bool IDataBase::doesUsernameExists(std::string username) {
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;
    bool ans = false;

    sqlStatement = "SELECT COUNT(USERNAME) from EMPLOYEE where USERNAME = \"" + username + "\"; ";
    res = sqlite3_exec(db, sqlStatement.c_str(), doesItemExistsCallback, static_cast<void*>(&ans), &errMessage);
    if (res != SQLITE_OK) {
        cout << "Username exists" << endl;
        sqlite3_free(errMessage);
    }

    return ans;
}

///******************************End Question Function*************************************************************


///******************************Add To Database*******************************************************************

void IDataBase::removeEmployee(RemoveEmployeeRequest request)
{
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;


    // Delete the employee from the database
    sqlStatement = "DELETE FROM Employee WHERE id = " + std::to_string(request._userId) + ";";
    res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
    if (res != SQLITE_OK) {
        std::cout << "Error removing employee from the database: " << errMessage << std::endl;
        sqlite3_free(errMessage);
    }
   
}

void IDataBase::createBusiness(BusinessRegistrationRequest request) {
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;
    if (!doesUsernameExists(request._username)) {
        sqlStatement = "INSERT INTO BUSINESS (ID, NAME, REGISTRATIONDATE, USERNAME, PASSWORD) VALUES(\"" + std::to_string(request._businessId) + "\",\"" + request._name + "\",\"" + request._registrationDate + "\",\"" + request._username + "\",\"" + request._password + "\");";
        res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
        if (res != SQLITE_OK) {
            cout << "error insert into Business" << endl;
            sqlite3_free(errMessage);
            throw std::invalid_argument("error insert into Business");
        }
        
        sqlStatement = "INSERT INTO EMPLOYEE (BUSINESSID, USERNAME, PASSWORD, IS_MANAGER) VALUES(\"" + std::to_string(request._businessId) + "\",\"" + request._username + "\",\"" + request._password + "\", \"" + std::to_string(true) + "\");";
        res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
        if (res != SQLITE_OK) {
            cout << "error insert into Employee" << endl;
            sqlite3_free(errMessage);
            throw std::invalid_argument("error insert into Employee");
        }
        
    }
    else {
        cout << "Username already exists" << endl;
        throw std::invalid_argument("username exists");
    }
}

void IDataBase::addEmployee(AddEmployeeRequest request) {
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;
    int businessid = 0;
    
    sqlStatement = "SELECT businessid FROM Employee WHERE id = " + std::to_string(request._userId) + ";";

    res = sqlite3_exec(db, sqlStatement.c_str(), getUserIdCallback, static_cast<void*>(&businessid), &errMessage);
    if (res != SQLITE_OK) {
        std::cout << "Error executing SQL statement: " << errMessage << std::endl;
        sqlite3_free(errMessage);
    }

    
    
    sqlStatement = "INSERT INTO EMPLOYEE (BUSINESSID, USERNAME, PASSWORD, IS_MANAGER) VALUES(\"" + std::to_string(businessid) + "\",\"" + request._username + "\",\"" + request._password + "\", \"" + std::to_string(false) + "\");";
    res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
    if (res != SQLITE_OK) {
        cout << "error insert into Employee" << endl;
        sqlite3_free(errMessage);
        throw std::invalid_argument("error insert into Employee");

    }
    
}


void IDataBase::uploadReceipt(UploadReceiptRequest request) {
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;

  
    // Insert the receipt into the database
    sqlStatement = "INSERT INTO Receipt (id, amount, date, employeeId) VALUES (" +
        std::to_string(request._receipt._id) + ", " +
        std::to_string(request._receipt._amount) + ", '" +
        request._receipt._dateTime + "', " +
        std::to_string(request._receipt._userId) + ", " + ");";

    res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
    if (res != SQLITE_OK) {
        std::cout << "Error uploading receipt to the database: " << errMessage << std::endl;
        sqlite3_free(errMessage);
    }
    
}

///******************************End Add To Database*******************************************************************





