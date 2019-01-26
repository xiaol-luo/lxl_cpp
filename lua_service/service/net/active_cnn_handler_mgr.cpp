#pragma once

#include "active_cnn_handler_mgr.h"

bool ActiveCnnHandlerMgr::AddCnn(std::shared_ptr<INetConnectHander> cnn)
{
	if (nullptr == cnn || cnn->GetNetId() <= 0 || m_cnns.end() != m_cnns.find(cnn->GetNetId()))
		return false;
	m_cnns.insert(std::make_pair(cnn->GetNetId(), cnn));
	return true;
}

void ActiveCnnHandlerMgr::RemoveCnn(NetId netid)
{
	m_cnns.erase(netid);
}
