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
		std::string class_name = "INetConnectHandler";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<INetConnectHandler> meta_table(
			sol::base_classes, sol::bases<INetworkHandler>(),
			"on_recv", &INetConnectHandler::OnRecvData
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		std::string class_name = "INetListenHandler";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<INetListenHandler> meta_table(
			sol::base_classes, sol::bases<INetworkHandler>(),
			"gen_cnn", &INetListenHandler::GenConnectorHandler
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		std::string class_name = "LuaTcpConnect";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<LuaTcpConnect> meta_table(
			sol::constructors<LuaTcpConnect()>(),
			sol::base_classes, sol::bases<INetConnectHandler, INetworkHandler>(),
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
			sol::base_classes, sol::bases<INetListenHandler, INetworkHandler>(),
			"init", &LuaTcpListen::Init
		);
		native_tb.set_usertype(class_name, meta_table);
	}
}
