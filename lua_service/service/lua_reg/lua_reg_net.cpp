#include "lua_reg.h"
#include "net_handler/lua_tcp_connect.h"
#include "net_handler/lua_tcp_listen.h"
#include "net_handler/common_listener.h"
#include "net_handler/common_cnn_handler.h"
#include "net_handler/http_rsp_cnn.h"
#include "net_handler/http_req_cnn.h"

static bool http_rsp_cnn__req_cb_fn(sol::protected_function lua_fn, HttpRspCnn * self, uint32_t method, std::string url, std::unordered_map<std::string, std::string> heads,
	std::string body, uint64_t body_len)
{
	bool ret = false;
	if (lua_fn.valid())
	{
		sol::protected_function_result pfr = lua_fn(self, method, url, sol::as_table(heads), body, body_len);
		if (pfr.valid() && pfr.return_count() > 0)
		{
			sol::type ret_type = pfr.get_type(0);
			if (sol::type::boolean == ret_type)
			{
				ret = pfr.get<bool>(0);
			}
		}
	}
	return ret;
}

static void wrap_http_rsp_cnn__set_req_cb_fn(HttpRspCnn &cnn, sol::protected_function lua_fn)
{
	cnn.SetReqCbFn(std::bind(http_rsp_cnn__req_cb_fn, lua_fn,
		std::placeholders::_1, std::placeholders::_2,
		std::placeholders::_3, std::placeholders::_4, 
		std::placeholders::_5, std::placeholders::_6));
}

void lua_reg_net(lua_State *L)
{
	sol::table native_tb = get_or_create_table(L, TB_NATIVE);
	{
		// INetworkHandler
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
		// INetConnectHandler
		std::string class_name = "INetConnectHandler";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<INetConnectHandler> meta_table(
			sol::base_classes, sol::bases<INetworkHandler>(),
			"on_recv", &INetConnectHandler::OnRecvData,
			"get_shared_ptr", &INetConnectHandler::GetSharedPtr,
			"get_ptr", &INetConnectHandler::GetPtr
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		// INetListenHandler
		std::string class_name = "INetListenHandler";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<INetListenHandler> meta_table(
			sol::base_classes, sol::bases<INetworkHandler>(),
			"gen_cnn", &INetListenHandler::GenConnectorHandler,
			"get_shared_ptr", &INetListenHandler::GetSharedPtr,
			"get_ptr", &INetListenHandler::GetPtr
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		// CommonListenCallback
		std::string class_name = "CommonListenCallback";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<CommonListenCallback> meta_table(
			"on_add_cnn", &CommonListenCallback::on_add_cnn,
			"on_remove_cnn", &CommonListenCallback::on_remove_cnn,
			"on_open", &CommonListenCallback::on_open,
			"on_close", &CommonListenCallback::on_close,
			"do_gen_cnn_handler", &CommonListenCallback::do_gen_cnn_handler
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		// CommonListener
		std::string class_name = "CommonListener";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<CommonListener> meta_table(
			sol::constructors<CommonListener()>(),
			sol::base_classes, sol::bases<INetListenHandler, INetworkHandler>(),
			"add_cnn", &CommonListener::AddCnn,
			"remove_cnn", &CommonListener::RemoveCnn,
			"listen", &CommonListener::Listen,
			"listen_async", &CommonListener::ListenAsync,
			"set_cb", &CommonListener::SetCb,
			"get_cnn_map", &CommonListener::GetCnnMap
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		// CommonCnnCallback
		std::string class_name = "CommonCnnCallback";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<CommonCnnCallback> meta_table(
			"on_open", &CommonCnnCallback::on_open,
			"on_close", &CommonCnnCallback::on_close,
			"on_recv", &CommonCnnCallback::on_recv
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		// CommonConnecter
		std::string class_name = "CommonConnecter";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<CommonConnecter> meta_table(
			sol::constructors<CommonConnecter()>(),
			sol::base_classes, sol::bases<INetConnectHandler, INetworkHandler>(),
			"set_cb", &CommonConnecter::SetCb
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
				[](LuaTcpConnect *self, uint32_t pid, const std::string &bin) { return self->Send(pid, bin); }
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
	{
		// HttpRspCnn
		std::string class_name = "HttpRspCnn";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<HttpRspCnn> meta_table(
			sol::constructors<HttpRspCnn(std::weak_ptr<NetHandlerMap<INetConnectHandler>>)>(),
			sol::base_classes, sol::bases<INetConnectHandler, INetworkHandler>(),
			"set_req_cb", wrap_http_rsp_cnn__set_req_cb_fn,
			"set_event_cb", &HttpRspCnn::SetEventCbFn
		);
		native_tb.set_usertype(class_name, meta_table);
	}
	{
		// HttpRspCnn
		std::string class_name = "HttpReqCnn";
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<HttpReqCnn> meta_table(
			sol::constructors<HttpReqCnn(std::weak_ptr<NetHandlerMap<INetConnectHandler>>)>(),
			sol::base_classes, sol::bases<INetConnectHandler, INetworkHandler>(),
			"set_req_cb", &HttpReqCnn::SetRspCbFn,
			"set_event_cb", &HttpReqCnn::SetEventCbFn,
			"set_req_data", &HttpReqCnn::SetReqData
		);
		native_tb.set_usertype(class_name, meta_table);
	}

	{
		std::string class_name = "INetworkHandlerMap";
		;
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<INetworkHandlerMap> meta_table(
			"add", &INetworkHandlerMap::Add,
			"remove", &INetworkHandlerMap::Remove,
			"clear", &INetworkHandlerMap::Clear
		);
		native_tb.set_usertype(class_name, meta_table);
	}

	{
		std::string class_name = "INetCnnHandlerMap";
		;
		sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
		assert(!v.valid());
		sol::usertype<INetCnnHandlerMap> meta_table(
			"add", &INetCnnHandlerMap::Add,
			"remove", &INetCnnHandlerMap::Remove,
			"clear", &INetCnnHandlerMap::Clear
		);
		native_tb.set_usertype(class_name, meta_table);
	}
}
