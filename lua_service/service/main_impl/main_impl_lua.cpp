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

bool StartLuaScript(lua_State *L, std::string script_root_dir, int argc, char **argv, const std::vector<std::string> &extra_args)
{
	int begin_idx = argc;
	for (int i = 0; i < argc; ++i)
	{
		if (0 == std::strcmp(argv[i], Const_Lua_Args_Begin))
		{
			begin_idx = i + 1;
			break;
		}
	}
	
	int status = LUA_OK;
	// open libs
	luaL_openlibs(L);
	register_native_libs(L);
	int top = lua_gettop(L);
	do
	{
		lua_newtable(L);
		int tb_empty_slot = 1;
		{
			// 把script_root_dir加入lua的搜索路径
			lua_pushstring(L, Const_Opt_Lua_Path);
			lua_rawseti(L, -2, tb_empty_slot);
			++tb_empty_slot;
			lua_pushstring(L, script_root_dir.c_str());
			lua_rawseti(L, -2, tb_empty_slot);
			++tb_empty_slot;

			lua_pushstring(L, Const_Opt_C_Path);
			lua_rawseti(L, -2, tb_empty_slot);
			++tb_empty_slot;
			lua_pushstring(L, script_root_dir.c_str());
			lua_rawseti(L, -2, tb_empty_slot);
			++tb_empty_slot;
		}
		for (int i = begin_idx; i < argc; i++)
		{
			lua_pushstring(L, argv[i]);
			lua_rawseti(L, -2, tb_empty_slot);
			++tb_empty_slot;
		}
		for (const std::string &val : extra_args)
		{
			lua_pushstring(L, val.c_str());
			lua_rawseti(L, -2, tb_empty_slot);
			++tb_empty_slot;
		}
		lua_setglobal(L, "arg");

		std::string lua_file_path = fmt::format("{}/{}", script_root_dir, Lua_File_Prepare_Env);
		const char *lua_file = lua_file_path.c_str();
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

	bool ret = LUA_OK == status;
	if (!ret)
	{
		log_error("StartLuaScript fail, status: {}", status);
		// engine_stop();
	}
	return ret;
}

std::vector<std::string> ServiceMakeLuaExtraArgs(int argc, char ** argv)
{
	assert(argc > Args_Index_Min_Value);

	std::vector<std::string> extra_args;
	extra_args.push_back(Const_Opt_Service_Name);
	extra_args.push_back(argv[Args_Index_Service_Name]);
	extra_args.push_back(Const_Opt_Lua_Path);
	extra_args.push_back(argv[Args_Index_WorkDir]);
	extra_args.push_back(Const_Opt_C_Path);
	extra_args.push_back(argv[Args_Index_WorkDir]);
	extra_args.push_back(Const_Opt_Data_Dir);
	extra_args.push_back(argv[Args_Index_Data_Dir]);
	extra_args.push_back(Const_Opt_Native_Other_Params);
	int curr_idx = Args_Index_Lua_Dir + 1;
	while (curr_idx < argc)
	{
		char *arg = argv[curr_idx];
		if (0 == std::strcmp(arg, Const_Lua_Args_Begin))
		{
			break;
		}
		extra_args.push_back(arg);
	}
	return extra_args;
}
