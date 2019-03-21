#pragma once

#include "i_service.h"
extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}
#include <vector>

class ServiceBase : public IService
{
public:
	virtual EModuleRetCode Update();
	void TryQuitGame();
	void SetLuaState(lua_State *L) { m_lua_state = L; }
	lua_State * GetLuaState() { return m_lua_state; }
	virtual void RunService(int argc, char **argv) = 0;

protected:
	enum State 
	{
		State_Runing,
		State_Quiting,
		State_Quited,
	};
	State m_state = State_Runing;
	virtual bool CanQuitGame() = 0;
	virtual void NotifyQuitGame() = 0;

	lua_State *m_lua_state = nullptr;
};

