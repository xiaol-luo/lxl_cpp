#pragma once

#include <thread>
#include <queue>
#include <thread>
#include <mutex>
#include <unordered_map>
#include "network/i_network_module.h"
#include "net_task.h"
#include "buffer/net_buffer.h"
#include "server_logic/ServerLogic.h"

struct NetTaskThread;
namespace Net
{
	class INetWorker;
}

enum ENetWorkDataAction
{
	ENetWorkDataAction_Read = 0,
	ENetWorkDataAction_Close,
	ENetWorkDataAction_Max,
};

struct NetworkData
{
	NetworkData(
		ENetworkHandlerType _handler_type, 
		NetId _netid, 
		int _fd, 
		std::weak_ptr<INetworkHandler> _handle,
		ENetWorkDataAction _action, 
		int _err_num, 
		int _new_fd, 
		NetBuffer *_binary) 
		: handler_type(_handler_type), netid(_netid), fd(_fd), handler(_handle), action(_action), err_num(_err_num),
		new_fd(_new_fd), binary(_binary) {}
	ENetworkHandlerType handler_type = ENetworkHandlerType_Max;
	NetId netid = 0;
	int fd = -1;
	std::weak_ptr<INetworkHandler> handler;
	ENetWorkDataAction action = ENetWorkDataAction_Max;
	int err_num = 0;
	int new_fd = -1;
	NetBuffer *binary = nullptr;
};

class NetworkModule : public INetworkModule
{
public:
	NetworkModule(ModuleMgr *module_mgr);
	virtual ~NetworkModule();
	virtual EModuleRetCode Init(void **param);
	virtual EModuleRetCode Awake();
	virtual EModuleRetCode Update();
	virtual EModuleRetCode Release();
	virtual EModuleRetCode Destroy();

public:
	virtual NetId Listen(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetListenHandler> handler);
	virtual NetId Connect(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetConnectHandler> handler);
	virtual void Close(NetId netid);
	virtual int64_t ListenAsync(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetListenHandler> handler);
	virtual int64_t ConnectAsync(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetConnectHandler> handler);
	virtual void CancelAsync(uint64_t async_id);
	virtual bool Send(NetId netId, char *buffer, uint32_t len);

protected:
	std::mutex *m_net_task_mutex = nullptr;
	std::queue<Net::NetTask *> m_net_tasks;
	std::mutex *m_net_task_results_mutex = nullptr;
	std::queue<Net::NetTaskResult> m_net_task_results;
	int m_net_task_thread_num = 1;
	NetTaskThread **m_net_task_threads = nullptr;
	void ProcessNetTaskResult();

protected:
	std::unordered_map<int64_t, std::weak_ptr<INetworkHandler>> m_async_network_handlers;
	NetId m_last_netid = 0;
	int64_t m_last_async_id = 0;
	NetId GenNetId();
	int64_t GenAsyncId();

protected:
	int m_net_worker_num = 1;
	Net::INetWorker **m_net_workers = nullptr;
	Net::INetWorker * ChoseWorker(NetId netid);
	void ProcessNetDatas();
};
