#include "pure_lua_service.h"
#include <sol/sol.hpp>
#include "iengine.h"
#include "main_impl/main_impl.h"

void PureLuaService::SetFuns(std::string notify_quit_game_fn_name, std::string can_quit_game_fn_name)
{
	m_notify_quit_game_fn_name = notify_quit_game_fn_name;
	m_can_quit_game_fn_name = can_quit_game_fn_name;
}

#include "etcd_client/etcd_client.h"
void PureLuaService::RunService(int argc, char ** argv)
{
	std::vector<std::string> extra_args = ServiceMakeLuaExtraArgs(argc, argv);
	std::string script_root_dir = argv[Args_Index_Lua_Dir];
	bool ret = StartLuaScript(m_lua_state, script_root_dir, argc, argv, extra_args);
	if (!ret)
	{
		engine_stop();
	}
}

bool PureLuaService::CanQuitGame()
{
	bool can_quit = true;
	if (nullptr != m_lua_state && !m_can_quit_game_fn_name.empty())
	{
		sol::state_view lsv(m_lua_state);
		sol::object v = lsv.get<sol::object>(m_can_quit_game_fn_name);
		if (v.is<sol::protected_function>())
		{
			sol::protected_function fn = v.as<sol::protected_function>();
			sol::protected_function_result ret = fn();
			if (ret.valid())
			{
				can_quit = ret.get<bool>(0);
			}
		}
	}
	log_debug("PureLuaService::CanQuitGame {}", can_quit);
	return can_quit;
}

void PureLuaService::NotifyQuitGame()
{
	if (nullptr != m_lua_state && !m_notify_quit_game_fn_name.empty())
	{
		sol::state_view lsv(m_lua_state);
		sol::object v = lsv.get<sol::object>(m_notify_quit_game_fn_name);
		if (v.is<sol::protected_function>())
		{
			sol::protected_function fn = v.as<sol::protected_function>();
			fn();
		}
	}
}
