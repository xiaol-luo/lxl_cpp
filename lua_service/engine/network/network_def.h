#pragma once
#include <stdint.h>

using NetId = uint64_t;
const static NetId INVALID_NET_ID = 0;

namespace Net
{
	// 长度描述所用字节数
	static const int PROTOCOL_LEN_DESCRIPT_SIZE = sizeof(uint32_t);
	static const int PROTOCOL_CONTENT_MAX_SIZE = 4096;
	static const int PROTOCOL_MAX_SIZE = PROTOCOL_LEN_DESCRIPT_SIZE + PROTOCOL_CONTENT_MAX_SIZE;

	static const int ERROR_NET_HANDLER_EXPIRED = 1;
	static const int ERROR_PEER_CLOSED = 2;
	static const int ERROR_WRITE_CLOSED_SOCKET = 3;
}
