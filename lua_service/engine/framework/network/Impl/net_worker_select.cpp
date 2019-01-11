#include "net_worker_select.h"

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
		return false;
	}

	void NetWorkerSelect::RemoveCnn(NetId id)
	{
	}

	bool NetWorkerSelect::Send(NetId netId, char * buffer, uint32_t len)
	{
		return false;
	}

	bool NetWorkerSelect::GetNetDatas(std::queue<NetworkData*>*& out_datas)
	{
		return false;
	}

	bool NetWorkerSelect::Start()
	{
		return false;
	}

	void NetWorkerSelect::Stop()
	{
	}
}