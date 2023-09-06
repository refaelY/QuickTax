#pragma once
#include <iostream>
#include <vector>
#include "json.hpp"
#include "ResponseStruct.h"

#define STATUS "_status"
#define MSG "_message"

using nlohmann::json;





class JsonResponsePacketSerializer
{
private:
	static std::vector<std::uint8_t> toBite(std::string temp);

public:
	static std::vector<std::uint8_t> serializeResponse(const ErrorResponse& packet);
	static std::vector<std::uint8_t> serializeResponse(const LoginResponse& packet);
	static std::vector<std::uint8_t> serializeResponse(const AddEmployeeResponse& packet);
	static std::vector<std::uint8_t> serializeResponse(const UploadReceiptResponse& packet);
	static std::vector<std::uint8_t> serializeResponse(const GetEmployeeListResponse& packet);
	static std::vector<std::uint8_t> serializeResponse(const DeleteReceiptResponse& packet);
	static std::vector<std::uint8_t> serializeResponse(const RemoveEmployeeResponse& packet);
	static std::vector<std::uint8_t> serializeResponse(const GetReceiptListResponse& packet);
    static std::vector<std::uint8_t> serializeResponse(const GetImgResponse& packet);
};
