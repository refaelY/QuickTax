#pragma once

#ifdef _WIN32
    #include <WinSock2.h>
    #include <Windows.h>
#else
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <unistd.h>
#endif


class WSAInitializer
{
public:
	WSAInitializer();
	~WSAInitializer();
};

