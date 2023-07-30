#pragma once
#include <iostream>
#include <map>
#include "RequestStruct.h"
#include <thread>
#include <time.h>
#include <vector>
#include <string>
#include "IDataBase.h"
#include "IRequestHandler.h"
#include "JsonResponsePacketSerializer.h"
#include "JsonRequestPacketDeserializer.h"

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

using namespace std;

#define PORT 5555
#define INVALID_REQUEST "Invalid Request"
#define ERROR_SEND_MSG "Error while sending message to client"

class Communicator
{
private:
    void handleRequests(SocketType clientSocket);
    IDataBase _m_database;
    IRequestHandler _requestHandler;

public:
    Communicator(IDataBase& database);
    ~Communicator();
    void bindAndListen(SocketType serverSocket);
    void startThreadForNewClient(SocketType clientSocket);
    static Request getData(SocketType clientSocket);
    static void sendData(SocketType clientSocket, std::vector<uint8_t> buffer, int code);
};
