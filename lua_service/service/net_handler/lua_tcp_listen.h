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

	bool Init(sol::table lua_logic);

	virtual void OnClose(int err_num) override;
	virtual void OnOpen(int err_num) override;
	virtual std::shared_ptr<INetConnectHandler> GenConnectorHandler() override;

	bool AddCnn(std::shared_ptr<INetConnectHandler> cnn);
	void RemoveCnn(NetId netid);

protected:
	sol::table m_lua_logic;
	std::shared_ptr<NetHandlerMap<INetConnectHandler>> m_cnn_map;
};