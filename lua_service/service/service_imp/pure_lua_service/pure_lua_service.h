#pragma once

#include "service_imp/service_base.h"
#include <string>
extern "C" 
{
#include "lua.h"
}

class PureLuaService : public ServiceBase
{
public:
	PureLuaService() {}
	virtual ~PureLuaService() {}
	void SetFuns(lua_State *L, std::string notify_quit_game_fn_name, std::string can_quit_game_fn_name);
	virtual EModuleRetCode Init(void **param) { return EModuleRetCode_Succ; }
	virtual EModuleRetCode Awake() { return EModuleRetCode_Succ; }
	virtual EModuleRetCode Release() { return EModuleRetCode_Succ; }
	virtual EModuleRetCode Destroy() { return EModuleRetCode_Succ; }

protected:
	virtual bool CanQuitGame() override;
	virtual void NotifyQuitGame() override;

	lua_State *m_lua_state = nullptr;
	std::string m_notify_quit_game_fn_name;
	std::string m_can_quit_game_fn_name;
};
