#include "sidecar_service.h"
#include <sol/sol.hpp>
#include "iengine.h"
#include "main_impl/main_impl.h"
#include "etcd_client/etcd_client.h"

bool SidecarService::CanQuitGame()
{
	return m_can_quit;
}

void SidecarService::NotifyQuitGame()
{
	m_can_quit = true;
}

void SidecarService::RunService(int argc, char ** argv)
{
	std::vector<std::string> extra_args = ServiceMakeLuaExtraArgs(argc, argv);
	std::string script_root_dir = argv[Args_Index_Lua_Dir];
	bool ret = StartLuaScript(m_lua_state, script_root_dir, argc, argv, extra_args);
	if (!ret)
	{
		engine_stop();
	}
	EtcdClient xxx(m_lua_state, "http://127.0.0.1:2379", "", "");
	auto fn = [](uint64_t op_id, const std::string & str)
	{
		log_debug("str {} {}", op_id, str);
	};
	xxx.Set("/test3/xxx", "hello", 1000, false, fn);
	xxx.Set("/test3/xxx", "hello", 1000, false, nullptr);
}
