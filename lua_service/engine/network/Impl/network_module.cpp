#include "network_module.h"
#include "module_def/module_mgr.h"
#include "log/log_mgr.h"
#include "net_worker_select.h"
#include "iengine.h"

#ifdef WIN32
#include <winsock2.h>
#define close closesocket
#endif

struct NetTaskThread
{
	using ThreadAction = void(*)(NetTaskThread *);
	NetTaskThread(std::function<void(NetTaskThread *)> _action, std::mutex *_task_mutex,
		std::queue<Net::NetTask *> *_net_tasks, 
		std::mutex *_result_mutex,
		std::queue<Net::NetTaskResult> *_cnn_results) :
		task_mutex(_task_mutex), net_tasks(_net_tasks), result_mutex(_result_mutex),
		cnn_results(_cnn_results), action(_action)
	{

	}

	~NetTaskThread()
	{

	}

	bool Start()
	{
		bool ret = false;
		if (nullptr == self_thread && !is_exit)
		{
			if (nullptr != action)
			{
				self_thread = new std::thread(action, this);
				ret = true;
			}
		}
		return ret;
	}
	void Exit()
	{
		is_exit = true;
	}
	void Join()
	{
		this->Exit();
		self_thread->join();
		action = nullptr;
		delete self_thread; self_thread = nullptr;
	}

	bool is_exit = false;
	std::mutex *task_mutex;
	std::queue<Net::NetTask *, std::deque<Net::NetTask *>> *net_tasks;
	std::mutex *result_mutex;
	std::queue<Net::NetTaskResult, std::deque<Net::NetTaskResult>> *cnn_results;
	std::function<void(NetTaskThread *)> action = nullptr;
	std::thread *self_thread = nullptr;
};

void NetTaskWorker(NetTaskThread *task_thread)
{
	if (nullptr == task_thread) return;

	bool is_exit = false;
	std::mutex *task_mutex = task_thread->task_mutex;
	std::queue<Net::NetTask *, std::deque<Net::NetTask *>> *cnn_tasks = task_thread->net_tasks;
	std::mutex *result_mutex = task_thread->result_mutex;
	std::queue<Net::NetTaskResult, std::deque<Net::NetTaskResult>> *cnn_results = task_thread->cnn_results;

	while (!task_thread->is_exit)
	{
		if (cnn_tasks->empty())
		{
			static const int SLEEP_SPAN = 25;
			std::this_thread::sleep_for(std::chrono::milliseconds(SLEEP_SPAN));
			continue;
		}
		Net::NetTask *task = nullptr;
		if (task_mutex->try_lock())
		{
			if (!cnn_tasks->empty())
			{
				task = cnn_tasks->front();
				cnn_tasks->pop();
			}
			task_mutex->unlock();
		}
		if (nullptr == task)
			continue;
		task->Process();
		result_mutex->lock();
		cnn_results->push(task->GetResult());
		result_mutex->unlock();
		delete task; task = nullptr;
	}
}

NetworkModule::NetworkModule(ModuleMgr *module_mgr) : INetworkModule(module_mgr)
{
	m_net_task_mutex = new std::mutex();
	m_net_task_results_mutex = new std::mutex();

	if (m_net_task_thread_num <= 0)
		m_net_task_thread_num = 1;
	int malloc_size = sizeof(NetTaskThread *) * m_net_task_thread_num;
	m_net_task_threads = (NetTaskThread **)malloc(malloc_size);
	memset(m_net_task_threads, 0, malloc_size);
	for (int i = 0; i < m_net_task_thread_num; ++i)
	{
		m_net_task_threads[i] = new NetTaskThread(
			NetTaskWorker, m_net_task_mutex, &m_net_tasks,
			m_net_task_results_mutex, &m_net_task_results);
	}

	if (m_net_worker_num <= 0)
		m_net_worker_num = 1;
	malloc_size = sizeof(Net::INetWorker *) * m_net_worker_num;
	m_net_workers = (Net::INetWorker **)malloc(malloc_size);
	memset(m_net_workers, 0, malloc_size);
	for (int i = 0; i < m_net_worker_num; ++i)
	{
		m_net_workers[i] = new Net::NetWorkerSelect();
	}
}

NetworkModule::~NetworkModule()
{
	if (nullptr != m_net_task_threads)
	{
		for (int i = 0; i < m_net_task_thread_num; ++i)
		{
			if (nullptr != m_net_task_threads[i])
			{
				delete m_net_task_threads[i];
				m_net_task_threads[i] = nullptr;
			}
		}
		free(m_net_task_threads); 
		m_net_task_threads = nullptr;
	}

	if (nullptr != m_net_task_mutex)
	{
		delete 	m_net_task_mutex;
		m_net_task_mutex = nullptr;
	}
	if (nullptr != m_net_task_results_mutex)
	{
		delete m_net_task_results_mutex;
		m_net_task_results_mutex = nullptr;
	}
	if (nullptr != m_net_workers)
	{
		for (int i = 0; i < m_net_worker_num; ++i)
		{
			delete m_net_workers[i];
			m_net_workers[i] = nullptr;
		}
		free(m_net_workers);
		m_net_workers = nullptr;
	}
}

