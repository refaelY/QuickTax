#include "HeaderFiles/Communicator.h"


Communicator::Communicator(IDataBase& database) : _requestHandler(_m_database)
{
	_m_database = database;
	_requestHandler = IRequestHandler(_m_database);
}

Communicator::~Communicator()
{

}

void Communicator::bindAndListen(SocketType serverSocket)
{
	struct sockaddr_in sa = { 0 };

	sa.sin_port = htons(PORT);
	sa.sin_family = AF_INET;
	sa.sin_addr.s_addr = INADDR_ANY;


	if (::bind(serverSocket, (struct sockaddr*)&sa, sizeof(sa)) == SOCKET_ERROR)
        throw std::runtime_error(std::string(__FUNCTION__) + " - bind");


	if (::listen(serverSocket, SOMAXCONN) == SOCKET_ERROR)
        throw std::runtime_error(std::string(__FUNCTION__) + " - listen");

}

void Communicator::startThreadForNewClient(SocketType clientSocket)
{
	std::thread client(&Communicator::handleRequests, this, clientSocket);
	client.detach();
}

void Communicator::handleRequests(SocketType clientSocket)
{
	Request request;
	RequestResult result;
	try
	{
		//************Get data from client*************
		request = getData(clientSocket);
		printf("fff");
		try
		{
			switch (request._code)
			{
			case LOGIN:
				result = _requestHandler.login(request, clientSocket);
				break;
			case BUSINESSREGISTRATION:
				result = _requestHandler.businessRegistration(request, clientSocket);
				break;
			case UPLOADRECEIPT:
				result = _requestHandler.uploadReceipt(request, clientSocket);
				break;
			case UPDATEPROFILE:
				//TODO
				break;
			case EMPLOYEELIST:
				result = _requestHandler.getEmployeeList(request, clientSocket);
				break;
			case DELETERECEIPT:
				result = _requestHandler.deleteReceipt(request, clientSocket);
				break;
			case GENERATEREPORT:
				//TODO
				break;
			case ADDEMPLOYEE:
				result = _requestHandler.addEmployee(request, clientSocket);
				break;
			case REMOVEEMPLOYEE:
				result = _requestHandler.removeEmployee(request, clientSocket);
				break;
			case UPDATEEMPLOYEE:
				//TODO
				break;
			case RECEIPTLIST:
				result = _requestHandler.getReceiptList(request, clientSocket);
				break;
			
			default:
				throw std::invalid_argument("Invalid request code.");
				
			}

		}
		catch (std::invalid_argument& e)
		{
			ErrorResponse error{ e.what() };
			result._response = JsonResponsePacketSerializer::serializeResponse(error);
			result._code = ERRORRESPONSE;
		}


		//*************send data to user**************

		sendData(clientSocket, result._response, result._code);
		
	}
	catch (exception& e)
	{
		std::cout << e.what() << std::endl;
	}
}

Request Communicator::getData(SocketType clientSocket)
{
	char msg[4];
	int code, size;
	std::vector<uint8_t> buffer;
	time_t timer;

	recv(clientSocket, msg, 3, 0); //get code
	msg[3] = NULL;
	code = std::atoi(msg);
	recv(clientSocket, msg, 4, 0); //get size of data
	size = std::atoi(msg);

	if (size != 0)
	{
		char* data = new char[size]; //create arry with this size
		recv(clientSocket, data, size, 0);
		//printf(data);
		for (int i = 0; i < size; i++) //Transferring everything to vector<BITE>
		{
			buffer.push_back(uint8_t(data[i]));
		}
		delete[] data;
	}

	timer = time(nullptr);
	Request request{ code, timer, buffer };
	return request;
}

void Communicator::sendData(SocketType clientSocket, std::vector<uint8_t> buffer, int code)
{
	char* data = new char[buffer.size() + 7];

	//packet:   CODE(3bit), SIZE(4bit), DATA(size-bit)
	std::string codeAndSize = std::to_string(code);

	for (int i = 0; i < (4 - std::to_string(buffer.size()).length()); i++) //add zero to be size 4 bit
	{
		codeAndSize += '0';
	}
	codeAndSize += std::to_string(buffer.size());

	for (int i = 0; i < codeAndSize.size(); i++) //add to dataToSend the code and the size
	{
		data[i] = codeAndSize[i];
	}
	int y = 0;
	for (int i = 7; y < buffer.size(); i++) //add the msg
	{
		data[i] = char(buffer[y]);
		y++;
	}

	if (send(clientSocket, data, buffer.size() + 7, 0) == SOCKET_ERROR)
	{
		throw std::runtime_error(ERROR_SEND_MSG);
	}

	delete[] data;
}

