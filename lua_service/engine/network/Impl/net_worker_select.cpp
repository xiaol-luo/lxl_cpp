#include "net_worker_select.h"
#include <fcntl.h>
#ifdef WIN32
#include <winsock2.h>
#else
#include <sys/select.h>
#include <sys/socket.h>
#include <unistd.h>
#endif

#ifdef WIN32
#include <winsock2.h>
#define close closesocket
#define read(p1, p2, p3) recv(p1, p2, p3, 0)
#define write(p1, p2, p3) send(p1, p2, p3, 0)
#endif

#ifndef WIN32
int GetLastError()
{
	return errno;
}
#endif

#include "iengine.h"

namespace Net
{
	NetWorkerSelect::NetWorkerSelect()
	{
	}

	NetWorkerSelect::~NetWorkerSelect()
	{
		this->Stop();
	}

	bool NetWorkerSelect::AddCnn(NetId id, int fd, std::shared_ptr<INetworkHandler> handler)
	{
		if (fd < 0)
			return false;

		bool ret = false;
		do 
		{
			if (m_is_exits)
				break;
			if (nullptr == handler)
				break;

			int ret_int = this->MakeFdUnblock(fd);
			if (0 != ret_int)
			{
				// TODO: USE REAL LOG
				printf("MakeFdUnblock fail netid:%I64u, fd:%d, ret_int:%d, errno:%d", id, fd, ret_int, GetLastError());
				break;
			}
			m_new_nodes_mutex.lock();
			if (m_new_nodes.count(id) <= 0)
			{
				ret = true;
				Node *node = new Node();
				node->netid = id;
				node->handler = handler;
				node->fd = fd;
				node->handler_type = handler->HandlerType();
				m_new_nodes.insert(std::make_pair(id, node));
			}
			m_new_nodes_mutex.unlock();
			handler->SetNetId(id);

			ret = true;
		} while (false);
		if (!ret)
		{
			close(fd);
		}
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
			NetBuffer *buff = new NetBuffer(64, 64);
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
		m_net_datas_mutex.unlock();
		return true;
	}

	bool NetWorkerSelect::Start()
	{
		if (m_is_started || nullptr != m_work_thread)
			return false;

		m_work_thread = new std::thread(std::bind(&NetWorkerSelect::WorkLoop, this));
		m_is_started = true;
		return true;
	}

	void NetWorkerSelect::Stop()
	{
		m_is_exits = true;
		log_debug("NetWorkerSelect::Stop 1 {0}  {1}", m_is_exits, (char *)this);
		if (m_work_thread->joinable())
		{
			log_debug("NetWorkerSelect::Stop 3");
			m_work_thread->join();
			log_debug("NetWorkerSelect::Stop 4");
		}
		log_debug("NetWorkerSelect::Stop 5");

		// 所有东西在这里销毁一下

	}

#include <functional>
	void NetWorkerSelect::PrintExitValue()
	{
		log_debug("PrintExitValue {0}", m_is_exits);
	}

