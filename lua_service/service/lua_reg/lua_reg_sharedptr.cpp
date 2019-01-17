#include "lua_reg.h"
#include <net/lua_tcp_connect.h>
#include <net/lua_tcp_listen.h>

void lua_reg_make_shared_ptr(lua_State *L)
{
	sol::table native_tb = get_or_create_table(L, TB_NATIVE);
	{
		native_tb.set_function("make_shared_lua_tcp_connect", []() { 
			return std::make_shared<LuaTcpConnect>(); 
		});
		native_tb.set_function("make_shared_lua_tcp_listen", []() { 
			return std::make_shared<LuaTcpListen>(); 
		});

		native_tb.set_function("to_weak_ptr_net_handler", sol::overload(
			[](std::shared_ptr<LuaTcpListen> p) { std::weak_ptr<INetworkHandler> ret = p; return ret; },
			[](std::shared_ptr<LuaTcpConnect> p) { std::weak_ptr<INetworkHandler> ret = p; return ret; }
		));
		native_tb.set_function("to_weak_ptr_net_listen", sol::overload(
			[](std::shared_ptr<LuaTcpListen> p) { std::weak_ptr<INetListenHander> ret = p; return ret; }
		));
		native_tb.set_function("to_weak_ptr_net_connect", sol::overload(
			[](std::shared_ptr<LuaTcpConnect> p) { std::weak_ptr<INetConnectHander> ret = p; return ret; }
		));
	}
}