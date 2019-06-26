#include "lua_reg.h"
#include "net_handler/lua_tcp_connect.h"
#include "net_handler/lua_tcp_listen.h"
#include "net_handler/common_listener.h"
#include "net_handler/common_cnn_handler.h"
#include "net_handler/http_rsp_cnn.h"
#include "net_handler/http_req_cnn.h"

void lua_reg_make_shared_ptr(lua_State *L)
{
	sol::main_table native_tb = get_or_create_table(L, TB_NATIVE);
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
		native_tb.set_function("make_shared_http_rsp_cnn", [](std::weak_ptr<NetHandlerMap<INetConnectHandler>> m) {
			return std::make_shared<HttpRspCnn>(m);
		});
		native_tb.set_function("make_shared_net_handler_map", []() {
			return std::make_shared<INetworkHandlerMap>();
		});
		native_tb.set_function("to_net_handler_map_weak_ptr", [](std::shared_ptr<INetworkHandlerMap> from) {
			std::weak_ptr<INetworkHandlerMap> to = from;
			return to;
		});

		native_tb.set_function("make_shared_cnn_handler_map", []() {
			return std::make_shared<INetCnnHandlerMap>();
		});
		native_tb.set_function("to_cnn_handler_map_weak_ptr", [](std::shared_ptr<INetCnnHandlerMap> from) {
			std::weak_ptr<INetCnnHandlerMap> to = from;
			return to;
		});


#define Net_Handler_Convert_Help(from, to) [](from p) { to ret = p; return ret; }
#define Convert_To_Net_Handler_Shared_Ptr(from) Net_Handler_Convert_Help(std::shared_ptr<from>, std::shared_ptr<INetworkHandler>)
#define Convert_To_Net_Handler_Weak_Ptr(from) Net_Handler_Convert_Help(std::shared_ptr<from>, std::weak_ptr<INetworkHandler>)
#define Convert_To_Cnn_Handler_Shared_Ptr(from) Net_Handler_Convert_Help(std::shared_ptr<from>, std::shared_ptr<INetConnectHandler>)
#define Convert_To_Cnn_Handler_Weak_Ptr(from) Net_Handler_Convert_Help(std::shared_ptr<from>, std::weak_ptr<INetConnectHandler>)
#define Convert_To_Listen_Handler_Shared_Ptr(from) Net_Handler_Convert_Help(std::shared_ptr<from>, std::shared_ptr<INetListenHandler>)
#define Convert_To_Listen_Handler_Weak_Ptr(from) Net_Handler_Convert_Help(std::shared_ptr<from>, std::weak_ptr<INetListenHandler>)

		// convert to INetHandler
		native_tb.set_function("to_net_handler_shared_ptr", sol::overload(
			Convert_To_Net_Handler_Shared_Ptr(LuaTcpConnect),
			Convert_To_Net_Handler_Shared_Ptr(HttpRspCnn),
			Convert_To_Net_Handler_Shared_Ptr(LuaTcpListen)
		));
		native_tb.set_function("to_net_handler_weak_ptr", sol::overload(
			Convert_To_Net_Handler_Weak_Ptr(LuaTcpConnect),
			Convert_To_Net_Handler_Weak_Ptr(HttpRspCnn),
			Convert_To_Net_Handler_Weak_Ptr(LuaTcpListen)
		));

		// convert to ICnnHandler
		native_tb.set_function("to_connect_handler_shared_ptr", sol::overload(
			Convert_To_Cnn_Handler_Shared_Ptr(LuaTcpConnect),
			Convert_To_Cnn_Handler_Shared_Ptr(HttpRspCnn)
		));
		native_tb.set_function("to_connect_handler_weak_ptr", sol::overload(
			Convert_To_Cnn_Handler_Weak_Ptr(LuaTcpConnect),
			Convert_To_Cnn_Handler_Weak_Ptr(HttpRspCnn)
		));

		// convert to IListenHandler
		native_tb.set_function("to_listen_handler_shared_ptr", sol::overload(
			Convert_To_Listen_Handler_Shared_Ptr(LuaTcpListen)
		));

		native_tb.set_function("to_listen_handler_weak_ptr", sol::overload(
			Convert_To_Listen_Handler_Weak_Ptr(LuaTcpListen)
		));

		/////

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