	void NetWorkerSelect::WorkLoop()
	{
		auto self = this;
		TimerID tid = add_firm_timer(std::bind(&NetWorkerSelect::PrintExitValue, self), 1000, -1);

		int max_fd = -1;
		fd_set read_set, write_set, err_set;
		timeval timeout_tv; 
		timeout_tv.tv_sec = 0; 
		timeout_tv.tv_usec = 50 * 1000; // 50毫秒

		int loop_times = 0;
		while (!self->m_is_exits)
		{
			WorkLoop_SendBuff();
			{
				max_fd = -1;
				FD_ZERO(&read_set);
				FD_ZERO(&write_set);
				FD_ZERO(&err_set);

				// 设置fd_set
				if (!self->m_id2nodes.empty())
				{
					for (auto kv : self->m_id2nodes)
					{
						Node *node = kv.second;
						if (node->closed || node->fd < 0)
							continue;

						FD_SET(node->fd, &read_set);
						FD_SET(node->fd, &err_set);
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
			}
			int ret = select(max_fd + 1, &read_set, &write_set, &err_set, &timeout_tv) > 0;
			if (ret > 0)
			{
				int hited_count = 0;
				for (int i = 0; i < max_fd; ++ i)
				{
					bool hited = false;
					// if (FD_ISSET(i, &read_set) || FD_ISSET(i, &err_set))
					{
						hited = true;
						self->HandleNetRead(i);
					}
					if (FD_ISSET(i, &write_set))
					{
						self->HandleNetWrite(i);
						hited = true;
					}
					if (hited)
					{
						++hited_count;
						if (hited_count > ret)
						{
							// break;
						}
					}
				}
			}
			WorkLoop_AddConn();
			WorkLoop_RemoveConn();
		}
		log_debug("select loop leave 2");
		self->m_to_remove_netids_mutex.lock();
		if (!self->m_to_remove_netids.empty())
		{
			for (auto kv : self->m_id2nodes)
			{
				self->m_to_remove_netids.insert(kv.first);
			}
		}
		self->m_to_remove_netids_mutex.unlock();
		WorkLoop_AddConn();
		WorkLoop_RemoveConn();
		WorkLoop_SendBuff();
		log_debug("select loop leave 1");
		remove_timer(tid);
	}

	void NetWorkerSelect::WorkLoop_AddConn()
	{
		auto self = this;
		// 加入节点
		self->m_new_nodes_mutex.lock();
		if (!self->m_new_nodes.empty())
		{
			for (auto kv : self->m_new_nodes)
			{
				self->m_id2nodes.insert(kv);
			}
			self->m_new_nodes.clear();
		}
		self->m_new_nodes_mutex.unlock();
	}

	void NetWorkerSelect::WorkLoop_RemoveConn()
	{
		auto self = this;
		// 删除节点
		self->m_to_remove_netids_mutex.lock();
		if (!self->m_to_remove_netids.empty())
		{
			for (auto netid : self->m_to_remove_netids)
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
						Node::DestroyNode(node); node = nullptr;
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
			self->m_to_remove_netids.clear();
		}
		self->m_to_remove_netids_mutex.unlock();
	}

	void NetWorkerSelect::WorkLoop_SendBuff()
	{
		auto self = this;
		// 处理将要被发送的NetBuffer
		self->m_wait_send_buffs_mutex.lock();
		if (!self->m_wait_send_buffs.empty())
		{
			for (auto kv : self->m_wait_send_buffs)
			{
				auto it = self->m_id2nodes.find(kv.first);
				if (self->m_id2nodes.end() == it || ENetworkHandler_Connect != it->second->handler_type)
				{
					delete kv.second;
				}
				else
				{
					it->second->AddSendBuff(kv.second);
				}
			}
			self->m_wait_send_buffs.clear();
		}
		self->m_wait_send_buffs_mutex.unlock();
	}

	void NetWorkerSelect::HandleNetRead(int fd)
	{
		Node *node = this->GetNodeByFd(fd);
		if (nullptr == node)
			return;

		if (ENetworkHandler_Connect == node->handler_type)
		{
			NetBuffer *buff = new NetBuffer(64, 64);
			int read_len = 0;
			int err_num = 0;
			bool close_fd = false;
			while (true)
			{
				if (buff->LeftSpace() <= 0)
				{
					buff->CheckExpend(buff->Capacity() + buff->StepSize());
				}
				int read_len = read(node->fd, buff->Ptr(), buff->LeftSpace());
				if (read_len > 0)
				{
					buff->SetPos(buff->Pos() + read_len);
				}
				if (0 == read_len)
				{
					err_num = 1;
					close_fd = true;
					break;
				}
				if (read_len < 0)
				{
					int err_num = GetLastError();
					if (EWOULDBLOCK != err_num && EAGAIN != err_num)
					{
						close_fd = true;
						break;
					}
				}
			}
			if (buff->Size() > 0)
			{
				this->AddNetworkData(new NetworkData(
					node->handler_type,
					node->netid,
					node->fd,
					node->handler,
					ENetWorkDataAction_Read,
					0, 0, buff
				));
			}
			else
			{
				delete buff; buff = nullptr;
			}
			if (close_fd)
			{
				HandleNetError(fd, err_num);
			}
		}
		if (ENetworkHandler_Listen == node->handler_type)
		{
			int new_fd = accept(fd, nullptr, nullptr);
			int err_no = GetLastError();
			if (new_fd >= 0)
			{
				this->AddNetworkData(new NetworkData(
					node->handler_type,
					node->netid,
					node->fd,
					node->handler,
					ENetWorkDataAction_Read,
					0, new_fd, nullptr
				));
			}
		}
	}

	void NetWorkerSelect::HandleNetWrite(int fd)
	{
		Node *node = this->GetNodeByFd(fd);
		if (nullptr == node)
			return;

		if (ENetworkHandler_Connect == node->handler_type)
		{
			int err_num = 0;
			bool close_fd = false;
			while (!node->send_buffs.empty())
			{
				NetBuffer *buff = node->send_buffs.front();
				if (buff->Size() > 0)
				{
					uint32_t buf_size = buff->Size();
					char *p = buff->HeadPtr();
					int write_len = write(node->fd, p, buf_size);
					if (write_len > 0)
					{
						buff->PopBuff(write_len, nullptr);
					}
					if (0 == write_len)
					{
						close_fd = true;
						err_num = 1;
						break;
					}
					if (write_len < 0)
					{
						int err_num = GetLastError();
						if (EWOULDBLOCK != err_num && EAGAIN != err_num)
						{
							close_fd = true;
							break;
						}
					}
				}
				if (buff->Size() <= 0)
				{
					node->send_buffs.pop();
					delete buff;
				}
			}
			if (close_fd)
			{
				HandleNetError(fd, err_num);
			}
		}
	}

	void NetWorkerSelect::HandleNetError(int fd, int err_num)
	{
		Node *node = this->GetNodeByFd(fd);
		if (nullptr == node)
		{
			close(fd);
			return;
		}
		m_id2nodes.erase(node->netid);
		this->AddNetworkData(new NetworkData(
			node->handler_type,
			node->netid,
			node->fd,
			node->handler,
			ENetWorkDataAction_Close,
			err_num, 0, nullptr
		));
		Node::DestroyNode(node); node = nullptr;
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

	int NetWorkerSelect::MakeFdUnblock(int fd)
	{
		int ret;
#ifdef WIN32
		unsigned long b = 1;
		ret = ioctlsocket((SOCKET)fd, FIONBIO, &b);
#else
		int flag = fcntl(fd, F_GETFL, 0) | O_NONBLOCK;
		ret = fcntl(fd, F_SETFL, flag);
#endif
		return ret;
	}

	void NetWorkerSelect::Node::AddSendBuff(NetBuffer *net_buffer)
	{
		// TODO: 优化
		send_buffs.push(net_buffer);
	}
	void NetWorkerSelect::Node::DestroyNode(Node * node)
	{
		if (nullptr == node) 
			return;

		while (!node->send_buffs.empty())
		{
			delete node->send_buffs.front();
			node->send_buffs.pop();
		}
		delete node; node = nullptr;
	}
}