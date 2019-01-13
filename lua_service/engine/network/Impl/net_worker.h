#pragma once

#include <memory>
#include <queue>
#include <unordered_map>
#include <set>
#include <mutex>
#include "i_net_worker.h"

struct bufferevent;
struct evconnlistener;
struct event_base;
struct evbuffer;

namespace Net
{
	class NetWorker : public INetWorker
	{
	public:
		NetWorker();
		virtual ~NetWorker();
		virtual bool AddCnn(NetId id, int fd, std::shared_ptr<INetworkHandler> handler);
		virtual void RemoveCnn(NetId id);
		virtual bool Send(NetId netId, char *buffer, uint32_t len);
		virtual bool GetNetDatas(std::queue<NetworkData*>** out_datas);
		virtual bool Start();
		virtual void Stop();
	};
}