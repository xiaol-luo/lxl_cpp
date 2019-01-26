#pragma once

#include <memory>
#include <unordered_map>
#include "network/i_network_handler.h"

class IAcceptCnnHandlerMgr : public INetListenHander
{
public:
	virtual bool AddCnn(std::shared_ptr<INetConnectHander> cnn) = 0;
	virtual void RemoveCnn(NetId netid) = 0;
};

template<typename CnnHandler>
class AcceptCnnHandlerMgr : public IAcceptCnnHandlerMgr
{
public:
	AcceptCnnHandlerMgr()
	{
		
	}

	~AcceptCnnHandlerMgr()
	{
		m_cnns.clear();
	}

	virtual void OnClose(int err_num) override
	{
		if (err_num)
		{
			log_error("AcceptCnnHandlerMgr OnClose", err_num);
		}
	}
	virtual void OnOpen(int err_num) override
	{
		if (err_num)
		{
			log_error("AcceptCnnHandlerMgr OnOpen Fail", err_num);
		}
		else
		{
			log_debug("AcceptCnnHandlerMgr::OnOpen");
		}
	}

	virtual std::shared_ptr<INetConnectHander> GenConnectorHandler() override
	{
		auto handler = std::make_shared<CnnHandler>(this->GetSharedPtr<AcceptCnnHandlerMgr>());
		return handler;
	}

	bool AddCnn(std::shared_ptr<INetConnectHander> cnn) override
	{
		if (nullptr == cnn || cnn->GetNetId() <= 0 || m_cnns.end() != m_cnns.find(cnn->GetNetId()))
			return false;
		m_cnns.insert(std::make_pair(cnn->GetNetId(), cnn));
		return true;
	}

	void RemoveCnn(NetId netid) override
	{
		m_cnns.erase(netid);
	}

protected:
	std::unordered_map<NetId, std::shared_ptr<INetConnectHander> > m_cnns;
};