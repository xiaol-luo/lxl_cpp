extern "C" 
{
	#include "lua.h"
	#include "lauxlib.h"
	#include "lualib.h"
}

#include "sol/sol.hpp"
#include <signal.h>
#include <memory>

#if WIN32
#include <WinSock2.h>
#include <direct.h>
#else
#include <arpa/inet.h>
#include <unistd.h>
#endif

#include "lua_reg/lua_reg.h"


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

#include "iengine.h"
class PureLuaService : public IService
{

};

static std::string ip = "127.0.0.1";
static int port = 2233;
static bool first_tick = true;

void QuitGame(int signal)
{
	log_debug("QuitGame");
	engine_stop();
}


#include "net/lua_tcp_connect.h"
#include "net/lua_tcp_listen.h"

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
		lua_pushcfunction(L, lua_error_handler);
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

void TickTestSend(lua_State *L)
{
	sol::state_view lsv(L);
	lsv["test_send"](1);
}

#include "net/http_rsp_cnn.h"
#include "net/common_listener.h"
#include "net/http_req_cnn.h"

std::shared_ptr<CommonListener> g_common_listener = nullptr;

void TestListenForHttp()
{
	log_debug("TestListenForHttp");
	g_common_listener = std::make_shared<CommonListener>();
	CommonListenCallback listen_cb;
	listen_cb.do_gen_cnn_handler = [](CommonListener *self)
	{
		return std::make_shared<HttpRspCnn>(self->GetCnnMap());
	};
	g_common_listener->SetCb(listen_cb);
	// g_common_listener->Listen(20480);
	g_common_listener->ListenAsync(20480);
}

std::shared_ptr<NetHandlerMap<INetConnectHandler>> g_http_cnns = nullptr;

void TestCnnForHttp()
{
	log_debug("-------------- TestCnnForHttp");
	std::string ctx = "sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss";
	std::shared_ptr<HttpReqCnn> cnn = std::make_shared<HttpReqCnn>(g_http_cnns);
	cnn->SetReqData("/abcdefg", false, std::unordered_map<std::string, std::string>(), ctx);
	net_connect("127.0.0.1", 20480, cnn);
}

int main (int argc, char **argv) 
{
	// argv: exe_name work_dir lua_file lua_file_params...
	if (argc < 3)
	{
		printf("exe_name work_dir lua_file ...\n");
		return -10;
	}
	char *work_dir = argv[1];
	std::string lua_file = argv[LUA_SCRIPT_IDX];

	printf("work dir is %s\n", work_dir);
	if (chdir(work_dir))
	{
		printf("change work dir fail errno %d , dir is %s\n", errno, work_dir);
		return -20;
	}
	lua_State *L = luaL_newstate();
	if (L == NULL)
	{
		printf("cannot create state: not enough memory");
		return -30;
	}

#ifdef WIN32
	WSADATA wsa_data;
	WSAStartup(0x0201, &wsa_data);
	signal(SIGINT, QuitGame);
	signal(SIGBREAK, QuitGame);
#else
	signal(SIGINT, QuitGame);
	signal(SIGPIPE, SIG_IGN);
#endif

	g_http_cnns = std::make_shared<NetHandlerMap<INetConnectHandler>>();

	engine_init();
	engine_loop_span(100);
	start_log(ELogLevel_Debug);
	PureLuaService xxx;
	setup_service(&xxx);
	timer_next(std::bind(StartLuaScript, L, argc, argv), 0);
	timer_next(TestListenForHttp, 1000);
	timer_firm(TestCnnForHttp, 1 * 200, -1);
	engine_loop();
	lua_close(L);
	engine_destroy();
	return 0;
}

