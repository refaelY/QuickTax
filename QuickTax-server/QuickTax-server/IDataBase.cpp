#include "HeaderFiles/IDataBase.h"

const std::string dbFileName = "/root/QuickTax/QuickTax-server/QuickTax-server/DataBaseServer.db";

const std::string IMAGE_FOLDER = "/root/QuickTax/QuickTax-server/QuickTax-server/receipt_images/";




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

        sqlStatement = "CREATE TABLE IF NOT EXISTS Receipt (ID INTEGER, AMOUNT INTEGER, DATE TEXT, EMPLOYEEID INTEGER, STORENAME TEXT, IMG TEXT, PRIMARY KEY(ID))";
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
    std::string image = argv[5];
    double amount = std::stoi(argv[1]);
    std::string date = argv[2];
    int employeeId = std::stoi(argv[3]);
    string storeName = argv[4];

    Receipt receipt{ image, employeeId, storeName, amount, date};
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

std::string IDataBase::getImg(const std::string& imagePath)
{
    std::string imageData;
    
    std::ifstream imageFile(imagePath, std::ios::binary | std::ios::ate);
    if (!imageFile.is_open()) {
        throw std::runtime_error("Error opening image file: " + imagePath);
    }
    
    std::streamsize imageSize = imageFile.tellg();
    imageFile.seekg(0, std::ios::beg);
    
    imageData.resize(imageSize);
    if (!imageFile.read(reinterpret_cast<char*>(imageData.data()), imageSize)) {
        throw std::runtime_error("Error reading image data from file: " + imagePath);
    }
    
    imageFile.close();
    
    // Convert the image data to a base64-encoded string
    std::string base64Image;
        
    base64Image = base64_encode(reinterpret_cast<const unsigned char*>(imageData.c_str()), imageData.length());
    
    return base64Image;
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
        throw std::invalid_argument("error removing employee from the database");
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
        throw std::invalid_argument("error in thr server Database");
    }

    sqlStatement = "INSERT INTO EMPLOYEE (BUSINESSID, USERNAME, PASSWORD, IS_MANAGER) VALUES(\"" + std::to_string(businessid) + "\",\"" + request._username + "\",\"" + request._password + "\", \"" + std::to_string(false) + "\");";
    res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
    if (res != SQLITE_OK) {
        cout << "error insert into Employee" << endl;
        sqlite3_free(errMessage);
        std::cout << "Error insert into Employee: " << errMessage << std::endl;
        throw std::invalid_argument("error insert into Employee");
    }
    
}

int IDataBase::getUniqueReceiptId() {
    std::string sqlStatement = "SELECT COUNT(*) FROM receipt;";
    char* errMessage = nullptr;
    int result = 0;

    int res = sqlite3_exec(db, sqlStatement.c_str(), getUserIdCallback, static_cast<void*>(&result), &errMessage);
    if (res != SQLITE_OK) {
        std::cout << "Error executing SQL statement: " << errMessage << std::endl;
        sqlite3_free(errMessage);
    }

    return result + 1; // Return the current sequence value without incrementing
}



std::string IDataBase::uploadReceipt(UploadReceiptRequest request) {
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;
    std::string image_binary;
    int receiptId = getUniqueReceiptId();

    
    std::string image_path = IMAGE_FOLDER + std::to_string(receiptId) + "_" + std::to_string(request._receipt._userId) + "_" + request._receipt._dateTime;

    
    image_binary = base64_decode(request._receipt._image);
    

    std::ofstream imageFile(image_path, std::ios::binary);
    imageFile.write(image_binary.c_str(), image_binary.length());

    
    request._receipt._image = image_path;

    // Insert the receipt into the database
    sqlStatement = "INSERT INTO Receipt (amount, date, employeeId, STORENAME, IMG) VALUES (" +
        std::to_string(request._receipt._amount) + ", '" +
        request._receipt._dateTime + "', " +
        std::to_string(request._receipt._userId) + ", '" +
        request._receipt._storeName + "', '" +
        request._receipt._image + "');";

    res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
    if (res != SQLITE_OK) {
        std::cout << "Error uploading receipt to the database: " << errMessage << std::endl;
        sqlite3_free(errMessage);
        throw std::invalid_argument("Error uploading receipt to the database");
    }

    return image_path;
}


///******************************End Add To Database*******************************************************************



//#TODO!
void IDataBase::deleteReceipt(DeleteReceiptRequest request)
{
    std::string sqlStatement;
    char* errMessage = nullptr;
    int res;


    // Delete the employee from the database
    sqlStatement = "DELETE FROM Receipt WHERE employeeid = " + std::to_string(request._receipt._userId) + " and date = '" + request._receipt._dateTime + "' and amount = " + std::to_string(request._receipt._amount) + " and storename = '" + request._receipt._storeName + "' ;";
    res = sqlite3_exec(db, sqlStatement.c_str(), nullptr, nullptr, &errMessage);
    if (res != SQLITE_OK) {
        std::cout << "Error removing employee from the database: " << errMessage << std::endl;
        sqlite3_free(errMessage);
        throw std::invalid_argument("error removing employee from the database");
    }
}
