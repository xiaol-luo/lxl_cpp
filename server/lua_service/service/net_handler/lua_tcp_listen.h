#pragma once

const static char * LUA_LISTEN_CB_ONCLOSE = "on_close";
const static char * LUA_LISTEN_CB_ONOPEN = "on_open";
const static char * LUA_LISTEN_GEN_CNN = "gen_cnn";

#include "network/i_network_handler.h"
#include "net_handler/net_handler_map.h"
#include <sol/sol.hpp>

class LuaTcpListen : public INetListenHandler
{

public:
	LuaTcpListen();
	virtual ~LuaTcpListen();

	bool Init(sol::main_table lua_logic);

	virtual void OnClose(int error_num) override;
	virtual void OnOpen(int error_num) override;
	virtual std::shared_ptr<INetConnectHandler> GenConnectorHandler() override;

protected:
	sol::main_table m_lua_logic;
};