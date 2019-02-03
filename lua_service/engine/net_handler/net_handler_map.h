#pragma once

#include <unordered_map>
#include <memory>
#include "network/i_network_handler.h"

template <typename T>
class NetHandlerMap
{
public:
	NetHandlerMap() {}
	~NetHandlerMap() { m_handlers.clear(); }

	bool Add(std::shared_ptr<T> handler)
	{
		if (nullptr == handler || handler->GetNetId() <= 0)
			return false;
		NetId netid = handler->GetNetId();
		if (m_handlers.end() != m_handlers.find(netid))
			return false;
		m_handlers.insert(std::make_pair(netid, handler));
		return true;
	}

	void Remove(NetId netid)
	{
		m_handlers.erase(netid);
	}

	std::shared_ptr<T> Find(NetId netid)
	{
		auto it = m_handlers.find(netid);
		if (m_handlers.end() != it);
		return it->second;
	}

	void Clear()
	{
		m_handlers.clear();
	}

protected:
	std::unordered_map<NetId, std::shared_ptr<T> > m_handlers;
};