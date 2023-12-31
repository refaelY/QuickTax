#include "HeaderFiles/IRequestHandler.h"



IRequestHandler::IRequestHandler(IDataBase& m_database)
{
	_m_database = m_database;
}

IRequestHandler::~IRequestHandler() {}

RequestResult IRequestHandler::login(Request request, SocketType socket)
{
	RequestResult result;
	LoginResponse response;

    _m_database.open();
	LoginRequest loginRequest = JsonRequestPacketDeserializer::deserializeLoginRequest(request._buffer);
	if (_m_database.doesUserExists(loginRequest))
	{
		if (_m_database.doesUserDirector(loginRequest))
        {
            response._status = DIRECTOR;
        }
		else
            response._status = EMPLOYEE;
	}
	else
        throw std::invalid_argument(ERROR_USER_NOT_EXISTS);

	response._userId = _m_database.getUserId(loginRequest._username, loginRequest._password);
	response._storeName = _m_database.getBusinessName(response._userId);
	result._response = JsonResponsePacketSerializer::serializeResponse(response);
	result._code = LOGINRESPONSE;

    _m_database.close();
	return result;
}

RequestResult IRequestHandler::businessRegistration(Request request, SocketType socket)
{
	RequestResult result;
	LoginResponse response;

    _m_database.open();
	BusinessRegistrationRequest businessRegistrationRequest = JsonRequestPacketDeserializer::deserializeBusinessRegistrationRequest(request._buffer);

	if (_m_database.doesUsernameExists(businessRegistrationRequest._username))
	{
		throw std::invalid_argument(ERROR_USER_EXISTS);
	}
	else
		_m_database.createBusiness(businessRegistrationRequest);

	response._userId = _m_database.getUserId(businessRegistrationRequest._username, businessRegistrationRequest._password);
	response._storeName = _m_database.getBusinessName(response._userId);
	response._status = 1;
	result._response = JsonResponsePacketSerializer::serializeResponse(response);
	result._code = BUSINESSREGISTRATIONRESPONSE;

    _m_database.close();
	return result;
}

RequestResult IRequestHandler::addEmployee(Request request, SocketType socket)
{
	RequestResult result;
	AddEmployeeResponse response;
    
	AddEmployeeRequest add_employee = JsonRequestPacketDeserializer::deserializeAddEmployeeRequest(request._buffer);
    

    _m_database.open();
    if (_m_database.doesUserDirectorById(add_employee._userId))
    {
        if (_m_database.doesUsernameExists(add_employee._username))
        {
            throw std::invalid_argument(ERROR_USER_EXISTS);
        }
        else
            _m_database.addEmployee(add_employee);
    }
    else
        throw std::invalid_argument("You are not the manager");
    response._status = SUCCEED;
	result._response = JsonResponsePacketSerializer::serializeResponse(response);
	result._code = ADDEMPLOYEERESPONSE;

    _m_database.close();
	return result;
}


RequestResult IRequestHandler::uploadReceipt(Request request, SocketType socket)
{
	RequestResult result;
	UploadReceiptResponse response;
	
    _m_database.open();
	UploadReceiptRequest upload_Receipt = JsonRequestPacketDeserializer::deserializeUploadReceiptRequest(request._buffer);
	_m_database.uploadReceipt(upload_Receipt);
	response._status = SUCCEED;

    _m_database.close();
	result._response = JsonResponsePacketSerializer::serializeResponse(response);
	result._code = UPLOADRECEIPTRESPONSE;

	return result;
}


RequestResult IRequestHandler::getEmployeeList(Request request, SocketType socket)
{
	RequestResult result;
	GetEmployeeListResponse response;

	GetEmployeeListRequest getEmployeeList = JsonRequestPacketDeserializer::deserializeGetEmployeeListRequest(request._buffer);

    _m_database.open();
	response._employeeList = _m_database.getEmployeeList(getEmployeeList);
	result._response = JsonResponsePacketSerializer::serializeResponse(response);
	result._code = GETEMPLOYEELISTRESPONSE;

    _m_database.close();
	return result;
}

RequestResult IRequestHandler::deleteReceipt(Request request, SocketType socket)
{
	RequestResult result;
	DeleteReceiptResponse response;

	DeleteReceiptRequest deleteReceipt = JsonRequestPacketDeserializer::deserializeDeleteReceiptRequest(request._buffer);

   //_m_database.open();
	//_m_database.deleteReceipt(deleteReceipt);
	response._status = SUCCEED;
	result._response = JsonResponsePacketSerializer::serializeResponse(response);
	result._code = DELETERECEIPTRESPONSE;

    //_m_database.close();
	return result;
}


RequestResult IRequestHandler::removeEmployee(Request request, SocketType socket)
{
	RequestResult result;
	RemoveEmployeeResponse response;

	RemoveEmployeeRequest removeEmployee = JsonRequestPacketDeserializer::deserializeRemoveEmployeeRequest(request._buffer);

    _m_database.open();
	_m_database.removeEmployee(removeEmployee);
	response._status = SUCCEED;

	result._response = JsonResponsePacketSerializer::serializeResponse(response);
	result._code = REMOVEEMPLOYEERESPONS;

    _m_database.close();
	return result;
}

RequestResult IRequestHandler::getReceiptList(Request request, SocketType socket)
{
	RequestResult result;
	GetReceiptListResponse response;

	GetReceiptListRequest getReceiptList = JsonRequestPacketDeserializer::deserializeGetReceiptListRequest(request._buffer);

    _m_database.open();
	response._receiptList = _m_database.getReceiptList(getReceiptList);
    _m_database.close();
    
	result._response = JsonResponsePacketSerializer::serializeResponse(response);
	result._code = GETRECEIPTLISTRESPONSE;

	return result;
}


