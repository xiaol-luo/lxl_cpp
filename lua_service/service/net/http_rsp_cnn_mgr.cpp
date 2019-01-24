#include "http_rsp_cnn_mgr.h"
#include "http_rsp_cnn.h"
#include "iengine.h"

HttpRspCnnMgr::HttpRspCnnMgr()
{
}

HttpRspCnnMgr::~HttpRspCnnMgr()
{
	m_rsp_cnns.clear();
}

void HttpRspCnnMgr::OnClose(int err_num)
{
	if (err_num)
	{
		log_error("HttpRspCnnMgr OnClose", err_num);
	}
}

void HttpRspCnnMgr::OnOpen(int err_num)
{
	if (err_num)
	{
		log_error("HttpRspCnnMgr OnOpen Fail", err_num);
	}
	else
	{
		log_debug("HttpRspCnnMgr::OnOpen");
	}
}

std::shared_ptr<INetConnectHander> HttpRspCnnMgr::GenConnectorHandler()
{
	 auto handler = std::make_shared<HttpRspCnn>(this->GetSharedPtr<HttpRspCnnMgr>());
	 return handler;
}

bool HttpRspCnnMgr::AddRspCnn(std::shared_ptr<HttpRspCnn> cnn)
{
	if (nullptr == cnn || cnn->GetNetId() <= 0 || m_rsp_cnns.end() != m_rsp_cnns.find(cnn->GetNetId()))
		return false;
	m_rsp_cnns.insert(std::make_pair(cnn->GetNetId(), cnn));
	return true;
}

void HttpRspCnnMgr::RemoveRspCnn(NetId netid)
{
	m_rsp_cnns.erase(netid);
}