EModuleRetCode NetworkModule::Init(void **param)
{
	return EModuleRetCode_Succ;
}

EModuleRetCode NetworkModule::Awake()
{
	bool ret = true;
	if (ret)
	{
		for (int i = 0; i < m_net_worker_num; ++i)
		{
			if (!m_net_workers[i]->Start())
			{
				ret = false;
				break;
			}
		}
	}
	if (ret)
	{
		for (int i = 0; i < m_net_task_thread_num; ++i)
		{
			if (!m_net_task_threads[i]->Start())
			{
				ret = false;
				break;
			}
		}
	}

	return ret ? EModuleRetCode_Succ : EModuleRetCode_Failed;
}

EModuleRetCode NetworkModule::Update()
{
	this->ProcessNetTaskResult();
	this->ProcessNetDatas();
	return EModuleRetCode_Succ;
}

EModuleRetCode NetworkModule::Release()
{
	for (int i = 0; i < m_net_task_thread_num; ++i)
	{
		m_net_task_threads[i]->Exit();
	}
	for (int i = 0; i < m_net_task_thread_num; ++i)
	{
		m_net_task_threads[i]->Join();
	}
	while (!m_net_task_results.empty())
	{
		m_net_task_results.pop();
	}
	while (!m_net_tasks.empty())
	{
		delete m_net_tasks.front();
		m_net_tasks.pop();
	}

	return EModuleRetCode_Succ;
}

EModuleRetCode NetworkModule::Destroy()
{
	for (int i = 0; i < m_net_worker_num; ++i)
	{
		m_net_workers[i]->Stop();
	}
	m_async_network_handlers.clear();

	return EModuleRetCode_Succ;
}

NetId NetworkModule::Listen(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetListenHander> handler)
{
	std::shared_ptr<INetworkHandler> sp_handler = handler.lock();
	if (nullptr == sp_handler) return 0;

	NetId netid = 0;
	Net::NetTaskListen task(0, ip, port, opt);
	task.Process();
	const Net::NetTaskResult &ret = task.GetResult();
	int err_num = ret.err_num;
	std::string err_msg = ret.err_msg;
	if (0 == err_num)
	{
		netid = this->GenNetId();
		if (!ChoseWorker(netid)->AddCnn(netid, ret.fd, sp_handler))
		{
			err_num = 1;
			if (ret.fd >= 0)
				close(ret.fd);
			err_msg = "NetWorker::Add fail";
		}
	}

	sp_handler->OnOpen(err_num);
	if (0 != err_num)
	{
		netid = 0;
		MODULE_LOG_MGR->Error("NetworkModule::Listen {0}:{1} fail, errno {2}", ip, port, err_num);
	}
	return netid;
}

NetId NetworkModule::Connect(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetConnectHander> handler)
{
	std::shared_ptr<INetworkHandler> sp_handler = handler.lock();
	if (nullptr == sp_handler) return 0;

	NetId netid = 0;
	Net::NetTaskConnect task(0, ip, port, opt);
	task.Process();
	const Net::NetTaskResult &ret = task.GetResult();
	int err_num = ret.err_num;
	std::string err_msg = ret.err_msg;
	if (0 == err_num)
	{
		netid = this->GenNetId();
		if (!ChoseWorker(netid)->AddCnn(netid, ret.fd, sp_handler))
		{
			err_num = 1;
			if (ret.fd >= 0)
			{
				close(ret.fd);
			}
			err_msg = "NetWorker::Add fail";
		}
	}

	sp_handler->OnOpen(err_num);
	if (0 != err_num)
	{
		netid = 0;
		MODULE_LOG_MGR->Error("NetworkModule::Connect {0}:{1} fail, errno {2}", ip, port, err_num);
	}
	return netid;
}

void NetworkModule::Close(NetId netid)
{
	this->ChoseWorker(netid)->RemoveCnn(netid);
}

int64_t NetworkModule::ListenAsync(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetListenHander> handler)
{
	if (nullptr == handler.lock()) return 0;

	int64_t async_id = this->GenAsyncId();
	m_async_network_handlers[async_id] = handler;
	Net::NetTaskListen *task = new Net::NetTaskListen(
		async_id, ip, port, opt);
	m_net_task_mutex->lock();
	m_net_tasks.push(task);
	m_net_task_mutex->unlock();
	return async_id;
}

int64_t NetworkModule::ConnectAsync(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetConnectHander> handler)
{
	if (nullptr == handler.lock()) return 0;

	int64_t async_id = this->GenAsyncId();
	m_async_network_handlers[async_id] = handler;
	Net::NetTaskConnect *task = new Net::NetTaskConnect(
		async_id, ip, port, opt);
	m_net_task_mutex->lock();
	m_net_tasks.push(task);
	m_net_task_mutex->unlock();
	return async_id;
}

