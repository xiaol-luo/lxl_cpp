#pragma once

#include "network/i_network_handler.h"
#include <unordered_map>
#include "http_rsp_cnn.h"

class HttpRspCnnMgr : public INetListenHander
{
public:
	HttpRspCnnMgr();
	virtual ~HttpRspCnnMgr();
	virtual void OnClose(int err_num) override;
	virtual void OnOpen(int err_num) override;
	virtual std::shared_ptr<INetConnectHander> GenConnectorHandler() override;

	virtual bool AddRspCnn(std::shared_ptr<HttpRspCnn> cnn);
	virtual void RemoveRspCnn(NetId netid);

protected:
	std::unordered_map<NetId, std::shared_ptr<HttpRspCnn> > m_rsp_cnns;
};