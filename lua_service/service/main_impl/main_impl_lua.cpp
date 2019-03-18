#include "main_impl/main_impl.h"
#include "iengine.h"
#include "lua_reg/lua_reg.h"

int lua_panic_error(lua_State* L) 
{
	size_t messagesize;
	std::string err_str;
	const char* message = lua_tolstring(L, -1, &messagesize);
	if (!message)
	{
		message = "lua_at_panic unexpected error";
		messagesize = strlen(message);
	}
	std::string err_msg(message, messagesize);
	log_error("lua_at_panic {}", err_msg.c_str());
	throw sol::error(err_msg);
}

int lua_pcall_error (lua_State* L) 
{
	std::string msg = "An unknown error has triggered the default error handler";
	sol::optional<sol::string_view> maybetopmsg = sol::stack::check_get<sol::string_view>(L, 1);
	if (maybetopmsg) {
		const sol::string_view& topmsg = maybetopmsg.value();
		msg.assign(topmsg.data(), topmsg.size());
	}
	luaL_traceback(L, L, msg.c_str(), 1);
	sol::optional<sol::string_view> maybetraceback = sol::stack::check_get<sol::string_view>(L, -1);
	if (maybetraceback) {
		const sol::string_view& traceback = maybetraceback.value();
		msg.assign(traceback.data(), traceback.size());
	}
	log_error("lua_traceback_error\n{}", msg.c_str());
	return sol::stack::push(L, msg);
}

void StartLuaScript(lua_State *L, int begin_idx, int argc, char **argv)
{
	int status = LUA_OK;
	// open libs
	luaL_openlibs(L);
	register_native_libs(L);
	lua_newtable(L);
	int top = lua_gettop(L);
	do
	{
		for (int i = begin_idx + 1; i < argc; i++)
		{
			lua_pushstring(L, argv[i]);
			lua_rawseti(L, -2, i - begin_idx);
		}
		lua_setglobal(L, "arg");
		char *lua_file = argv[begin_idx];
		status = luaL_loadfile(L, lua_file);
		if (LUA_OK != status)
		{
			log_debug(lua_tostring(L, -1));
			break;
		}
		int base = lua_gettop(L);
		lua_pushcfunction(L, lua_pcall_error);
		lua_insert(L, base);
		status = lua_pcall(L, 0, LUA_MULTRET, base);
		lua_remove(L, base);
		if (LUA_OK != status)
		{
			log_debug(lua_tostring(L, -1));
			break;
		}
	} while (false);
	lua_settop(L, top);

	if (LUA_OK != status)
	{
		log_error("StartLuaScript fail engine_stop, status: {}", status);
		engine_stop();
	}
}