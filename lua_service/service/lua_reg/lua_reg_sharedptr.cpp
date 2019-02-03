#include "lua_reg.h"
#include "net_handler/lua_tcp_connect.h"
#include "net_handler/lua_tcp_listen.h"
#include "net_handler/common_listener.h"
#include "net_handler/common_cnn_handler.h"
#include "net_handler/http_rsp_cnn.h"
#include "net_handler/http_req_cnn.h"

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
		native_tb.set_function("make_shared_common_listener", []() {
			return std::make_shared<CommonListener>();
		});
		native_tb.set_function("make_shared_http_rsp_cnn", 
			[](std::weak_ptr<NetHandlerMap<INetConnectHandler>> m) {
			return std::make_shared<HttpRspCnn>(m);
		});

		native_tb.set_function("to_shared_ptr_net_connect", sol::overload(
			[](std::shared_ptr<HttpRspCnn> p) { std::shared_ptr<INetConnectHandler> ret = p; return ret; }
		));

		native_tb.set_function("to_weak_ptr_net_handler", sol::overload(
			[](std::shared_ptr<LuaTcpListen> p) { std::weak_ptr<INetworkHandler> ret = p; return ret; },
			[](std::shared_ptr<LuaTcpConnect> p) { std::weak_ptr<INetworkHandler> ret = p; return ret; }
		));
		native_tb.set_function("to_weak_ptr_net_listen", sol::overload(
			[](std::shared_ptr<LuaTcpListen> p) { std::weak_ptr<INetListenHandler> ret = p; return ret; },
			[](std::shared_ptr<CommonListener> p) { std::weak_ptr<INetListenHandler> ret = p; return ret; }
		));
		native_tb.set_function("to_weak_ptr_net_connect", sol::overload(
			[](std::shared_ptr<LuaTcpConnect> p) { std::weak_ptr<INetConnectHandler> ret = p; return ret; },
			[](std::shared_ptr<HttpRspCnn> p) { std::weak_ptr<INetConnectHandler> ret = p; return ret; }
		));
	}
}