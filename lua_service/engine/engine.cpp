extern "C" 
{
	#include "lua.h"
	#include "lauxlib.h"
	#include "lualib.h"
}

#include "sol/sol.hpp"
#include <chrono>

#ifdef WIN32
#include <direct.h>
#define chdir _chdir
#else
#include <unistd.h>
#endif

int64_t RealMs()
{
	std::chrono::high_resolution_clock::time_point tp = std::chrono::high_resolution_clock::now();
	long long now = std::chrono::duration_cast<std::chrono::milliseconds>(tp.time_since_epoch()).count();
	return now;
}

static void change_dir(std::string dir_path)
{
	if (dir_path.length() <= 0)
	{
		printf("chdir: not accept dir_path length which is 0 \n");
		return;
	}
	int ret = chdir(dir_path.c_str());
	if (0 != ret)
	{
		printf("chdir to dir %s fail, errno is %d \n", dir_path.c_str(), ret);
	}
}

#include "server_logic/ServerLogic.h"
#include "iengine.h"
ServerLogic *g_server_logic;

ServerLogic * GServerLogic()
{
	return g_server_logic;
}

uint64_t http_get(const std::string &url, const std::unordered_map<std::string, std::string> *heads,
	HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb)
{
	uint64_t ret = 0;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetHttpClientMgr()->Get(url, heads, rsp_cb, err_cb);
	}
	return ret;
}

uint64_t http_delete(const std::string & url, const std::unordered_map<std::string, std::string>* heads, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb)
{
	uint64_t ret = 0;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetHttpClientMgr()->Delete(url, heads, rsp_cb, err_cb);
	}
	return ret;
}

uint64_t http_post(const std::string &url, const std::unordered_map<std::string, std::string> *heads, const std::string *content,
	HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb)
{
	uint64_t ret = 0;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetHttpClientMgr()->Post(url, heads, content, rsp_cb, err_cb);
	}
	return ret;
}

uint64_t http_put(const std::string & url, const std::unordered_map<std::string, std::string>* heads, const std::string * content, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb)
{
	uint64_t ret = 0;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetHttpClientMgr()->Put(url, heads, content, rsp_cb, err_cb);
	}
	return ret;
}

void http_cancel(int64_t async_id)
{
	if (nullptr != g_server_logic)
	{
		g_server_logic->GetHttpClientMgr()->Cancel(async_id);
	}
}

void add_async_task(TaskBase * task)
{
	if (nullptr != g_server_logic)
	{
		g_server_logic->GetAsyncTaskMgr()->AddTask(task);
	}
}

int dns_query(std::string host, std::vector<std::string>* out_ips)
{
	int ret = -1;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetDnsService()->QueryIp(host, out_ips);
	}
	return ret;
}

void dns_query_async(std::string host, DnsQueryIpCallback cb)
{
	if (nullptr != g_server_logic)
	{
		g_server_logic->GetDnsService()->QueryIpAsync(host, cb);
	}
}

void engine_init()
{
	if (nullptr == g_server_logic)
	{
		g_server_logic = new ServerLogic();
	}
}

void engine_loop()
{
	g_server_logic->Loop();
}

void engine_stop()
{
	g_server_logic->Quit();
}

void engine_destroy()
{
	delete g_server_logic; g_server_logic = nullptr;
}

void engine_loop_span(int ms)
{
	g_server_logic->SetLoopSpan(ms);
}

EServerLogicState engine_state()
{
	EServerLogicState ret = EServerLogicState_Max;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetState();
	}
	return ret;
}

IService * engine_service()
{
	IService *service = nullptr;
	if (nullptr != g_server_logic)
	{
		service = g_server_logic->GetService();

	}
	return service;
}

double logic_sec()
{
	return g_server_logic->LogicSec();
}

int64_t logic_ms()
{
	return g_server_logic->LogicMs();
}

int64_t delta_ms()
{
	return g_server_logic->DeltaMs();
}
void * mempool_malloc(size_t malloc_size)
{
	return g_server_logic->GetMemPool()->Malloc(malloc_size);
}

void * mempool_realloc(void *ptr, size_t new_malloc_size)
{
	return g_server_logic->GetMemPool()->Realloc(ptr, new_malloc_size);
}

void mempool_free(void *ptr)
{
	g_server_logic->GetMemPool()->Free(ptr);
}

bool start_log(ELogLevel log_lvl)
{
	return g_server_logic->GetLogMgr()->Start(log_lvl);
}

void setup_service(IService *service)
{
	g_server_logic->SetService(service);
}

TimerID timer_add(TimerCallback cb_fn, int64_t start_ts_ms, int64_t execute_span_ms, int64_t execute_times)
{
	TimerID ret = INVALID_TIMER_ID;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetTimerMgr()->Add(cb_fn, start_ts_ms, execute_span_ms, execute_times);
	}
	return ret;
}
TimerID timer_next(TimerCallback cb_fn, int64_t start_ts_ms)
{
	TimerID ret = INVALID_TIMER_ID;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetTimerMgr()->AddNext(cb_fn, start_ts_ms);
	}
	return ret;
}

TimerID timer_firm(TimerCallback cb_fn, int64_t execute_span_ms, int64_t execute_times)
{
	TimerID ret = INVALID_TIMER_ID;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetTimerMgr()->AddFirm(cb_fn, execute_span_ms, execute_times);
	}
	return ret;
}

void timer_remove(TimerID timer_id)
{
	if (nullptr != g_server_logic)
	{
		g_server_logic->GetTimerMgr()->Remove(timer_id);
	}
}

NetId net_listen(std::string ip, uint16_t port, std::weak_ptr<INetListenHandler> handler)
{
	NetId ret = INVALID_NET_ID;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetNet()->Listen(ip, port, nullptr, handler);
	}
	return ret;
}

NetId net_connect(std::string ip, uint16_t port, std::weak_ptr<INetConnectHandler> handler)
{
	NetId ret = INVALID_NET_ID;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetNet()->Connect(ip, port, nullptr, handler);
	}
	return ret;
}

void net_close(NetId netid)
{
	if (nullptr != g_server_logic)
	{
		g_server_logic->GetNet()->Close(netid);
	}
}

int64_t net_listen_async(std::string ip, uint16_t port, std::weak_ptr<INetListenHandler> handler)
{
	int64_t ret = 0;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetNet()->ListenAsync(ip, port, nullptr, handler);
	}
	return ret;
}

int64_t net_connect_async(std::string ip, uint16_t port, std::weak_ptr<INetConnectHandler> handler)
{
	int64_t ret = 0;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetNet()->ConnectAsync(ip, port, nullptr, handler);
	}
	return ret;
}

void net_cancel_async(uint64_t async_id)
{
	if (nullptr != g_server_logic)
	{
		g_server_logic->GetNet()->CancelAsync(async_id);
	}
}

bool net_send(NetId netId, char *buffer, uint32_t len)
{
	bool ret = false;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetNet()->Send(netId, buffer, len);
	}
	return ret;
}
