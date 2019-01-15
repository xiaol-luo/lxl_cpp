#include "lua_tcp_listen.h"

LuaTcpListen::LuaTcpListen(sol::table lua_logic)
{
}

LuaTcpListen::~LuaTcpListen()
{
}

void LuaTcpListen::OnClose(int err_num)
{
}

void LuaTcpListen::OnOpen(int err_num)
{
}

std::shared_ptr<INetConnectHander> LuaTcpListen::GenConnectorHandler()
{
	return std::shared_ptr<INetConnectHander>();
}
