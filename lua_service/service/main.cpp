extern "C" 
{
	#include "lua.h"
	#include "lauxlib.h"
	#include "lualib.h"
}

#include "sol/sol.hpp"
#include <signal.h>
#include <memory>
#include "iengine.h"
#include "lua_reg/lua_reg.h"

#if WIN32
#include <WinSock2.h>
#include <direct.h>
#define chdir _chdir
#else
#include <arpa/inet.h>
#include <unistd.h>
#endif

class PureLuaService : public IService
{

};

void QuitGame(int signal)
{
	log_debug("QuitGame");
	engine_stop();
}


#include "net_handler/lua_tcp_connect.h"
#include "net_handler/lua_tcp_listen.h"


static int lua_panic_error(lua_State* L) {
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

static int lua_pcall_error(lua_State* L) {
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

//static int lua_pcall_error(lua_State *L) 
//{
//	const char *msg = lua_tostring(L, 1);
//	if (msg == NULL) 
//	{
//		if (luaL_callmeta(L, 1, "__tostring") && lua_type(L, -1) == LUA_TSTRING)
//		{
//			return 1;
//		}
//		else
//		{
//			msg = lua_pushfstring(L, "(error object is a %s value)",luaL_typename(L, 1));
//		}
//	}
//
//	luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
//	return 1;  /* return the traceback */
//}

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

#define LUA_SCRIPT_IDX 2

void StartLuaScript(lua_State *L, int argc, char **argv)
{
	// open libs
	luaL_openlibs(L);
	register_native_libs(L);

	lua_newtable(L);
	int top = lua_gettop(L);
	int status = LUA_OK;
	do
	{
		for (int i = LUA_SCRIPT_IDX + 1; i < argc; i++)
		{
			lua_pushstring(L, argv[i]);
			lua_rawseti(L, -2, i - LUA_SCRIPT_IDX);
			// printf("argv[%d]=%s\n", i, argv[i]);
		}
		lua_setglobal(L, "arg");
		char *lua_file = argv[LUA_SCRIPT_IDX];
		status = luaL_loadfile(L, lua_file);
		if (LUA_OK != status)
		{
			lua_status_report(L, status);
			break;
		}
		int base = lua_gettop(L);
		lua_pushcfunction(L, lua_pcall_error);
		lua_insert(L, base);
		status = lua_pcall(L, 0, LUA_MULTRET, base);
		lua_remove(L, base);
		if (LUA_OK != status)
		{
			printf("%s", lua_tostring(L, -1));
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

#include <mongocxx/client.hpp>
#include <mongocxx/database.hpp>
#include <mongocxx/uri.hpp>
#include <mongocxx/instance.hpp>
#include <bsoncxx/builder/stream/document.hpp>

void try_mongodb_api()
{
	mongocxx::instance ins{};
	{
		mongocxx::uri mg_uri("mongodb://192.168.56.101:27017");
		mongocxx::client mg_client(mg_uri);
		mongocxx::database test_db = mg_client["test"];
		auto builder = bsoncxx::builder::stream::document();
		bsoncxx::document::value doc_value = builder
			<< "name" << "MongoDB"
			<< "type" << "database"
			<< "count" << 1
			<< "versions" << bsoncxx::builder::stream::open_array
			<< "v3.2" << "v3.0" << "v2.6"
			<< bsoncxx::builder::stream::close_array
			<< "info" << bsoncxx::builder::stream::open_document
			<< "x" << 203
			<< "y" << 102
			<< bsoncxx::builder::stream::close_document
			<< bsoncxx::builder::stream::finalize;


		mongocxx::collection test_coll = test_db["test_coll"];
		bsoncxx::stdx::optional<mongocxx::result::insert_one> result = test_coll.insert_one(doc_value.view());

	}
}


int main (int argc, char **argv) 
{
#ifdef WIN32
	WSADATA wsa_data;
	WSAStartup(0x0201, &wsa_data);
	signal(SIGINT, QuitGame);
	signal(SIGBREAK, QuitGame);
#else
	signal(SIGINT, QuitGame);
	signal(SIGPIPE, SIG_IGN);
#endif

	// try_mongodb_api();

	// argv: exe_name work_dir lua_file lua_file_params...
	if (argc < 3)
	{
		printf("exe_name work_dir lua_file ...\n");
		return -10;
	}
	char *work_dir = argv[1];
	printf("work dir is %s\n", work_dir);
	if (0 != chdir(work_dir))
	{
		printf("change work dir fail errno %d , dir is %s\n", errno, work_dir);
		return -20;
	}
	sol::state ls(lua_panic_error);
	lua_State *L = ls.lua_state();
	sol::protected_function::set_default_handler(sol::object(L, sol::in_place, lua_pcall_error));

	engine_init();
	engine_loop_span(100);
	start_log(ELogLevel_Debug);
	PureLuaService lua_service;
	setup_service(&lua_service);
	timer_next(std::bind(StartLuaScript, L, argc, argv), 0);
	engine_loop();
	engine_destroy();
	return 0;
}

