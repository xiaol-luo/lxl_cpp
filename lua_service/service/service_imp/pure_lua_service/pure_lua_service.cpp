#include "pure_lua_service.h"
#include <sol/sol.hpp>
#include "iengine.h"

void PureLuaService::SetFuns(lua_State * L, std::string notify_quit_game_fn_name, std::string can_quit_game_fn_name)
{
	m_lua_state = L;
	m_notify_quit_game_fn_name = notify_quit_game_fn_name;
	m_can_quit_game_fn_name = can_quit_game_fn_name;
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
