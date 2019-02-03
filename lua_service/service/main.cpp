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


#include "net_handler/lua_tcp_connect.h"
#include "net_handler/lua_tcp_listen.h"

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

#include "net_handler/http_rsp_cnn.h"
#include "net_handler/common_listener.h"
#include "net_handler/http_req_cnn.h"

static bool cnn_process_req_fn(HttpRspCnn *self,
	uint32_t req_way,
	std::string url,
	std::unordered_map<std::string, std::string> heads,
	std::string body,
	uint64_t body_len) {
	log_debug("cnn_process_req_fn {} {} {} {}", req_way, url, body, body_len);
	return false;
};

std::shared_ptr<CommonListener> g_common_listener = nullptr;
void TestListenForHttp()
{
	log_debug("TestListenForHttp");
	g_common_listener = std::make_shared<CommonListener>();
	CommonListenCallback listen_cb;
	listen_cb.do_gen_cnn_handler = [](CommonListener *self)
	{
		auto cnn = std::make_shared<HttpRspCnn>(self->GetCnnMap());
		cnn->SetReqCbFn(cnn_process_req_fn);
		return cnn;
	};
	g_common_listener->SetCb(listen_cb);
	// g_common_listener->Listen(20480);
	g_common_listener->ListenAsync(20480);
}

std::shared_ptr<NetHandlerMap<INetConnectHandler>> g_http_cnns = nullptr;

void TestCnnForHttp()
{
	log_debug("-------------- TestCnnForHttp");
	std::string ctx = "sssssssssssssssssssssssss";
	std::shared_ptr<HttpReqCnn> cnn = std::make_shared<HttpReqCnn>(g_http_cnns);
	cnn->SetReqData(true, "www.baidu.com/abcdefg?a=1", std::unordered_map<std::string, std::string>(), ctx);
	net_connect("127.0.0.1", 20480, cnn);
}

#include <regex>

int main (int argc, char **argv) 
{
	{
		// std::string url = "https://zh.cppreference.com/w/cpp/regex/regex_match";
		// std::string url = "http://zh.cppreference.com/w/cpp/regex/regex_match";
		// std::string url = "https://zh.cppreference.com:8090/w/cpp/regex/regex_match";
		std::string url = "https://www.baidu.com/s?ie=utf-8&f=8&rsv_bp=1&tn=87048150_dg&wd=c%2B%2B11%20reference&oq=c%252B%252B11%2520regex&rsv_pq=b15e9b6900010368&rsv_t=3cdazysxh6Lwn7W9fA3jT5Y%2B%2F6jMfimmaoU8EETuET7z2mYP%2BK9rzhCbDShsuyDPoaY&rqlang=cn&rsv_enter=0&inputT=4398&rsv_sug3=84&rsv_sug1=63&rsv_sug7=100&rsv_sug2=0&rsv_sug4=5001&rsv_sug=1";
		std::string match_pattern_str = R"raw(((http[s]?://)?([\S]+?))(:([1-9][0-9]*))?(/[\S]+)?)raw";
		printf("HttpReqCnn::SetReqData match_pattern %s\n", match_pattern_str.c_str());
		std::regex match_pattern(match_pattern_str, std::regex::icase);
		std::smatch match_ret;
		bool is_match = regex_match(url, match_ret, match_pattern);
		if (is_match)
		{

			for (int i = 0; i < match_ret.size(); ++i)
			{
				std::ssub_match sub_match = match_ret[i];
				printf(" sub_match %d %s\n", i, sub_match.str().c_str());
			}
			std::string host = match_ret[1].str();
			std::string port = match_ret[5].str();
			std::string method = match_ret[6].str();

			{
				std::string method = match_ret[6].str();
				std::string m_method;
				std::string params;
				int idx = method.find('?');
				if (std::string::npos == idx)
				{
					m_method = method;
				}
				else
				{
					m_method = method.substr(0, idx);
					params = method.substr(idx+1);
				}
			}
		}
		int a = 0;
		++ a;
	}


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
	// timer_firm(TestCnnForHttp, 1 * 2000, -1);
	engine_loop();
	lua_close(L);
	engine_destroy();
	return 0;
}

