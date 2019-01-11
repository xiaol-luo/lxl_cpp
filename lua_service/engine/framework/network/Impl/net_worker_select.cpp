#include "net_worker_select.h"
#ifdef WIN32
#include <winsock2.h>
#else
#include <sys/select.h>
#endif

namespace Net
{
	NetWorkerSelect::NetWorkerSelect()
	{
	}

	NetWorkerSelect::~NetWorkerSelect()
	{
	}

	bool NetWorkerSelect::AddCnn(NetId id, int fd, std::shared_ptr<INetworkHandler> handler)
	{
		if (nullptr == handler || fd < 0)
			return false;

		bool ret = false;
		m_new_nodes_mutex.lock();
		if (m_new_nodes.count(id) <= 0)
		{
			ret = true;
			Node *node = new Node();
			node->handler = handler;
			node->fd = fd;
			node->handler_type = handler->HandlerType();
			m_new_nodes.insert(std::make_pair(id, node));
		}
		m_new_nodes_mutex.unlock();
		return ret;
	}

	void NetWorkerSelect::RemoveCnn(NetId id)
	{
		m_to_remove_netids_mutex.lock();
		m_to_remove_netids.insert(id);
		m_to_remove_netids_mutex.unlock();
	}

	bool NetWorkerSelect::Send(NetId netId, char * buffer, uint32_t len)
	{
		if (nullptr == buffer || len <= 0)
			return false;

		bool ret = false;
		bool hited = false;
		if (!hited)
		{
			m_net_datas_mutex.lock();
			auto it = m_id2nodes.find(netId);
			if (m_id2nodes.end() != it)
			{
				hited = true;
				ret = it->second->AddSendBuff(buffer, len);
			}
			m_net_datas_mutex.unlock();
		}
		if (!hited)
		{
			m_new_nodes_mutex.lock();
			auto it = m_new_nodes.find(netId);
			if (m_new_nodes.end() != it)
			{
				hited = true;
				ret = it->second->AddSendBuff(buffer, len);
			}
			m_new_nodes_mutex.unlock();
		}
		return ret;
	}

	bool NetWorkerSelect::GetNetDatas(std::queue<NetworkData*>** out_datas)
	{
		if (nullptr == out_datas)
			return false;

		m_net_datas_mutex.lock();
		*out_datas = &m_net_datas[m_net_datas_using_idx];
		m_net_datas_using_idx = (m_net_datas_using_idx + 1) % Net_Data_Queue_Size;
		m_new_nodes_mutex.unlock();
		return true;
	}

	bool NetWorkerSelect::Start()
	{
		if (m_is_started || nullptr != m_work_thread)
			return false;

		m_work_thread = new std::thread(&NetWorkerSelect::WorkLoop, this);
		m_is_started = true;
		return false;
	}

	void NetWorkerSelect::Stop()
	{
		m_is_exits = true;
		m_work_thread->join();
	}

	void NetWorkerSelect::WorkLoop(NetWorkerSelect * self)
	{
		int max_fd = -1;
		fd_set read_set, write_set, error_set;
		timeval timeout_tv; 
		timeout_tv.tv_sec = 0; 
		timeout_tv.tv_usec = 50 * 1000; // 50ºÁÃë
		while (!self->m_is_exits)
		{
			select(&read_set, &write_set, &error_set, )
		}
	}

	bool NetWorkerSelect::Node::AddSendBuff(char * buff, uint32_t buff_len)
	{
		return false;
	}
}