#pragma once
#include "network/i_network_module.h"
#include "network_module.h"

namespace Net
{
	class INetWorker
	{
	public:
		INetWorker() {}
		virtual ~INetWorker() {}
		virtual bool AddCnn(NetId id, int fd, std::shared_ptr<INetworkHandler> handler) = 0;
		virtual void RemoveCnn(NetId id) = 0;
		virtual bool Send(NetId netId, char *buffer, uint32_t len) = 0;
		virtual bool GetNetDatas(std::queue<NetworkData*>** out_datas) = 0;
		virtual bool Start() = 0;
		virtual void Stop() = 0;
	};
}