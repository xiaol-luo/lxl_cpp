#include "lua_reg.h"
#include "net/lua_tcp_connect.h"
#include "net/lua_tcp_listen.h"

void lua_reg_net(lua_State *L)
{
	sol::table native_tb = get_or_create_table(L, TB_NATIVE);
	{
		std::string class_name = "INetworkHandler";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<INetworkHandler> meta_table(
			sol::base_classes, sol::bases<std::enable_shared_from_this<INetworkHandler>>(),
			"on_close", &INetworkHandler::OnClose, 
			"on_open", &INetworkHandler::OnOpen,
			"netid", sol::property(&INetworkHandler::GetNetId, &INetworkHandler::SetNetId),
			"handle_type", sol::property(&INetworkHandler::HandlerType)
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		std::string class_name = "INetConnectHander";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<INetConnectHander> meta_table(
			sol::base_classes, sol::bases<INetworkHandler>(),
			"on_recv", &INetConnectHander::OnRecvData
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		std::string class_name = "INetListenHander";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<INetListenHander> meta_table(
			sol::base_classes, sol::bases<INetworkHandler>(),
			"gen_cnn", &INetListenHander::GenConnectorHandler
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		std::string class_name = "LuaTcpConnect";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<LuaTcpConnect> meta_table(
			sol::constructors<LuaTcpConnect()>(),
			sol::base_classes, sol::bases<INetConnectHander, INetworkHandler>(),
			"init", &LuaTcpConnect::Init,
			"send", sol::overload(
				[](LuaTcpConnect *self, uint32_t pid) { return self->Send(pid); },
				[](LuaTcpConnect *self, uint32_t pid, std::string &bin) { return self->Send(pid, bin); }
			)
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		std::string class_name = "LuaTcpListen";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<LuaTcpListen> meta_table(
			sol::constructors<LuaTcpListen()>(),
			sol::base_classes, sol::bases<INetListenHander, INetworkHandler>(),
			"init", &LuaTcpListen::Init
		);
		native_tb.set_usertype(class_name, meta_table);
	}
}
