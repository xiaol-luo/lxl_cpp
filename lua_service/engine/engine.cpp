extern "C" 
{
	#include "lua.h"
	#include "lauxlib.h"
	#include "lualib.h"
}

#include "sol/sol.hpp"

#include "iengine.h"

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

#define NATIVE "native"

static void register_native_fns(lua_State *L)
{
	sol::state_view sv(L);
	sol::table t = sv.create_named_table(NATIVE);
	t.set_function("chdir", change_dir);
}

