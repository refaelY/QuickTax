#include "HeaderFiles/JsonRequestPacketDeserializer.h"


LoginRequest JsonRequestPacketDeserializer::deserializeLoginRequest(const std::vector<std::uint8_t> buffer)
{
	LoginRequest login;
	json j = json::parse(buffer);

	login._username = j.at(USERNAME).get<std::string>();
	login._password = j.at(PASSWORD).get<std::string>();

	return login;
}

BusinessRegistrationRequest JsonRequestPacketDeserializer::deserializeBusinessRegistrationRequest(const std::vector<std::uint8_t> buffer)
{
	BusinessRegistrationRequest signup;
	json j = json::parse(buffer);

	signup._businessId = j.at(BUSINESSID).get<int>();
	signup._name = j.at(NAME).get<std::string>();
	signup._password = j.at(PASSWORD).get<std::string>();
	signup._registrationDate = j.at(REGISTRATIONDATE).get<std::string>();
	signup._username = j.at(USERNAME).get<std::string>();

	return signup;
}

AddEmployeeRequest JsonRequestPacketDeserializer::deserializeAddEmployeeRequest(const std::vector<std::uint8_t> buffer)
{
	AddEmployeeRequest addEmployee;
	json j = json::parse(buffer);

	addEmployee._username = j.at(USERNAME).get<std::string>();
	addEmployee._password = j.at(PASSWORD).get<std::string>();
	addEmployee._userId = j.at("_userId").get<int>();

	return addEmployee;
}

GetEmployeeListRequest JsonRequestPacketDeserializer::deserializeGetEmployeeListRequest(const std::vector<std::uint8_t> buffer)
{
	GetEmployeeListRequest request;
	json j = json::parse(buffer);

	request._userId = j.at(USERID).get<int>();
	

	return request;
}


DeleteReceiptRequest JsonRequestPacketDeserializer::deserializeDeleteReceiptRequest(const std::vector<std::uint8_t> buffer)
{
	DeleteReceiptRequest request;
	json j = json::parse(buffer);

	int id = j.at("receipt").at("_id");
	int userId = j.at("receipt").at("_userId");
	std::string storeName = j.at("receipt").at("_storeName");
	double amount = j.at("receipt").at("_amount");
	std::string dateTime = j.at("receipt").at("_dateTime");

	request._receipt = Receipt{ id, userId, storeName, amount, dateTime };

	return request;
}

RemoveEmployeeRequest JsonRequestPacketDeserializer::deserializeRemoveEmployeeRequest(const std::vector<std::uint8_t> buffer)
{
	RemoveEmployeeRequest request;
	json j = json::parse(buffer);

	request._managerId = j.at("_managerId").get<int>();
	request._userId = j.at(USERID).get<int>();


	return request;
}

GetReceiptListRequest JsonRequestPacketDeserializer::deserializeGetReceiptListRequest(const std::vector<std::uint8_t> buffer)
{
	GetReceiptListRequest request;
	json j = json::parse(buffer);

	request._userId = j.at(USERID).get<int>();


	return request;
}


UploadReceiptRequest JsonRequestPacketDeserializer::deserializeUploadReceiptRequest(const std::vector<std::uint8_t> buffer)
{
	UploadReceiptRequest request;
	json j = json::parse(buffer);

	int id = j.at("receipt").at("_id");
	int userId = j.at("receipt").at("_userId");
	std::string storeName = j.at("receipt").at("_storeName");
	double amount = j.at("receipt").at("_amount");
	std::string dateTime = j.at("receipt").at("_dateTime");

	request._receipt = Receipt{ id, userId, storeName, amount, dateTime };

	return request;
}



