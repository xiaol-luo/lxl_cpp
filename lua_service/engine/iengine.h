
#pragma once

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}
#include "server_logic/ServerLogic.h"

extern ServerLogic *g_server_logic;

void engine_init();
void engine_loop();
void engine_stop();
void engine_destroy();
void engine_loop_span(int ms);
EServerLogicState engine_state();

void * mempool_malloc(uint32_t malloc_size);
void * mempool_realloc(void *ptr, uint32_t new_malloc_size);
void mempool_free(void *ptr);

bool start_log(ELogLevel log_lvl);
void setup_service(IService *service);
TimerID timer_add(TimerCallback cb_fn, int64_t start_ts_ms, int64_t execute_span_ms, int64_t execute_times);
TimerID timer_next(TimerCallback cb_fn, int64_t start_ts_ms);
TimerID timer_firm(TimerCallback cb_fn, int64_t execute_span_ms, int64_t execute_times);
void timer_remove(TimerID timer_id);

NetId net_listen(std::string ip, uint16_t port, std::weak_ptr<INetListenHander> handler);
NetId net_connect(std::string ip, uint16_t port, std::weak_ptr<INetConnectHander> handler);
void net_close(NetId netid);
int64_t net_listen_async(std::string ip, uint16_t port, std::weak_ptr<INetListenHander> handler);
int64_t net_connect_async(std::string ip, uint16_t port, std::weak_ptr<INetConnectHander> handler);
void net_cancel_async(uint64_t async_id);
bool net_send(NetId netId, char *buffer, uint32_t len);
ServerLogic * GServerLogic();

template <typename... Args>
void log(ELogLevel log_level, const char* fmt, const Args&... args)
{
	GServerLogic()->GetLogMgr()->Log(log_level, fmt, args...);
}
template <typename... Args>
void log_debug(const char* fmt, const Args&... args)
{
	GServerLogic()->GetLogMgr()->Debug(fmt, args...);
}
template <typename... Args>
void log_info(const char* fmt, const Args&... args)
{
	GServerLogic()->GetLogMgr()->Info(fmt, args...);
}
template <typename... Args>
void log_warn(const char* fmt, const Args&... args)
{
	GServerLogic()->GetLogMgr()->Warn(fmt, args...);
}
template <typename... Args>
void log_error(const char* fmt, const Args&... args)
{
	GServerLogic()->GetLogMgr()->Error(fmt, args...);
}
