#include "lua_tcp_listen.h"

LuaTcpListen::LuaTcpListen()
{
}

LuaTcpListen::~LuaTcpListen()
{
}

bool LuaTcpListen::Init(sol::table lua_logic)
{
	if (!lua_logic.valid())
		return false;

	m_lua_logic = lua_logic;
	{
		sol::object fn = m_lua_logic.get<sol::object>(LUA_LISTEN_CB_ONCLOSE);
		assert(fn.is<sol::function>());
	}
	{
		sol::object fn = m_lua_logic.get<sol::object>(LUA_LISTEN_CB_ONOPEN);
		assert(fn.is<sol::function>());
	}
	{
		sol::object fn = m_lua_logic.get<sol::object>(LUA_LISTEN_GEN_CNN);
		assert(fn.is<sol::function>());
	}
	return true;
}

void LuaTcpListen::OnClose(int err_num)
{
	m_lua_logic[LUA_LISTEN_CB_ONCLOSE](err_num);
}

void LuaTcpListen::OnOpen(int err_num)
{
	m_lua_logic[LUA_LISTEN_CB_ONOPEN](err_num);
}

std::shared_ptr<INetConnectHander> LuaTcpListen::GenConnectorHandler()
{
	std::shared_ptr<INetConnectHander> ptr = nullptr;
	sol::object ret = m_lua_logic[LUA_LISTEN_GEN_CNN]();
	if (ret.valid() && ret.is<sol::userdata>())
	{
		sol::optional<std::shared_ptr<INetConnectHander>> maybe_cnn = ret.as<sol::optional<std::shared_ptr<INetConnectHander>>>();
		if (maybe_cnn)
		{
			std::shared_ptr < INetConnectHander> cnn = maybe_cnn.value();
			ptr = cnn;
		}
	}
	return ptr;
}
