#pragma once

const static char * LUA_LISTEN_CB_ONCLOSE = "on_close";
const static char * LUA_LISTEN_CB_ONOPEN = "on_open";
const static char * LUA_LISTEN_GEN_CNN = "gen_connection";

#include "network/i_network_handler.h"
#include <sol/sol.hpp>

class LuaTcpListen : public INetListenHander
{

public:
	LuaTcpListen(sol::table lua_logic);
	virtual ~LuaTcpListen();

	virtual void OnClose(int err_num) override;
	virtual void OnOpen(int err_num) override;
	virtual std::shared_ptr<INetConnectHander> GenConnectorHandler() override;

protected:
	sol::table m_lua_logic;
};