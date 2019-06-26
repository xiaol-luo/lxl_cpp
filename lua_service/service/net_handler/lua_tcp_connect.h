#pragma once

const static char * LUA_CNN_CB_ONCLOSE = "on_close";
const static char * LUA_CNN_CB_ONOPEN = "on_open";
const static char * LUA_CNN_CB_ONRECV = "on_recv";

#include "network/i_network_handler.h"
#include <sol/sol.hpp>
#include "buffer/net_buffer.h"
#include "net_proto_splitter.h"

class LuaTcpConnect : public INetConnectHandler
{
public:
	LuaTcpConnect();
	virtual ~LuaTcpConnect();
	virtual void OnClose(int error_num) override;
	virtual void OnOpen(int error_num) override;
	virtual void OnRecvData(char *data, uint32_t len) override;

	bool Init(sol::main_table lua_logic);
	bool Send(uint32_t pid);
	bool Send(uint32_t pid, const std::string &data);

protected:
	sol::main_table m_lua_logic;
	NetBuffer *m_buff = nullptr;

	NetPidContentSplitter *m_pid_ctx_splitter;
};