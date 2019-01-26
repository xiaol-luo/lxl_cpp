#pragma once

#include <memory>
#include <unordered_map>
#include "network/i_network_handler.h"

class ActiveCnnHandlerMgr
{
public:
	bool AddCnn(std::shared_ptr<INetConnectHander> cnn);
	void RemoveCnn(NetId netid);

protected:
	std::unordered_map<NetId, std::shared_ptr<INetConnectHander> > m_cnns;
};
