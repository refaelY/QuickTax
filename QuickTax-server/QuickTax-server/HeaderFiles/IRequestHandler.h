#pragma once
#include <iostream>
#include <time.h>
#include <vector>
#include "RequestStruct.h"
#include "ResponseStruct.h"
#include "JsonRequestPacketDeserializer.h"
#include "JsonResponsePacketSerializer.h"
#include "IDataBase.h"


//namespace asio = boost::asio;
//namespace fs = boost::filesystem;

#ifdef _WIN32
    #include <WinSock2.h>
    #pragma comment(lib, "ws2_32.lib")
    typedef SOCKET SocketType; // Use SOCKET for Windows
#else
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <unistd.h>
    typedef int SocketType; // Use int for non-Windows (macOS, Linux, etc.)
    #define SOCKET_ERROR -1
#endif

#define ERROR_USER_NOT_EXISTS "user is not exists"
#define ERROR_USER_EXISTS "user is exists"
#define ALL_NUMBER "0123456789"
#define FAILEDLOGIN 0
#define EMPLOYEE 1
#define DIRECTOR 2



class IRequestHandler
{
private:
    IDataBase _m_database;

public:
    IRequestHandler(IDataBase& m_database);
    ~IRequestHandler();

    RequestResult login(Request request, SocketType socket);
    RequestResult businessRegistration(Request request, SocketType socket);
    RequestResult addEmployee(Request request, SocketType socket);
    RequestResult uploadReceipt(Request request, SocketType socket);
    RequestResult getEmployeeList(Request request, SocketType socket);
    RequestResult deleteReceipt(Request request, SocketType socket);
    RequestResult removeEmployee(Request request, SocketType socket);
    RequestResult getReceiptList(Request request, SocketType socket);
    RequestResult getImg(Request request, SocketType socket);
};
