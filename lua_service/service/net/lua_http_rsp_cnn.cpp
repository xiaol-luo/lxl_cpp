
#include "lua_http_rsp_cnn.h"


LuaHttpRspCnn::LuaHttpRspCnn(std::weak_ptr<NetHandlerMap<INetConnectHandler>> cnn_map) : HttpRspCnn(cnn_map)
{
}

LuaHttpRspCnn::~LuaHttpRspCnn()
{

}

void LuaHttpRspCnn::SetProcessFn(sol::function process_fn, sol::object param)
{
	m_process_req_fn = process_fn;
	m_process_req_param = param;
}
