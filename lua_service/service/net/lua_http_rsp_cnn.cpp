#include "lua_http_rsp_cnn.h"

LuaHttpRspCnn::LuaHttpRspCnn(std::weak_ptr<IAcceptCnnHandlerMgr> mgr) : HttpRspCnn(mgr)
{

}

LuaHttpRspCnn::~LuaHttpRspCnn()
{

}

int LuaHttpRspCnn::ProcessReq()
{
	if (!m_process_req_fn.valid())
		return -1;

	unsigned int method = m_parser->method;
	m_process_req_fn.call(method, m_req_url, m_req_heads, m_req_body->HeadPtr(), m_process_req_param);
	return 0;
}

void LuaHttpRspCnn::SetHandleReqFn(sol::function process_fn, sol::object param)
{
	m_process_req_fn = process_fn;
	m_process_req_param = param;
}
