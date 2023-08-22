#pragma once
#include "Communicator.h"
#include "IDataBase.h"

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

#include <stdexcept> // Include the header for std::runtime_error

class Server
{
private:
    IDataBase _m_database;
    Communicator _m_communicator;
    SocketType _serverSocket;

public:
    Server();
    ~Server();
    void run();
};
