extern "C" 
{
	#include "lua.h"
	#include "lauxlib.h"
	#include "lualib.h"
}

#include "sol/sol.hpp"
#include <chrono>

#define LUA_EXIT_FAILURE -1
#define lUA_EXIT_SUCCESS 0
#define LUA_SCRIPT_IDX 1

static int lua_status_report(lua_State *L, int status) 
{
	if (status != LUA_OK) 
	{
		const char *msg = lua_tostring(L, -1);
		printf(msg);
		lua_pop(L, 1);
	}
	return status;
}

static int lua_error_handler(lua_State *L) 
{
	const char *msg = lua_tostring(L, 1);
	if (msg == NULL) 
	{
		if (luaL_callmeta(L, 1, "__tostring") && lua_type(L, -1) == LUA_TSTRING)
		{
			return 1;
		}
		else
		{
			msg = lua_pushfstring(L, "(error object is a %s value)",luaL_typename(L, 1));
		}
	}
	luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
	return 1;  /* return the traceback */
}

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
ServerLogic *g_server_logic;

ServerLogic * GServerLogic()
{
	return g_server_logic;
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

void * mempool_malloc(uint32_t malloc_size)
{
	return g_server_logic->GetMemPool()->Malloc(malloc_size);
}

void * mempool_realloc(void *ptr, uint32_t new_malloc_size)
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

NetId net_listen(std::string ip, uint16_t port, std::weak_ptr<INetListenHander> handler)
{
	NetId ret = INVALID_NET_ID;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetNet()->Listen(ip, port, nullptr, handler);
	}
	return ret;
}

NetId net_connect(std::string ip, uint16_t port, std::weak_ptr<INetConnectHander> handler)
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

int64_t net_listen_async(std::string ip, uint16_t port, std::weak_ptr<INetListenHander> handler)
{
	int64_t ret = 0;
	if (nullptr != g_server_logic)
	{
		ret = g_server_logic->GetNet()->ListenAsync(ip, port, nullptr, handler);
	}
	return ret;
}

int64_t net_connect_async(std::string ip, uint16_t port, std::weak_ptr<INetConnectHander> handler)
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
