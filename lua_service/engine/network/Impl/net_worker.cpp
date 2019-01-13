#include "net_worker.h"
#include "network/i_network_handler.h"
#include "network/Impl/network_module.h"
#include <signal.h>
#include "network/network_def.h"

namespace Net
{
	NetWorker::NetWorker()
	{
	}
	NetWorker::~NetWorker()
	{
	}
	bool NetWorker::AddCnn(NetId id, int fd, std::shared_ptr<INetworkHandler> handler)
	{
		return false;
	}
	void NetWorker::RemoveCnn(NetId id)
	{
	}
	bool NetWorker::Send(NetId netId, char * buffer, uint32_t len)
	{
		return false;
	}
	bool NetWorker::GetNetDatas(std::queue<NetworkData *>** out_datas)
	{
		return false;
	}
	bool NetWorker::Start()
	{
		return false;
	}
	void NetWorker::Stop()
	{
	}
}
