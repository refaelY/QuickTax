#include "HeaderFiles/JsonResponsePacketSerializer.h"


std::vector<std::uint8_t> JsonResponsePacketSerializer::serializeResponse(const ErrorResponse& packet)//
{
	json j{ { MSG, packet._message } };
	std::vector<std::uint8_t> ans = toBite(j.dump());

	return ans;
}

std::vector<std::uint8_t> JsonResponsePacketSerializer::serializeResponse(const LoginResponse& packet)//
{
	json j{ { STATUS, packet._status } };

	std::vector<std::uint8_t> ans = toBite(j.dump());
	return ans;
}


std::vector<std::uint8_t> JsonResponsePacketSerializer::serializeResponse(const AddEmployeeResponse& packet)//
{
	json j{ { STATUS, packet._status } };

	std::vector<std::uint8_t> ans = toBite(j.dump());
	return ans;
}


std::vector<std::uint8_t> JsonResponsePacketSerializer::serializeResponse(const UploadReceiptResponse& packet)
{
	json j{ { STATUS, packet._status } };

	std::vector<std::uint8_t> ans = toBite(j.dump());
	return ans;
}
std::vector<std::uint8_t> JsonResponsePacketSerializer::serializeResponse(const GetEmployeeListResponse& packet)
{
	json j;

	for (const auto& employee : packet._employeeList) {
		json res;

		for (const auto& receipt : employee._receipts) {
			json receipts = {
				{ "_id", receipt._id },
				{ "_userId", receipt._userId },
				{ "_storeName", receipt._storeName },
				{ "_amount", receipt._amount },
				{ "_dateTime", receipt._dateTime }
			};
			res.push_back(receipts);
		}

		json employeeJson = {
			{ "_userId", employee._userId },
			{ "_userName", employee._userName },
			{ "_storeName", employee._storeName },
			{ "_receipts", res }
		};
		j.push_back(employeeJson);
	}

	std::vector<std::uint8_t> ans(j.dump().begin(), j.dump().end());
	return ans;
}




std::vector<std::uint8_t> JsonResponsePacketSerializer::serializeResponse(const DeleteReceiptResponse& packet)
{
	json j{ { STATUS, packet._status } };

	std::vector<std::uint8_t> ans = toBite(j.dump());
	return ans;
}

std::vector<std::uint8_t> JsonResponsePacketSerializer::serializeResponse(const RemoveEmployeeResponse& packet)
{
	json j{ { STATUS, packet._status } };

	std::vector<std::uint8_t> ans = toBite(j.dump());
	return ans;
}

std::vector<std::uint8_t> JsonResponsePacketSerializer::serializeResponse(const GetReceiptListResponse& packet)
{
	json j;
	for (const auto& receipt : packet._receiptList) {
		json receiptJson = {
			{ "_id", receipt._id },
			{ "_userId", receipt._userId },
			{ "_storeName", receipt._storeName },
			{ "_amount", receipt._amount },
			{ "_dateTime", receipt._dateTime }
		};
		j.push_back(receiptJson);
	}

	std::vector<std::uint8_t> ans(j.dump().begin(), j.dump().end());
	return ans;
}


std::vector<std::uint8_t> JsonResponsePacketSerializer::toBite(std::string temp)
{
	std::vector<std::uint8_t> ans;

	for (int i = 0; i < temp.size(); i++)
		ans.push_back(temp[i]);
	return ans;
}