void NetworkModule::CancelAsync(uint64_t async_id)
{
	m_async_network_handlers.erase(async_id);
}

bool NetworkModule::Send(NetId netId, char *buffer, uint32_t len)
{
	if (netId <= 0 || nullptr == buffer || len <= 0)
		return false;
	return this->ChoseWorker(netId)->Send(netId, buffer, len);
}

NetId NetworkModule::GenNetId()
{
	++ m_last_netid;
	if (m_last_netid <= 0) m_last_netid = 1;
	return m_last_netid;
}

int64_t NetworkModule::GenAsyncId()
{
	++ m_last_async_id;
	if (m_last_async_id <= 0) m_last_async_id = 1;
	return m_last_async_id;
}

Net::INetWorker * NetworkModule::ChoseWorker(NetId netid)
{
	return m_net_workers[netid % m_net_worker_num];
}

void NetworkModule::ProcessNetTaskResult()
{
	std::queue<Net::NetTaskResult> cnn_results_swap;
	m_net_task_results_mutex->lock();
	cnn_results_swap.swap(m_net_task_results);
	m_net_task_results_mutex->unlock();
	if (cnn_results_swap.empty())
		return;

	while (!cnn_results_swap.empty())
	{
		Net::NetTaskResult ret = cnn_results_swap.front();
		cnn_results_swap.pop();
		auto it = m_async_network_handlers.find(ret.id);
		if (m_async_network_handlers.end() == it || it->second.expired())
		{
			if (ret.fd >= 0)
				close(ret.fd);
		}
		else
		{
			std::shared_ptr<INetworkHandler> handler = it->second.lock();
			int err_num = ret.err_num;
			std::string err_msg = ret.err_msg;
			if (0 == err_num)
			{
				NetId netid = this->GenNetId();
				if (!ChoseWorker(netid)->AddCnn(netid, ret.fd, handler))
				{
					err_num = 1;
					err_msg = "NetWorker::Add fail";
				}
			}
			handler->OnOpen(err_num);
			if (0 != err_num)
			{
				MODULE_LOG_MGR->Error("NetworkModule::ProcessConnectResult errno {0}, error reason", err_num, err_msg);
			}
		}
		m_async_network_handlers.erase(ret.id);
	}
}

void NetworkModule::ProcessNetDatas()
{
	for (int i = 0; i < m_net_worker_num; ++i)
	{
		std::set<NetId, std::less<NetId>> to_remove_netids;
		std::queue<NetworkData *> *net_datas = nullptr;
		if (m_net_workers[i]->GetNetDatas(&net_datas))
		{
			while (!net_datas->empty())
			{
				NetworkData *data = net_datas->front();
				net_datas->pop();
				std::shared_ptr<INetworkHandler> handler = data->handler.lock();
				if (nullptr == handler)
				{
					if (ENetworkHandler_Listen == data->handler_type && ENetWorkDataAction_Read == data->action)
					{
						if (data->new_fd >= 0)
						{
							close(data->new_fd);
							data->new_fd = -1;
						}
					}
					to_remove_netids.insert(data->netid);
				}
				else
				{
					if (ENetworkHandler_Connect == handler->HandlerType())
					{
						std::shared_ptr<INetConnectHander> tmp_handler = std::dynamic_pointer_cast<INetConnectHander>(handler);
						if (ENetWorkDataAction_Close == data->action)
						{
							tmp_handler->OnClose(data->err_num);
						}
						if (ENetWorkDataAction_Read == data->action)
						{
							tmp_handler->OnRecvData(data->binary->HeadPtr(), data->binary->Size());
						}
					}
					if (ENetworkHandler_Listen == handler->HandlerType())
					{
						std::shared_ptr<INetListenHander> tmp_handler = std::dynamic_pointer_cast<INetListenHander>(handler);
						if (ENetWorkDataAction_Close == data->action)
						{
							tmp_handler->OnClose(data->err_num);
						}
						if (ENetWorkDataAction_Read == data->action)
						{
							std::shared_ptr<INetConnectHander> new_handler = tmp_handler->GenConnectorHandler();
							NetId netid = this->GenNetId();
							int err_num = 0;
							if (nullptr == new_handler || !ChoseWorker(netid)->AddCnn(netid, data->new_fd, new_handler))
							{
								err_num = 1;
							}
							if (nullptr != new_handler)
							{
								new_handler->OnOpen(err_num);
							}
							if (0 != err_num)
							{
								if (data->new_fd >= 0)
								{
									close(data->new_fd);
								}
							}
						}
					}
				}
				free(data->binary); data->binary = nullptr;
				delete data; data = nullptr;
			}
		}
		for (NetId netid : to_remove_netids)
		{
			m_net_workers[i]->RemoveCnn(netid);
		}
	}
}
