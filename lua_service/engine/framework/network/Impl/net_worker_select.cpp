#include "net_worker_select.h"
#ifdef WIN32
#include <winsock2.h>
#else
#include <sys/select.h>
#endif

#ifdef WIN32
#include <winsock2.h>
#define close closesocket
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
		if (m_is_exits)
			return false;

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
		if (m_is_exits)
			return false;

		if (nullptr == buffer || len <= 0)
			return false;

		m_wait_send_buffs_mutex.lock();
		auto it = m_wait_send_buffs.find(netId);
		if (m_wait_send_buffs.end() == it)
		{
			NetBuffer *buff = new NetBuffer(256, 64);
			auto ret = m_wait_send_buffs.insert(std::make_pair(netId, buff));
			if (!ret.second)
			{
				delete buff; buff = nullptr;
				return false;
			}
			it = ret.first;
		}
		NetBuffer *buff = it->second;
		buff->AppendBuff(buffer, len);
		m_wait_send_buffs_mutex.unlock();
		return true;
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

		// 所有东西在这里销毁一下
	}

	void NetWorkerSelect::WorkLoop(NetWorkerSelect * self)
	{
		int max_fd = -1;
		fd_set read_set, write_set, error_set;
		timeval timeout_tv; 
		timeout_tv.tv_sec = 0; 
		timeout_tv.tv_usec = 50 * 1000; // 50毫秒
		while (!self->m_is_exits)
		{
			WorkLoop_SendBuff(self);
			{
				max_fd = -1;
				// 设置fd_set
				for (auto kv : self->m_id2nodes)
				{
					Node *node = kv.second;
					if (node->closed || node->fd < 0)
						continue;
					bool is_set = false;
					FD_SET(node->fd, &read_set);
					FD_SET(node->fd, &error_set);
					if (!node->send_buffs.empty())
					{
						FD_SET(node->fd, &write_set);
					}
					if (node->fd > max_fd)
					{
						max_fd = node->fd;
					}
				}
			}
			int ret = select(max_fd, &read_set, &write_set, &error_set, &timeout_tv) > 0;
			if (ret > 0)
			{
				int hited_count = 0;
				for (int i = 0; i < max_fd; ++ i)
				{
					bool hited = false;
					if (FD_ISSET(i, &read_set))
					{
						hited = true;
						self->HandleNetRead(i);
					}
					if (FD_ISSET(i, &error_set))
					{
						self->HandleNetError(i);
						hited = true;
					}
					if (FD_ISSET(i, &write_set))
					{
						hited = true;
						self->HandleNetWrite(i);
					}
					if (hited)
					{
						++hited_count;
						if (hited_count > ret)
						{
							break;
						}
					}
				}
			}
			WorkLoop_AddConn(self);
			WorkLoop_RemoveConn(self);
		}
		self->m_to_remove_netids_mutex.lock();
		for (auto kv : self->m_id2nodes)
		{
			self->m_to_remove_netids.insert(kv.first);
		}
		self->m_to_remove_netids_mutex.unlock();
		WorkLoop_AddConn(self);
		WorkLoop_RemoveConn(self);
		WorkLoop_SendBuff(self);
	}

	void NetWorkerSelect::WorkLoop_AddConn(NetWorkerSelect * self)
	{
		// 加入节点
		self->m_new_nodes_mutex.lock();
		std::unordered_map<NetId, Node *> new_nodes(self->m_new_nodes.begin(), self->m_new_nodes.end());
		self->m_new_nodes.clear();
		self->m_new_nodes_mutex.unlock();
		for (auto kv : new_nodes)
		{
			self->m_id2nodes.insert(kv);
		}
	}

	void NetWorkerSelect::WorkLoop_RemoveConn(NetWorkerSelect * self)
	{
		// 删除节点
		self->m_to_remove_netids_mutex.lock();
		std::set<NetId> to_remove_netids(self->m_to_remove_netids.begin(), self->m_to_remove_netids.end());
		self->m_to_remove_netids.clear();
		self->m_to_remove_netids_mutex.unlock();
		for (auto netid : to_remove_netids)
		{
			{
				auto it = self->m_id2nodes.find(netid);
				if (it != self->m_id2nodes.end())
				{
					Node *node = it->second;
					self->m_id2nodes.erase(it);
					it = self->m_id2nodes.end();
					if (!node->closed && node->fd >= 0)
					{
						node->closed = true;
						close(node->fd);
						node->fd = -1;
					}
					NetworkData *network_data = new NetworkData(node->handler_type,
						node->netid, node->fd, node->handler, ENetWorkDataAction_Close,
						0, -1, nullptr);
					self->AddNetworkData(network_data);
					while (!node->send_buffs.empty())
					{
						delete node->send_buffs.front();
						node->send_buffs.pop();
					}
					delete node; node = nullptr;
				}
			}
			{
				self->m_wait_send_buffs_mutex.lock();
				auto it = self->m_wait_send_buffs.find(netid);
				if (self->m_wait_send_buffs.end() != it)
				{
					delete it->second;
					self->m_wait_send_buffs.erase(it);
				}
				self->m_wait_send_buffs_mutex.unlock();
			}
		}
	}

	void NetWorkerSelect::WorkLoop_SendBuff(NetWorkerSelect * self)
	{
		// 处理将要被发送的NetBuffer
		self->m_wait_send_buffs_mutex.lock();
		std::unordered_map<NetId, NetBuffer *> wait_send_buffs(self->m_wait_send_buffs.begin(), self->m_wait_send_buffs.end());
		self->m_wait_send_buffs.clear();
		self->m_wait_send_buffs_mutex.unlock();
		for (auto kv : wait_send_buffs)
		{
			auto it = self->m_id2nodes.find(kv.first);
			if (self->m_id2nodes.end() == it)
			{
				delete kv.second;
			}
			else
			{
				it->second->AddSendBuff(kv.second);
			}
		}
	}

	void NetWorkerSelect::HandleNetRead(int fd)
	{
		Node *node = this->GetNodeByFd(fd);
		if (nullptr == node)
			return;

		if (ENetworkHandler_Connect == node->handler_type)
		{
			NetBuffer *buff = new NetBuffer(64, 32);
			int err_num = 0;
			buff->ReadFd(fd, UINT32_MAX, &err_num);
			this->AddNetworkData(new NetworkData(
				node->handler_type,
				node->netid, 
				node->fd, 
				node->handler, 
				ENetWorkDataAction_Read, 
				err_num,
				-1,
				buff));
		}
		if (ENetworkHandler_Listen == node->handler_type)
		{

		}
	}

	void NetWorkerSelect::HandleNetWrite(int fd)
	{
		Node *node = this->GetNodeByFd(fd);
		if (nullptr == node)
			return;

		if (ENetworkHandler_Connect == node->handler_type)
		{

		}
		if (ENetworkHandler_Listen == node->handler_type)
		{

		}
	}

	void NetWorkerSelect::HandleNetError(int fd)
	{
		Node *node = this->GetNodeByFd(fd);
		if (nullptr == node)
			return;

		if (ENetworkHandler_Connect == node->handler_type)
		{

		}
		if (ENetworkHandler_Listen == node->handler_type)
		{

		}
	}

	NetWorkerSelect::Node * NetWorkerSelect::GetNodeByFd(int fd)
	{
		// TODO: 优化
		for (auto kv : m_id2nodes)
		{
			if (kv.second->fd == fd)
			{
				return kv.second;
			}
		}
		return nullptr;
	}

	void NetWorkerSelect::AddNetworkData(NetworkData * data)
	{
		m_net_datas_mutex.lock();
		m_net_datas[m_net_datas_using_idx].push(data);
		m_net_datas_mutex.unlock();
	}

	void NetWorkerSelect::Node::AddSendBuff(NetBuffer *net_buffer)
	{
		send_buffs.push(net_buffer);
	}
}