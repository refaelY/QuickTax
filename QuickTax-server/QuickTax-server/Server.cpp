#include "HeaderFiles/Server.h"


Server::Server() : _m_communicator(_m_database)
{
    _m_database.open();
    _m_communicator = Communicator(_m_database);

#ifdef _WIN32
    WSAInitializer wsaInit;
#endif

    _serverSocket = ::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

    if (_serverSocket == SOCKET_ERROR)
        throw std::runtime_error(std::string(__FUNCTION__) + " - socket");
}

Server::~Server()
{
    try
    {
        #ifdef _WIN32
            ::closesocket(_serverSocket); // Close socket on Windows
        #else
            ::close(_serverSocket); // Close socket on non-Windows platforms (macOS, Linux, etc.)
        #endif
            _m_database.close();
    }
    catch (...) {}
}



void Server::run()
{
    _m_communicator.bindAndListen(_serverSocket);
    printf("server are bind and listen to new http get\n");
    while (true)
    {
        SocketType client_socket = ::accept(_serverSocket, NULL, NULL);
        printf("::accept new client\n");
        if (client_socket == SOCKET_ERROR)
            throw std::runtime_error(std::string(__FUNCTION__) + " - accept");

        _m_communicator.startThreadForNewClient(client_socket);
    }
}


