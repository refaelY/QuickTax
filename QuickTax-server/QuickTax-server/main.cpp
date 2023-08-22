#pragma comment (lib, "ws2_32.lib")
#include <iostream>
#include "HeaderFiles/Server.h"
#include <exception>

int main()
{
    try
    {
        Server myServer;

        myServer.run();
    }
    catch (std::exception& e)
    {
        std::cout << "Error occured: " << e.what() << std::endl;
    }
    system("PAUSE");
    return 0;
}
