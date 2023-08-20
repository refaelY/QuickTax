#pragma once
#include "json.hpp"
#include "RequestStruct.h"

#define USERNAME "_username"
#define NAME "_name"
#define PASSWORD "_password"
#define BUSINESSID "_businessId"
#define EMAIL "_email"
#define USERID "_userId"
#define REGISTRATIONDATE "_registrationDate"

using nlohmann::json;

class JsonRequestPacketDeserializer
{
public:
	static LoginRequest deserializeLoginRequest(const std::vector<std::uint8_t> buffer);
	static BusinessRegistrationRequest deserializeBusinessRegistrationRequest(const std::vector<std::uint8_t> buffer);
	static AddEmployeeRequest deserializeAddEmployeeRequest(const std::vector<std::uint8_t> buffer);
	static GetEmployeeListRequest deserializeGetEmployeeListRequest(const std::vector<std::uint8_t> buffer);
	static DeleteReceiptRequest deserializeDeleteReceiptRequest(const std::vector<std::uint8_t> buffer);
	static RemoveEmployeeRequest deserializeRemoveEmployeeRequest(const std::vector<std::uint8_t> buffer);
	static GetReceiptListRequest deserializeGetReceiptListRequest(const std::vector<std::uint8_t> buffer);
	static UploadReceiptRequest deserializeUploadReceiptRequest(const std::vector<std::uint8_t> buffer);


	
};
