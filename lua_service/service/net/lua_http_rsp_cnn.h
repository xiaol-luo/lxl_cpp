#pragma once

#include "http_rsp_cnn.h"
#include <sol/sol.hpp>

class LuaHttpRspCnn : public HttpRspCnn
{
	LuaHttpRspCnn(std::weak_ptr<IAcceptCnnHandlerMgr> mgr);
	virtual ~LuaHttpRspCnn();

	virtual int ProcessReq() override;
	void SetHandleReqFn(sol::function process_fn, sol::object param);

protected:
	sol::function m_process_req_fn;
	sol::object m_process_req_param;
};