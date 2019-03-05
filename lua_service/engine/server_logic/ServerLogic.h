#pragma once

#include <module_def/i_module.h>
#include "network/i_network_module.h"
#include "timer/timer_mgr.h"
#include "log/log_mgr.h"
#include "memory_pool/MemoryPoolMgr.h"
#include "i_service.h"
#include "http/http_client_mgr.h"
#include "common/task/async_task_mgr.h"
#include "dns/dns_service.h"

enum EServerLogicState
{
	EServerLogicState_Free,
	EServerLogicState_Init,
	EServerLogicState_Awake,
	EServerLogicState_Update,
	EServerLogicState_Release,
	EServerLogicState_Destroy,
	EServerLogicState_Max,
};

class ServerLogic
{
public:
	ServerLogic();
	virtual ~ServerLogic();
	bool StartLog(ELogLevel log_lvl);
	void SetLoopSpan(int ms) { m_loop_span_ms = ms > 0 ? ms : m_loop_span_ms; }
	void SetService(IService *service);
	IService * GetService() { return m_service; }
	void SetParams() {}
	void Loop();
	void Quit();
	void SetModuleParams(void **params, std::function<void(void ***)> clear_fn) {}
	EServerLogicState GetState() { return m_state; }
	INetworkModule * GetNet();

protected:
	bool Init();
	bool Awake();
	void Update();
	void Realse();
	void Destroy();
	EServerLogicState m_state = EServerLogicState_Free;
	ModuleMgr *m_module_mgr = nullptr;
	int m_loop_span_ms = 100;
	void **m_module_params[EMoudleName_Max];
	std::function<void(void ***)> m_module_params_clear_fn = nullptr;
	IService *m_service = nullptr;

public:
	double LogicSec() { return m_logic_sec; }
	int64_t LogicMs() { return m_logic_ms; }
	int64_t DeltaMs() { return m_delta_ms; }
private:
	void OnFrame();
	uint64_t m_logic_ms = 0;
	double m_logic_sec = 0;
	uint64_t m_delta_ms = 0;

public:
	LogMgr * GetLogMgr() { return m_log_mgr; }
private:
	LogMgr *m_log_mgr = nullptr;

public:
	TimerMgr * GetTimerMgr() { return m_timer_mgr; }
private:
	TimerMgr *m_timer_mgr = nullptr;

public:
	MemoryPoolMgr *GetMemPool() { return m_memory_pool_mgr; }
private:
	MemoryPoolMgr *m_memory_pool_mgr = nullptr;

public:
	HttpClientMgr * GetHttpClientMgr() { return m_http_client_mgr; }
private:
	HttpClientMgr * m_http_client_mgr = nullptr;

public:
	AsyncTaskMgr * GetAsyncTaskMgr() { return m_async_task_mgr; }
private:
	AsyncTaskMgr * m_async_task_mgr = nullptr;

public:
	DnsService * GetDnsService() { return m_dns_service; }
private:
	DnsService * m_dns_service = nullptr;
};

