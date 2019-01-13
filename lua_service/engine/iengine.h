
#pragma once

#if defined(WIN32)
	#if defined(ENGINE_BUILD_AS_DLL)
		// #define ENGINE_API __declspec(dllexport)
	#else
		// #define ENGINE_API __declspec(dllimport)
	#endif
	#define ENGINE_API
#else
	#define ENGINE_API extern
#endif

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}
#include "server_logic/ServerLogic.h"

extern ServerLogic *g_server_logic;

ENGINE_API void register_native_fns(lua_State *L);
ENGINE_API void engine_init();
ENGINE_API void engine_loop();
ENGINE_API void engine_stop();
ENGINE_API void engine_destroy();
ENGINE_API void engine_loop_span(int ms);
ENGINE_API EServerLogicState engine_state();
ENGINE_API bool start_log(ELogLevel log_lvl);
ENGINE_API void setup_service(IService *service);
ENGINE_API TimerID add_timer(TimerCallback cb_fn, int64_t start_ts_ms, int64_t execute_span_ms, int64_t execute_times);
ENGINE_API TimerID add_next_timer(TimerCallback cb_fn, int64_t start_ts_ms);
ENGINE_API TimerID add_firm_timer(TimerCallback cb_fn, int64_t execute_span_ms, int64_t execute_times);
ENGINE_API void remove_timer(TimerID timer_id);

ENGINE_API NetId net_listen(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetListenHander> handler);
ENGINE_API NetId net_connect(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetConnectHander> handler);
ENGINE_API void net_close(NetId netid);
ENGINE_API int64_t net_listen_async(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetListenHander> handler);
ENGINE_API int64_t net_connect_async(std::string ip, uint16_t port, void *opt, std::weak_ptr<INetConnectHander> handler);
ENGINE_API void net_cancel_async(uint64_t async_id);
ENGINE_API bool net_send(NetId netId, char *buffer, uint32_t len);
ENGINE_API ServerLogic * GServerLogic();

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
