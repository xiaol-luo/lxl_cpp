#include "i_net_worker.h"
#include "buffer/net_buffer.h"
#include <unordered_map>
#include <set>

namespace Net 
{
	class NetWorkerSelect : public INetWorker
	{
	public:
		NetWorkerSelect();
		virtual ~NetWorkerSelect();
		virtual bool AddCnn(NetId id, int fd, std::shared_ptr<INetworkHandler> handler);
		virtual void RemoveCnn(NetId id);
		virtual bool Send(NetId netId, char *buffer, uint32_t len);
		virtual bool GetNetDatas(std::queue<NetworkData*>* &out_datas);
		virtual bool Start();
		virtual void Stop();

	private:
		struct Node
		{
			NetId netid = -1;
			ENetworkHandlerType handler_type = ENetworkHandlerType_Max;
			std::weak_ptr<INetworkHandler> handler;
			int fd = -1;
			std::queue<NetBuffer *> send_buffers;
		};

		std::mutex m_mutex;
		std::unordered_map<NetId, Node *> m_new_nodes;
		std::unordered_map<NetId, Node *> m_id2nodes;
		std::set<NetId> m_to_remove_netids;
		
		static const int Net_Data_Queue_Size = 2;
		int m_net_datas_using_idx = 0;
		std::queue<NetBuffer *> m_net_datas[Net_Data_Queue_Size];
	};
}